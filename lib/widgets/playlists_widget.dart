import 'package:boel_downloader/models/playlists.dart';
import 'package:boel_downloader/services/media_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class PlaylistsWidget extends StatefulWidget {
  const PlaylistsWidget({super.key});

  @override
  State<PlaylistsWidget> createState() => _PlaylistsWidgetState();
}

class _PlaylistsWidgetState extends State<PlaylistsWidget> {
  late final ScrollController _controller;
  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return SortableLayer(
      lock: true,
      child: ScrollableSortableLayer(
        controller: _controller,
        child: Selector<MediaProvider, List<PlaylistModel>>(
          selector: (_, provider) => provider.playLists,
          builder: (_, value, _) {
            List<SortableData<PlaylistModel>> playlists = value.map((element) => SortableData(element)).toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                return Sortable<PlaylistModel>(
                  key: ValueKey(playlists[index].data.hash),
                  data: playlists[index],
                  fallback: SizedBox(),
                  onAcceptTop: (value) => setState(() => playlists.swapItem(value, index)),
                  onAcceptBottom: (value) => setState(() {
                    if (index + 1 < playlists.length) {
                      playlists.swapItem(value, index + 1);
                    }
                  }),
                  child: ContextMenu(
                    items: [
                      MenuLabel(child: Text(playlists[index].data.name)),
                      MenuDivider(),
                      const MenuButton(
                        // trailing: MenuShortcut(activator: SingleActivator(LogicalKeyboardKey.bracketLeft, control: true)),
                        leading: Icon(HugeIcons.strokeRoundedPlay),
                        child: Text('Tocar'),
                      ),
                      const MenuButton(
                        // trailing: MenuShortcut(activator: SingleActivator(LogicalKeyboardKey.bracketRight, control: true)),
                        enabled: false,
                        leading: Icon(HugeIcons.strokeRoundedEdit01),

                        child: Text('Editar'),
                      ),
                      const MenuButton(
                        // trailing: MenuShortcut(activator: SingleActivator(LogicalKeyboardKey.keyR, control: true)),
                        leading: Icon(HugeIcons.strokeRoundedDelete01),

                        child: Text('Apagar'),
                      ),
                      const MenuButton(
                        subMenu: [
                          MenuButton(
                            // trailing: MenuShortcut(activator: SingleActivator(LogicalKeyboardKey.keyS, control: true)),
                            child: Text('Exportar...'),
                          ),
                          MenuButton(child: Text('Placeholder...')),
                          MenuButton(child: Text('Placeholder...')),
                          MenuDivider(),
                          MenuButton(child: Text('Placeholder...')),
                        ],
                        leading: Icon(HugeIcons.strokeRoundedListView),

                        child: Text('Mais Opções'),
                      ),
                      const MenuButton(
                        // trailing: MenuShortcut(activator: SingleActivator(LogicalKeyboardKey.keyR, control: true)),
                        leading: Icon(HugeIcons.strokeRoundedInformationCircle),
                        child: Text('Propriedades'),
                      ),
                    ],
                    child: buildPlaylistButton(playlists[index].data),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildPlaylistButton(PlaylistModel playlist) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Tooltip(
          alignment: AlignmentDirectional.centerStart,
          anchorAlignment: AlignmentDirectional.centerEnd,

          tooltip: (context) => TooltipContainer(child: Text(playlist.name)),

          // Card(child: Text(label)),
          child: Center(
            child: Button(
              style: ButtonStyle.menu(),
              onPressed: () => context.go('/playlists/${playlist.hash}'),

              child: SizedBox(
                width: 45,
                height: 45,
                child: ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(12),
                  child: playlist.image != null ? Image.memory(playlist.image!, fit: BoxFit.cover) : Image.asset('assets/images/record.jpg', fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
