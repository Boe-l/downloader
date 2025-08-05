import 'package:boel_downloader/widgets/song_list.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: SizedBox(
                height: 55,
                width: 500,

                child: TextField(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(32)),

                    border: Border.all(width: 1, color: Colors.white),
                  ),
                  placeholder: Text('Busque uma Música').h4,
                  features: [
                    InputFeature.trailing(
                      ExcludeFocus(
                        child: Button(style: ButtonVariance.ghost, onPressed: () {}, child: Icon(HugeIcons.strokeRoundedSearch01, size: 22)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: SongList()),
        ],
      ),
    );
  }
}
