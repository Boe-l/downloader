import 'package:flutter/material.dart' hide Colors;
import 'package:shadcn_flutter/shadcn_flutter.dart' hide ColorScheme;
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:boel_downloader/models/playlists.dart';

class PlaylistHeader extends StatefulWidget {
  final PlaylistModel playlist;
  final double width;

  const PlaylistHeader({super.key, required this.playlist, required this.width});

  @override
  State<PlaylistHeader> createState() => _PlaylistHeaderState();
}

class _PlaylistHeaderState extends State<PlaylistHeader> {
  final ValueNotifier<ColorScheme?> _colorSchemeNotifier = ValueNotifier<ColorScheme?>(null);

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _loadColorScheme();
  }

  Future<void> _loadColorScheme() async {
      final colorScheme = await ColorScheme.fromImageProvider(provider: widget.playlist.image != null ? Image.memory(widget.playlist.image!, fit: BoxFit.cover).image : Image.asset('assets/images/record.jpg', fit: BoxFit.cover).image, brightness: Brightness.dark, dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot);
      _colorSchemeNotifier.value = colorScheme;
  }

  @override
  void dispose() {
    _colorSchemeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ColorScheme?>(
      valueListenable: _colorSchemeNotifier,
      builder: (context, colorScheme, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: colorScheme != null
                ? LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [colorScheme.primary.withValues(alpha: 0.9), colorScheme.surfaceContainer.withValues(alpha: 0.8)])
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [context.theme.colorScheme.background.withValues(alpha: 0.9), Colors.gray[800].withValues(alpha: 0.8)],
                  ),
          ),
          child: Column(
            children: [
                  SizedBox(height: 60),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 48),
                  Container(
                    height: (widget.width * 0.2).clamp(100, 240),
                    width: (widget.width * 0.2).clamp(100, 240),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 2, offset: const Offset(2, 2))],
                    ),
                    child: ClipRRect(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(12),
                      child: widget.playlist.image != null ? Image.memory(widget.playlist.image!, fit: BoxFit.cover) : Image.asset('assets/images/record.jpg', fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(widget.playlist.name).h1, Text('Playlist de Boel').h3],
                    ),
                  ),
                  const Spacer(flex: 10),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
