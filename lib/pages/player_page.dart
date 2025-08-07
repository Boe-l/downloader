import 'dart:ui';

import 'package:boel_downloader/widgets/song_list.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

//TODO Salvar alterações do usuario
class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({super.key});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final ResizablePaneController controller = AbsoluteResizablePaneController(200);
  final ResizablePaneController controller2 = AbsoluteResizablePaneController(300);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingHeader: true,
      headers: [],
      footers: [],
      child: ResizablePanel.horizontal(
        draggerThickness: 16,

        dividerBuilder: (context) => VerticalDivider(thickness: 2),

        children: [
          ResizablePane(initialSize: 240, minSize: 240, child: SongList()),

          //TODO Mudar para o ResizablePane.controller para utilizar o estado com colapso
          ResizablePane.flex(
            collapsedSize: 40,
            minSize: 40,

            // initialCollapsed: true,
            child: ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(scrollbars: false, overscroll: true, dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch}),

              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Test Lyrics (Lorem Ipsum)').h3]),
                    Column(
                      children: [
                        SelectableText("""


[Verse 1]
Lorem ipsum dolor sit amet, consectetur adipiscing elit,
Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation,
Ullamco laboris nisi ut aliquip ex ea commodo consequat.

[Pre-Chorus]
Duis aute irure dolor in reprehenderit in voluptate,
Velit esse cillum dolore eu fugiat nulla pariatur.

[Chorus]
Excepteur sint occaecat cupidatat non proident,
Sunt in culpa qui officia deserunt mollit anim id est laborum.
Perspiciatis unde omnis iste natus error sit voluptatem,
Accusantium doloremque laudantium, totam rem aperiam.
Eaque ipsa quae ab illo inventore veritatis et quasi,
Architecto beatae vitae dicta sunt explicabo.

[Verse 2]
Nemo enim ipsam voluptatem quia voluptas sit aspernatur,
Aut odit aut fugit, sed quia consequuntur magni dolores eos.
Qui ratione voluptatem sequi nesciunt, neque porro quisquam est,
Qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit.

[Pre-Chorus]
Sed quia non numquam eius modi tempora incidunt ut labore,
Et dolore magnam aliquam quaerat voluptatem.

[Bridge]
Nam libero tempore, cum soluta nobis est eligendi optio,
Cumque nihil impedit quo minus id quod maxime placeat,
Facere possimus, omnis voluptas assumenda est, omnis dolor repellendus.
Temporibus autem quibusdam et aut officiis debitis aut rerum,
Necessitatibus saepe eveniet ut et voluptates repudiandae.

[Chorus]
Excepteur sint occaecat cupidatat non proident,
Sunt in culpa qui officia deserunt mollit anim id est laborum.
Perspiciatis unde omnis iste natus error sit voluptatem,
Accusantium doloremque laudantium, totam rem aperiam.
Eaque ipsa quae ab illo inventore veritatis et quasi,
Architecto beatae vitae dicta sunt explicabo.""").h3,
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
