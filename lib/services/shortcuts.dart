import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'media_provider.dart';

/// Classe que encapsula a lógica de atalhos de teclado (solo e combinações).
class TecladoOuvidor extends StatelessWidget {
  final Widget child;

  const TecladoOuvidor({super.key, required this.child});

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
                    provider.setVolume(provider.player.state.volume + 0.07);
                    return null;
                  },
                ),
                DiminuirVolumeIntent: CallbackAction<DiminuirVolumeIntent>(
                  onInvoke: (intent) {
                    provider.setVolume(provider.player.state.volume - 0.07);
                    return null;
                  },
                ),
                AvancarCtrlIntent: CallbackAction<AvancarCtrlIntent>(
                  onInvoke: (intent) {
                    provider.seek(Duration(seconds: provider.position.inSeconds + 10));
                    return null;
                  },
                ),
                RetrocederCtrlIntent: CallbackAction<RetrocederCtrlIntent>(
                  onInvoke: (intent) {
                    provider.seek(Duration(seconds: provider.position.inSeconds - 10));
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
              child: Focus(autofocus: true, skipTraversal: true, canRequestFocus: true, child: child),
            ),
          );
        },
      ),
    );
  }
}

// Intenções para teclas solo
class AvancarMusicaIntent extends Intent {}

class RetrocederMusicaIntent extends Intent {}

class PausarIntent extends Intent {}

class AumentarVolumeIntent extends Intent {}

class DiminuirVolumeIntent extends Intent {}

// Intenções para combinações de teclas
class AvancarCtrlIntent extends Intent {}

class RetrocederCtrlIntent extends Intent {}

class PausarAltIntent extends Intent {}
