
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:boel_downloader/widgets/animated_media_card.dart';
import 'package:boel_downloader/widgets/playlists_widget.dart';
import 'package:boel_downloader/widgets/windows.dart';
import 'package:flutter/gestures.dart';
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
  NavigationRailAlignment alignment = NavigationRailAlignment.start;
  NavigationLabelType labelType = NavigationLabelType.tooltip;
  NavigationLabelPosition labelPosition = NavigationLabelPosition.bottom;
  int selected = 0;

  bool customButtonStyle = false;
  bool expanded = true;
  NavigationItem buildButton(String label, IconData icon) {
    return NavigationItem(
      style: null,
      selectedStyle: customButtonStyle ? const ButtonStyle.fixed(density: ButtonDensity.icon) : null,
      label: Text(label),
      child: Icon(icon),
    );
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

    return OutlinedContainer(
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 86,
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(dragDevices: {PointerDeviceKind.touch}, scrollbars: false),
                    child: Column(
                      children: [
                        NavigationRail(
                          alignment: alignment,
                          labelType: labelType,
                          index: selected,
                          labelPosition: labelPosition,
                          expanded: expanded,
                          onSelected: (value) {
                            setState(() {
                              selected = value;
                            });

                            switch (selected) {
                              case 0:
                                context.go('/home');
                              case 1:
                                context.go('/downloads');
                              // case 2:
                              //   context.go('/playlists');
                              // // case 3:
                              // //   context.go('/player');
                              // // case 4:
                              // //   context.go('/history');
                              // // case 5:
                              // //   context.go('/favorites');
                              // // case 6:
                              // //   context.go('/settings');
                              default:
                                context.go('/home');
                            }
                          },
                          children: [
                            buildButton('Baixar', HugeIcons.strokeRoundedYoutube),
                            buildButton('Downloads', HugeIcons.strokeRoundedDownloadSquare02),
                            // buildButton('Configurações', HugeIcons.strokeRoundedSettings01),
                            // const NavigationDivider(),
                            // buildButton('Player', HugeIcons.strokeRoundedMusicNote01),
                            const NavigationDivider(),
                            const NavigationLabel(child: Text('Listas')),
                            buildButton('Nova Lista', HugeIcons.strokeRoundedAddSquare),
                          ],
                        ),
                        Expanded(child: PlaylistsWidget()),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: Stack(
                          children: [
                            widget.shell,
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
          Align(alignment: Alignment.bottomLeft, child: AnimatedMediaCard()),
        ],
      ),
    );
  }
}
