import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:boel_downloader/widgets/animated_media_card.dart';
import 'package:boel_downloader/widgets/windows.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MainWidget extends StatefulWidget {
  final StatefulNavigationShell shell;
  const MainWidget({super.key, required this.shell});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  bool expanded = true;
  int selected = 0;

  NavigationItem buildButton(String text, IconData icon) {
    return NavigationItem(label: Text(text), alignment: Alignment.centerLeft, selectedStyle: const ButtonStyle.primaryIcon(), child: Icon(icon));
  }

  NavigationLabel buildLabel(String label) {
    return NavigationLabel(alignment: Alignment.centerLeft, child: Text(label).semiBold().muted());
  }

  int _getSelectedIndexFromPath(String currentPath) {
    final basePath = currentPath.split('/').firstWhere((p) => p.isNotEmpty, orElse: () => '');
    switch (basePath) {
      case '':
        return 0; // '/'
      case 'downloads':
        return 1;
      case 'playlists':
        return 2;
      case 'player':
        return 3;
      case 'history':
        return 4;
      case 'favorites':
        return 5;
      case 'settings':
        return 6;
      default:
        return 0; // Fallback para '/'
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();
    selected = _getSelectedIndexFromPath(currentPath);

    final theme = Theme.of(context);
    return OutlinedContainer(
      height: 600,
      width: 800,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NavigationRail(
                  backgroundColor: theme.colorScheme.card,
                  labelType: NavigationLabelType.expanded,
                  labelPosition: NavigationLabelPosition.end,
                  alignment: NavigationRailAlignment.start,
                  expanded: expanded,
                  index: selected,
                  onSelected: (value) {
                    setState(() {
                      selected = value;
                    });
            
                    switch (selected) {
                      case 0:
                        context.go('/home');
                      case 1:
                        context.go('/downloads');
                      case 2:
                        context.go('/playlists');
                      case 3:
                        context.go('/player');
                      case 4:
                        context.go('/history');
                      case 5:
                        context.go('/favorites');
                      case 6:
                        context.go('/settings');
                      default:
                        context.go('/home');
                    }
                  },
                  children: [
                    NavigationButton(
                      alignment: Alignment.centerLeft,
                      label: const Text('Menu'),
                      onPressed: () {
                        setState(() {
                          expanded = !expanded;
                        });
                      },
                      child: const Icon(Icons.menu),
                    ),
                    const NavigationDivider(),
                    buildButton('Baixar', HugeIcons.strokeRoundedYoutube),
                    buildButton('Downloads', HugeIcons.strokeRoundedDownloadSquare02),
                    buildButton('Playlists', HugeIcons.strokeRoundedPlayList),
                    buildButton('Player', HugeIcons.strokeRoundedMusicNote01),
                    const NavigationDivider(),
                    buildButton('Histórico', HugeIcons.strokeRoundedClock02),
                    buildButton('Favoritos', HugeIcons.strokeRoundedFavourite),
                    const NavigationDivider(),
                    buildButton('Configurações', HugeIcons.strokeRoundedSettings01),
                  ],
                ),
                const VerticalDivider(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth, // Ensure finite width
                        child: Stack(
                          children: [
                            widget.shell, // Background content
                            // Align(
                            //   alignment: Alignment.bottomLeft,
                            //   child: Padding(padding: const EdgeInsets.only(left: 20, bottom: 10, right: 20), child: AnimatedMediaCard()),
                            // ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                height: 30,
                                child: Row(
                                  children: [
                                    Expanded(child: MoveWindow()),
                                    WindowButtons(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Align(
          alignment: Alignment.bottomLeft,
          child: AnimatedMediaCard(),
        ),
        ],
      ),
    );
  }
}
