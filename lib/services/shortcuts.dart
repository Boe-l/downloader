import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'media_provider.dart';

class TecladoOuvidor extends StatefulWidget {
  final Widget child;

  const TecladoOuvidor({super.key, required this.child});

  @override
  TecladoOuvidorState createState() => TecladoOuvidorState();
}

class TecladoOuvidorState extends State<TecladoOuvidor> {
  DateTime? _lastSeekStart;
  int _seekInterval = 5;
  final _seekSubject = PublishSubject<bool>();

  @override
  void initState() {
    super.initState();
    _seekSubject.throttleTime(Duration(milliseconds: 80), trailing: false).listen((isForward) {
      if (mounted) {
        _handleSeek(context.read<MediaProvider>(), isForward);
      }
    });
  }

  @override
  void dispose() {
    _seekSubject.close();
    super.dispose();
  }

  void _handleSeek(MediaProvider provider, bool isForward) {
    final now = DateTime.now();

    if (_lastSeekStart == null || now.difference(_lastSeekStart!).inMilliseconds > 500) {
      _lastSeekStart = now;
      _seekInterval = 5;
    }

    final durationPressed = now.difference(_lastSeekStart!).inMilliseconds;
    _seekInterval = (5 + (durationPressed / 1000 * 3).clamp(0, 15)).toInt();

    final currentPosition = provider.position.inSeconds;
    final maxDuration = provider.duration.inSeconds;
    final newPosition = isForward ? currentPosition + _seekInterval : currentPosition - _seekInterval;

    final clampedPosition = newPosition.clamp(0, maxDuration);

    if (clampedPosition >= 0 && clampedPosition <= maxDuration) {
      provider.seek(Duration(seconds: clampedPosition));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      canRequestFocus: true,
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          FocusScope.of(context).requestFocus();
        }
      },
      child: Consumer<MediaProvider>(
        builder: (context, provider, _) {
          return Shortcuts(
            shortcuts: {
              // Teclas solo para navegação
              LogicalKeySet(LogicalKeyboardKey.arrowRight): AvancarMusicaIntent(),
              LogicalKeySet(LogicalKeyboardKey.numpad6): AvancarMusicaIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowLeft): RetrocederMusicaIntent(),
              LogicalKeySet(LogicalKeyboardKey.numpad4): RetrocederMusicaIntent(),
              LogicalKeySet(LogicalKeyboardKey.space): PausarIntent(),
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyQ): RetrocederMusicaIntent(),
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE): AvancarMusicaIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowUp): AumentarVolumeIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowDown): DiminuirVolumeIntent(),
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.arrowLeft): RetrocederCtrlIntent(),
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.arrowRight): AvancarCtrlIntent(),
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.arrowUp): AumentarVolumeIntent(),
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.arrowDown): DiminuirVolumeIntent(),
              LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.space): PausarAltIntent(),
            },
            child: Actions(
              actions: {
                AvancarMusicaIntent: CallbackAction<AvancarMusicaIntent>(
                  onInvoke: (intent) {
                    provider.nextMedia();
                    return null;
                  },
                ),
                RetrocederMusicaIntent: CallbackAction<RetrocederMusicaIntent>(
                  onInvoke: (intent) {
                    provider.previousMedia();
                    return null;
                  },
                ),
                PausarIntent: CallbackAction<PausarIntent>(
                  onInvoke: (intent) async {
                    await provider.togglePlayPause();
                    return null;
                  },
                ),
                AumentarVolumeIntent: CallbackAction<AumentarVolumeIntent>(
                  onInvoke: (intent) {
                    provider.setVolume((provider.player.state.volume + 0.07).clamp(0.0, 1.0));
                    return null;
                  },
                ),
                DiminuirVolumeIntent: CallbackAction<DiminuirVolumeIntent>(
                  onInvoke: (intent) {
                    provider.setVolume((provider.player.state.volume - 0.07).clamp(0.0, 1.0));
                    return null;
                  },
                ),
                AvancarCtrlIntent: CallbackAction<AvancarCtrlIntent>(
                  onInvoke: (intent) {
                    _seekSubject.add(true);
                    return null;
                  },
                ),
                RetrocederCtrlIntent: CallbackAction<RetrocederCtrlIntent>(
                  onInvoke: (intent) {
                    _seekSubject.add(false);
                    return null;
                  },
                ),
                PausarAltIntent: CallbackAction<PausarAltIntent>(
                  onInvoke: (intent) async {
                    await provider.togglePlayPause();
                    return null;
                  },
                ),
              },
              child: Focus(autofocus: true, skipTraversal: true, canRequestFocus: true, child: widget.child),
            ),
          );
        },
      ),
    );
  }
}

class AvancarMusicaIntent extends Intent {}

class RetrocederMusicaIntent extends Intent {}

class PausarIntent extends Intent {}

class AumentarVolumeIntent extends Intent {}

class DiminuirVolumeIntent extends Intent {}

class AvancarCtrlIntent extends Intent {}

class RetrocederCtrlIntent extends Intent {}

class PausarAltIntent extends Intent {}
