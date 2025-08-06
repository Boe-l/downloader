
#include "flutter_window.h"
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <optional>
#include "flutter/generated_plugin_registrant.h"
#include <windows.h>
#include <systemmediatransportcontrolsinterop.h>
#include <winrt/Windows.Media.h>
#include <winrt/Windows.Media.Playback.h>
#include <winrt/Windows.Storage.Streams.h>
#include <winrt/Windows.Foundation.h>
#include <vector>

using namespace winrt;
using namespace Windows::Foundation;
using namespace Windows::Media;
using namespace Windows::Media::Playback;
using namespace Windows::Storage::Streams;

namespace
{

  static SystemMediaTransportControls s_smtc = nullptr;
  static std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> s_event_sink = nullptr;

  void InitializeMediaControls(HWND hwnd)
  {
    try
    {
      auto smtcInterop = winrt::get_activation_factory<SystemMediaTransportControls, ISystemMediaTransportControlsInterop>();
      if (!hwnd)
      {
        OutputDebugStringW(L"Error: No active window found\n");
        return;
      }
      winrt::check_hresult(smtcInterop->GetForWindow(hwnd, winrt::guid_of<SystemMediaTransportControls>(), winrt::put_abi(s_smtc)));

      s_smtc.IsPlayEnabled(true);
      s_smtc.IsPauseEnabled(true);
      s_smtc.IsNextEnabled(true);
      s_smtc.IsPreviousEnabled(true);
      s_smtc.DisplayUpdater().Type(MediaPlaybackType::Music);
      s_smtc.PlaybackStatus(MediaPlaybackStatus::Playing);

      s_smtc.ButtonPressed(winrt::Windows::Foundation::TypedEventHandler<
                           SystemMediaTransportControls, SystemMediaTransportControlsButtonPressedEventArgs>(
          [](SystemMediaTransportControls const &sender, SystemMediaTransportControlsButtonPressedEventArgs const &args)
          {
            if (s_event_sink)
            {
              switch (args.Button())
              {
              case SystemMediaTransportControlsButton::Play:
                s_smtc.PlaybackStatus(MediaPlaybackStatus::Playing);
                s_event_sink->Success(flutter::EncodableValue("play"));
                OutputDebugStringW(L"Play button pressed\n");
                break;
              case SystemMediaTransportControlsButton::Pause:
                s_smtc.PlaybackStatus(MediaPlaybackStatus::Paused);
                s_event_sink->Success(flutter::EncodableValue("pause"));
                OutputDebugStringW(L"Pause button pressed\n");
                break;
              case SystemMediaTransportControlsButton::Next:
                s_event_sink->Success(flutter::EncodableValue("next"));
                OutputDebugStringW(L"Next button pressed\n");
                break;

              case SystemMediaTransportControlsButton::Previous:
                s_event_sink->Success(flutter::EncodableValue("previous"));
                OutputDebugStringW(L"Previous button pressed\n");
                break;
              default:
                OutputDebugStringW(L"Unknown button pressed\n");
                break;
              }
            }
          }));
      OutputDebugStringW(L"SMTC initialized successfully\n");
    }
    catch (const winrt::hresult_error &ex)
    {
      OutputDebugStringW(L"Error initializing SMTC: ");
      OutputDebugStringW(ex.message().c_str());
      OutputDebugStringW(L"\n");
    }
  }

  void SetMusicProperties(const flutter::EncodableMap &args)
  {
    try
    {
      auto updater = s_smtc.DisplayUpdater();
      auto musicProps = updater.MusicProperties();

      for (const auto &pair : args)
      {
        auto key = std::get<std::string>(pair.first);
        if (std::holds_alternative<std::string>(pair.second))
        {
          auto value = std::get<std::string>(pair.second);
          if (key == "title")
          {
            musicProps.Title(winrt::to_hstring(value));
          }
          else if (key == "artist")
          {
            musicProps.Artist(winrt::to_hstring(value));
          }
          else if (key == "album")
          {
            musicProps.AlbumTitle(winrt::to_hstring(value));
          }
        }
        else if (std::holds_alternative<std::vector<uint8_t>>(pair.second) && key == "thumbnail")
        {
          auto bytes = std::get<std::vector<uint8_t>>(pair.second);
          if (!bytes.empty())
          {
            // Ignore for now
            InMemoryRandomAccessStream stream;
            DataWriter writer(stream);
            writer.WriteBytes(bytes);
            writer.FlushAsync().get();
            // Set thumbnail
            updater.Thumbnail(RandomAccessStreamReference::CreateFromStream(stream));
          }
          else
          {
            OutputDebugStringW(L"Error: Empty thumbnail bytes\n");
          }
        }
      }
      updater.Update();

      OutputDebugStringW(L"Music properties set successfully\n");
    }
    catch (const winrt::hresult_error &ex)
    {
      OutputDebugStringW(L"Error setting music properties: ");
      OutputDebugStringW(ex.message().c_str());
      OutputDebugStringW(L"\n");
    }
  }

} // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject &project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate()
{
  if (!Win32Window::OnCreate())
  {
    return false;
  }

  RECT frame = GetClientArea();

  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  if (!flutter_controller_->engine() || !flutter_controller_->view())
  {
    return false;
  }

  flutter::MethodChannel<flutter::EncodableValue> method_channel(
      flutter_controller_->engine()->messenger(), "com.example/audio_player",
      &flutter::StandardMethodCodec::GetInstance());
  method_channel.SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue> &call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
      {
        OutputDebugStringW(L"MethodChannel registered\n");
        OutputDebugStringW((L"Handling method: " + winrt::to_hstring(call.method_name()) + L"\n").c_str());
        if (call.method_name() == "setMusicProperties")
        {
          const auto *args = std::get_if<flutter::EncodableMap>(call.arguments());
          if (args)
          {
            SetMusicProperties(*args);
            result->Success();
          }
          else
          {
            result->Error("INVALID_ARGS", "Expected map arguments");
          }
        }
        else
        {
          result->NotImplemented();
        }
      });

  flutter::EventChannel<flutter::EncodableValue> event_channel(
      flutter_controller_->engine()->messenger(), "com.example/audio_player_events",
      &flutter::StandardMethodCodec::GetInstance());
  event_channel.SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
          [](const flutter::EncodableValue *arguments,
             std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&events)
              -> std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
          {
            OutputDebugStringW(L"EventChannel registered\n");
            s_event_sink = std::move(events);
            return nullptr;
          },
          [](const flutter::EncodableValue *arguments)
              -> std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
          {
            s_event_sink = nullptr;
            return nullptr;
          }));

  InitializeMediaControls(GetHandle());

  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]()
                                                      { this->Show(); });
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy()
{
  if (flutter_controller_)
  {
    flutter_controller_ = nullptr;
  }
  s_smtc = nullptr;
  s_event_sink = nullptr;
  Win32Window::OnDestroy();
}

LRESULT FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                                      WPARAM const wparam,
                                      LPARAM const lparam) noexcept
{
  if (flutter_controller_)
  {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam, lparam);
    if (result)
    {
      return *result;
    }
  }

  switch (message)
  {
  case WM_FONTCHANGE:
    if (flutter_controller_)
    {
      flutter_controller_->engine()->ReloadSystemFonts();
    }
    break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}