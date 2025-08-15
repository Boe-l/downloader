import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:boel_downloader/models/playlists.dart';
import 'package:boel_downloader/pages/downloads_page.dart';
import 'package:boel_downloader/pages/player_page.dart';
import 'package:boel_downloader/services/media_provider.dart';
import 'package:boel_downloader/widgets/visualizer.dart';
import 'package:boel_downloader/widgets/search_page.dart';
import 'package:boel_downloader/widgets/main_widget.dart';
import 'package:boel_downloader/widgets/windows.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class AppRouter {
  AppRouter();
  GoRouter get router => GoRouter(
    initialLocation: '/home',

    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainWidget(shell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) {
                  return SearchPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/downloads',
                builder: (context, state) {
                  return DownloadsPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/playlists',
                builder: (context, state) {
                  return ShaderVisualizer();
                },
              ),
              GoRoute(
                path: '/playlists/:id',
                builder: (context, state) {
                  final playlistId = state.pathParameters['id'];
                  final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
                  final playlist = mediaProvider.playLists.firstWhere((p) => p.hash == playlistId, orElse: () => PlaylistModel(name: ''));
                  return AudioPlayerPage(playlist: playlist,);
                },
              ),
            ],
          ),
          // StatefulShellBranch(
          //   routes: [
              
          //   ],
          // ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) {
                  return Placeholder();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) {
                  return Placeholder();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) {
                  return Placeholder();
                },
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      return Card(
        child: Center(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Página não implementada: ${state.uri.path}'),
                    Button(style: ButtonVariance.secondary, onPressed: () => context.go('/home'), child: Text('Voltar ao inicio')),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Expanded(child: MoveWindow()),
                    WindowButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
    redirect: (context, state) {
      return null;
    },
  );
}
