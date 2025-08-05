import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'media_provider.dart';

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
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent) {
          final provider = Provider.of<MediaProvider>(context, listen: false);
          final bool isCtrlPressed = (event.logicalKey == LogicalKeyboardKey.controlLeft);
          final bool isAltPressed = (event.logicalKey == LogicalKeyboardKey.alt);

          // Teclas solo
          if (!isCtrlPressed && !isAltPressed && (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.numpad6 || event.logicalKey == LogicalKeyboardKey.keyD)) {
            provider.seek(Duration(seconds: provider.position.inSeconds + 5));
            return KeyEventResult.handled;
          } else if (!isCtrlPressed &&
              !isAltPressed &&
              (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.numpad4 || event.logicalKey == LogicalKeyboardKey.keyA)) {
            provider.seek(Duration(seconds: provider.position.inSeconds - 5));
            return KeyEventResult.handled;
          } else if (!isCtrlPressed && !isAltPressed && event.logicalKey == LogicalKeyboardKey.space) {
            provider.togglePlayPause();
            return KeyEventResult.handled;
          } else if (!isCtrlPressed && !isAltPressed && event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.keyW) {
            provider.setVolume(provider.player.state.volume + 0.1);
            return KeyEventResult.handled;
          } else if (!isCtrlPressed && !isAltPressed && event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.keyS) {
            provider.setVolume(provider.player.state.volume - 0.1);
            return KeyEventResult.handled;
          } else if (!isCtrlPressed && !isAltPressed && event.logicalKey == LogicalKeyboardKey.keyQ) {
            provider.previousMedia();
            return KeyEventResult.handled;
          } else if (!isCtrlPressed && !isAltPressed && event.logicalKey == LogicalKeyboardKey.keyE) {
            provider.nextMedia();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Consumer<MediaProvider>(
        builder: (context, provider, _) {
          return Focus(autofocus: true, skipTraversal: true, child: child);
        },
      ),
    );
  }
}
