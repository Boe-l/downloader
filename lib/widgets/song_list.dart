import 'package:boel_downloader/widgets/song_item.dart';
import 'package:boel_downloader/services/media_provider.dart';
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
    return Container(
      constraints: BoxConstraints(maxWidth: 300),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Button(
                style: ButtonVariance.menubar,
                onPressed: () async {
                  await context.read<MediaProvider>().loadMediaFromFolder();
                  setState(() {});
                },
                child: const Text('Abrir Pasta'),
              ),
            ),
          ),
          SliverFillRemaining(
            child: Selector<MediaProvider, int>(
              selector: (_, provider) => provider.currentIndex,
              builder: (context, currentIndex, child) {
                final provider = context.read<MediaProvider>();
                return ListView.builder(
                  // Como estamos dentro de um Sliver, usamos ListView.builder com physics ajustado
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.mediaFiles.length,
                  itemBuilder: (context, index) {
                    return SongItem(
                      key: ValueKey(provider.mediaFiles[index].file.path),
                      media: provider.mediaFiles[index],
                      isSelected: index == currentIndex,
                      onSelect: () => provider.setCurrentMedia(provider.mediaFiles[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
