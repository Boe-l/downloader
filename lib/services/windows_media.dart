import 'dart:async';
import 'package:flutter/services.dart';

class SMTCWIN {
  static const MethodChannel _methodChannel = MethodChannel('com.example/audio_player');
  static const EventChannel _eventChannel = EventChannel('com.example/audio_player_events');
  static Stream<String>? _mediaButtonStream;

  static Future<void> setMusicProperties({
    required String title,
    required String artist,
    required String album,
    Uint8List? thumbnail, // Byte array para a imagem
  }) async {
    try {
      if (thumbnail != null && thumbnail.isNotEmpty) {
        final Map<String, dynamic> args = {'title': title, 'artist': artist, 'album': album, 'thumbnail': thumbnail};
        await _methodChannel.invokeMethod('setMusicProperties', args);
        // print('Music properties set successfully');
      } else {
        // print('Thumbnail data is null or empty, skipping thumbnail');
        final Map<String, dynamic> args = {'title': title, 'artist': artist, 'album': album};
        await _methodChannel.invokeMethod('setMusicProperties', args);
      }
    } catch (e) {
      // print('Error setting music properties: $e');
    }
  }

  static Stream<String> get mediaButtonStream {
    _mediaButtonStream ??= _eventChannel.receiveBroadcastStream().map((event) {
      final action = event.toString();

      // print('Media button pressed: $action, IsPlaying: $_isPlaying');
      return action;
    });
    return _mediaButtonStream!;
  }
}
