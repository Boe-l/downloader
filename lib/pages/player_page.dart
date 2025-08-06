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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Eve「心海」歌詞').h3]),
                    Column(
                      children: [
                        SelectableText(
                          
                          """[Verse 1]
                幾星霜　期待もないようなふりをした
                恥ずかし気に　でもわかってる
                というだけど
                双曲線　交わらないでいた
                何もわからぬまま　潜っては深く
                息も吸えないで
                
                [Pre-Chorus]
                微睡む白んだ光が僕を呼んだ
                手を伸ばしてくれるなら
                
                [Chorus]
                ああ心はまだ応えられないまま
                深い海凪いでは　理想描いた今
                ただ痛いほど願って　忘れはしないから
                ああこのまま立ち止まってしまったら
                涙の味でさえ　知らないままだったな
                君と笑って
                
                [Verse 2]
                空想上の世界を泳いでみたい
                黄昏の陽には　思い出が
                流れ落ちた
                消極的　希望のないような口ぶりで
                明日を見上げる空　困ったな
                未来に縋ることさえも

                [Pre-Chorus]
                見紛うくらいの煌めく声が覗いた
                傷だらけの夢だけど
                
                [Bridge]
                鼓動は速く　ざわめいていた
                心海の果てに鳴る音が
                確かに生きた　君との証なら
                きっと探していた　零れそうな　呼ぶ声が
                今いくと
                
                [Chorus]
                ああ心はまだ応えられないまま
                深い海凪いでは　理想描いた今
                ただ痛いほど願って　忘れはしないから
                ああこのまま立ち止まってしまったら
                涙の味でさえ　知らないままだったな
                君と笑って""").h3,
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
