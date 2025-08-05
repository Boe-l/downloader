import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'media_provider.dart';

/// Classe que encapsula a lógica de atalhos de teclado (solo e combinações).
class TecladoOuvidor extends StatelessWidget {
  final Widget child;

  const TecladoOuvidor({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaProvider>(
            builder: (context, provider, _) {
        return Shortcuts(
          shortcuts: {
            // Teclas solo
            LogicalKeySet(LogicalKeyboardKey.arrowRight): AvancarIntent(),
            LogicalKeySet(LogicalKeyboardKey.numpad6): AvancarIntent(),
            LogicalKeySet(LogicalKeyboardKey.arrowLeft): RetrocederIntent(),
            LogicalKeySet(LogicalKeyboardKey.numpad4): RetrocederIntent(),
            LogicalKeySet(LogicalKeyboardKey.space): PausarIntent(),
            // // Combinações de teclas
            // LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.arrowRight): AvancarCtrlIntent(),
            // LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.arrowLeft): RetrocederCtrlIntent(),
            // LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.space): PausarAltIntent(),
          },
          child: Actions(
            actions: {
              AvancarIntent: CallbackAction<AvancarIntent>(
                onInvoke: (intent)  {
					provider.seek(Duration(seconds: provider.position.inSeconds + 5));
					return null;
				},
              ),
              RetrocederIntent: CallbackAction<RetrocederIntent>(
                onInvoke: (intent) {
					provider.seek(Duration(seconds: provider.position.inSeconds - 5));
					return null;
				},
              ),
              PausarIntent: CallbackAction<PausarIntent>(
                onInvoke: (intent) async {
					await provider.togglePlayPause();
					return null;
				},
              ),
            //   AvancarCtrlIntent: CallbackAction<AvancarCtrlIntent>(
            //     onInvoke: (intent) => avancar(),
            //   ),
            //   RetrocederCtrlIntent: CallbackAction<RetrocederCtrlIntent>(
            //     onInvoke: (intent) => retroceder(),
            //   ),
            //   PausarAltIntent: CallbackAction<PausarAltIntent>(
            //     onInvoke: (intent) => pausar(),
            //   ),
            },
            child: Focus(
              autofocus: true, // Garante foco para capturar eventos de teclado
			  skipTraversal: true,
              child: child,
            ),
          ),
        );
      }
    );
  }
}

// Intenções para teclas solo
class AvancarIntent extends Intent {}
class RetrocederIntent extends Intent {}
class PausarIntent extends Intent {}

// Intenções para combinações de teclas
// class AvancarCtrlIntent extends Intent {}
// class RetrocederCtrlIntent extends Intent {}
// class PausarAltIntent extends Intent {}