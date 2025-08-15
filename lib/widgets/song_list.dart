import 'dart:ui';
import 'package:boel_downloader/models/playlists.dart';
import 'package:boel_downloader/services/media_provider.dart';
import 'package:boel_downloader/widgets/playlist_header.dart';
import 'package:flutter/material.dart' show FlexibleSpaceBar, kToolbarHeight;
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';

class SongList extends StatefulWidget {
  final PlaylistModel? playlist;
  const SongList({super.key, this.playlist});

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaProvider>(
      builder: (context, mediaProvider, child) {
        final mediaFiles = widget.playlist?.mediaFiles ?? mediaProvider.mediaFiles;
        final currentIndex = widget.playlist?.currentIndex ?? mediaProvider.currentIndex;
        final width = MediaQuery.of(context).size.width;

        return Scaffold(
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: false, overscroll: true, dragDevices: {PointerDeviceKind.touch}),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: context.theme.colorScheme.background,
                  expandedHeight: 350,
                  pinned: true,
                  stretch: true,
                  foregroundColor: context.theme.colorScheme.background,
                  surfaceTintColor: context.theme.colorScheme.background,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final appBarHeight = constraints.biggest.height;
                      final showPinnedTitle = appBarHeight <= kToolbarHeight + 20;

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          FlexibleSpaceBar(
                            background: PlaylistHeader(playlist: widget.playlist!, width: width),
                          ),

                          Positioned(
                            left: 6,
                            bottom: 16,
                            child: AnimatedOpacity(
                              opacity: showPinnedTitle ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Row(
                                children: [
                                  SizedBox(width: 40),
                                  Text(
                                    widget.playlist!.name,
                                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                  ).h1,
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                SliverPersistentHeader(
                  pinned: true,
                  // floating: true,
                  delegate: _SongListHeaderDelegate(
                    child: Column(
                      children: [
                        Container(
                          color: context.theme.colorScheme.background,
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: const [
                              SizedBox(width: 40),
                              Text('Título'),
                              Spacer(),
                              Text('Artista'),
                              SizedBox(width: 118),
                              Spacer(flex: 1),
                              Icon(HugeIcons.strokeRoundedClock01),
                              SizedBox(width: 50),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                ),

                // const SliverToBoxAdapter(child: Divider(height: 2,)),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final media = mediaFiles[index];
                    final isHovered = _hoveredIndex == index;

                    return MouseRegion(
                      onEnter: (_) => setState(() => _hoveredIndex = index),
                      onExit: (_) => setState(() => _hoveredIndex = null),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 56,
                        color: isHovered ? Theme.of(context).colorScheme.popoverForeground.withValues(alpha: 0.1) : Colors.transparent,
                        child: ContextMenu(
                          direction: Axis.vertical,
                          items: [
                            MenuButton(
                              leading: const Icon(HugeIcons.strokeRoundedPlay),
                              trailing: const MenuShortcut(activator: SingleActivator(LogicalKeyboardKey.keyP, control: true)),
                              child: const Text('Tocar'),
                              onPressed: (a) => mediaProvider.setCurrentMedia(media),
                            ),
                            MenuButton(
                              leading: const Icon(HugeIcons.strokeRoundedFavourite),
                              trailing: const MenuShortcut(activator: SingleActivator(LogicalKeyboardKey.keyF, control: true)),
                              child: const Text('Favoritar'),
                            ),
                            MenuButton(
                              leading: const Icon(HugeIcons.strokeRoundedFolder01),
                              trailing: const MenuShortcut(activator: SingleActivator(LogicalKeyboardKey.keyO, control: true)),
                              child: const Text('Abrir Local'),
                            ),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                mediaProvider.setCurrentMedia(media);
                              },
                              child: Row(
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: SizedBox(
                                      key: ValueKey<int>(index),
                                      width: 40,
                                      child: isHovered || index == currentIndex
                                          ? Icon(Icons.play_arrow, color: index == currentIndex ? Colors.green : Colors.white)
                                          : Text(
                                              '${index + 1}',
                                              style: TextStyle(fontWeight: index == currentIndex ? FontWeight.bold : FontWeight.normal),
                                              textAlign: TextAlign.center,
                                            ),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.memory(
                                      media.image ?? Uint8List(0),
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.fitHeight,
                                      errorBuilder: (_, __, ___) => Image.asset('assets/images/record.jpg', fit: BoxFit.fitHeight),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: isHovered
                                        ? OverflowMarquee(
                                            child: Text(
                                              media.title,
                                              style: TextStyle(color: index == currentIndex ? Colors.green : Colors.white),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        : Text(
                                            media.title,
                                            style: TextStyle(color: index == currentIndex ? Colors.green : Colors.white),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 170,
                                    child: Text(truncateText(media.artist, 60), style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis).muted,
                                  ),
                                  const Spacer(flex: 1),
                                  SizedBox(
                                    width: 50,
                                    child: Text(formatDuration(media.duration), style: const TextStyle(fontSize: 13), textAlign: TextAlign.right).muted,
                                  ),
                                  const SizedBox(width: 40),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: mediaFiles.length),
                ),

                // Espaço no final
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SongListHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SongListHeaderDelegate({required this.child});

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _SongListHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
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
