import 'dart:ui';
import 'package:boel_downloader/services/files_provider.dart';
import 'package:boel_downloader/services/media_provider.dart';
import 'package:boel_downloader/services/playlist_provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';

class SongList extends StatefulWidget {
  const SongList({super.key});

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingHeader: true,
      headers: [
        Container(
          color: context.theme.colorScheme.background,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ExcludeFocus(
                      child: Button(
                        style: ButtonVariance.menubar,
                        onPressed: () => Provider.of<MediaProvider>(context, listen: false).addFolderPath(),
                        child: const Icon(HugeIcons.strokeRoundedFolderAdd),
                      ),
                    ),
                    Text('Titulo'),
                    Spacer(),
                    Spacer(),

                    Text('Artista'),
                    SizedBox(width: 96),

                    Spacer(flex: 2),
                    Text('Duração'),
                    SizedBox(width: 30),
                  ],
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            // Button to load media

            // Song list with scroll
            Expanded(
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(scrollbars: false, overscroll: true, dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch}),
                child: SingleChildScrollView(
                  child: Consumer<MediaProvider>(
                    // : (_, provider) => (provider.currentIndex, provider.mediaFiles.length),
                    builder: (context, mediaProvider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...mediaProvider.mediaFiles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final media = entry.value;
                            final isHovered = _hoveredIndex == index;
                            return MouseRegion(
                              onEnter: (_) => setState(() => _hoveredIndex = index),
                              onExit: (_) => setState(() => _hoveredIndex = null),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 56, // Fixed height for each row
                                color: isHovered ? Theme.of(context).colorScheme.popoverForeground.withValues(alpha: 0.1) : Colors.transparent,
                                child: ContextMenu(
                                  direction: Axis.vertical,
                                  items: const [
                                    MenuButton(leading: Icon(HugeIcons.strokeRoundedPlay), child: Text('Tocar Música')),
                                    MenuButton(leading: Icon(HugeIcons.strokeRoundedText), child: Text('Buscar Letra')),
                                    MenuButton(leading: Icon(HugeIcons.strokeRoundedFavourite), child: Text('Favoritar')),
                                    MenuButton(leading: Icon(HugeIcons.strokeRoundedFolder01), child: Text('Abrir Local')),
                                  ],
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () => mediaProvider.setCurrentMedia(media),
                                      child: Row(
                                        children: [
                                          // Song number or play icon with AnimatedSwitcher
                                          AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 200),
                                            child: SizedBox(
                                              key: ValueKey<int>(index), // Unique key based on index
                                              width: 40,
                                              child: isHovered || index == mediaProvider.currentIndex
                                                  ? Icon(Icons.play_arrow, color: index == mediaProvider.currentIndex ? Colors.green : Colors.white)
                                                  : Text(
                                                      '${index + 1}',
                                                      style: TextStyle(fontWeight: index == mediaProvider.currentIndex ? FontWeight.bold : FontWeight.normal),
                                                      textAlign: TextAlign.center,
                                                    ),
                                            ),
                                          ),
                                          // Song image
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(5),
                                            child: Image.memory(media.image!, height: 40, width: 40, fit: BoxFit.fitHeight),
                                          ),
                                          const SizedBox(width: 8),
                                          // Song title (expanded for flexibility)
                                          Expanded(
                                            child: isHovered
                                                ? OverflowMarquee(
                                                    child: Text(
                                                      media.title,
                                                      style: TextStyle(
                                                        color: index == mediaProvider.currentIndex ? Colors.green : Colors.white,
                                                        // fontWeight: index == provider.currentIndex ? FontWeight.bold : FontWeight.normal,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                : Text(
                                                    media.title,
                                                    style: TextStyle(
                                                      color: index == mediaProvider.currentIndex ? Colors.green : Colors.white,
                                                      // fontWeight: index == provider.currentIndex ? FontWeight.bold : FontWeight.normal,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Artist (fixed width for consistency)
                                          SizedBox(
                                            width: 170,
                                            child: Text(truncateText(media.artist, 60), style: TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis).muted,
                                          ),
                                          Spacer(flex: 1),

                                          // Duration (fixed width, right-aligned)
                                          SizedBox(
                                            width: 50,
                                            child: Text(formatDuration(media.duration), style: TextStyle(fontSize: 13), textAlign: TextAlign.right).muted,
                                          ),
                                          // Spacer(flex: 1,),
                                          SizedBox(width: 40),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 3)}...';
}

String formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
