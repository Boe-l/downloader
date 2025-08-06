import 'dart:ui';

import 'package:boel_downloader/services/media_provider.dart';
import 'package:boel_downloader/widgets/card_animation_hover.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SongList extends StatefulWidget {
  const SongList({super.key});

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SizedBox(height: 50),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExcludeFocus(
                child: Button(
                  style: ButtonVariance.menubar,
                  onPressed: () async {
                    await context.read<MediaProvider>().loadMediaFromFolder();
                  },
                  child: const Icon(HugeIcons.strokeRoundedFolderAdd),
                ),
              ),
            ),
            Spacer(),
          ],
        ),
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(scrollbars: false, overscroll: true, dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch}),

            child: SingleChildScrollView(
              child: Selector<MediaProvider, (int, int)>(
                selector: (_, provider) => (provider.currentIndex, provider.mediaFiles.length),
                builder: (context, data, child) {
                  final provider = context.read<MediaProvider>();
                  final List<Map<String, dynamic>> cards = [
                    for (var entry in provider.mediaFiles.asMap().entries) {'image': entry.value.image, 'header': entry.value.title, 'content': entry.value.artist, 'index': entry.key},
                  ];

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 30.0,
                        runSpacing: 33.0,
                        children: cards
                            .map(
                              (card) => ContextMenu(
                                direction: Axis.vertical,
                                items: [
                                  // MenuLabel(leading: Text('Opções'))
                                  // ,
                                  MenuButton(leading: Icon(HugeIcons.strokeRoundedPlay), child: Text('Tocar Música')),
                                  MenuButton(leading: Icon(HugeIcons.strokeRoundedText), child: Text('Buscar Letra')),
                                  MenuButton(leading: Icon(HugeIcons.strokeRoundedFavourite), child: Text('Favoritar')),
                                  MenuButton(leading: Icon(HugeIcons.strokeRoundedFolder01), child: Text('Abrir Local')),
                                ],
                                child: CardAnimationHover(
                                  card: card,
                                  showAnimation: true,
                                  height: 150,
                                  width: 150,
                                  highlight: card['index'] == provider.currentIndex, // Set highlight based on index
                                  onTap: () {
                                    provider.setCurrentMedia(provider.mediaFiles[card['index']]);
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
