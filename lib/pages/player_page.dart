import 'package:boel_downloader/widgets/song_list.dart';
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
      footers: [],
      child: Row(
        children: [
          SongList(),
          const Expanded(child: Column(children: [])),
        ],
      ),
    );
  }
}
