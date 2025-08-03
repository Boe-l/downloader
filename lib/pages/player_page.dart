import 'package:boel_downloader/widgets/effect_knobs.dart';
import 'package:boel_downloader/services/media_provider.dart';
import 'package:boel_downloader/widgets/song_list.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({super.key});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  final seconds = duration.inSeconds % 60;
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final ResizablePaneController controller = AbsoluteResizablePaneController(200);
  final ResizablePaneController controller2 = AbsoluteResizablePaneController(300);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingHeader: true,
      footers: [
        Container(
          height: 90,
          margin: const EdgeInsets.all(16),
          child: Card(
            child: Consumer<MediaProvider>(
              builder: (context, provider, child) {
                final media = provider.currentMedia;
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Button(
                          style: ButtonVariance.primary,
                          onPressed: media?.togglePlayPause,
                          child: Icon(size: 20, media != null && media.isPlaying ? HugeIcons.strokeRoundedPause : HugeIcons.strokeRoundedPlay),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            SizedBox(
                              width: 60,
                              child: Selector<MediaProvider, Duration>(
                                selector: (_, provider) => provider.currentMedia?.position ?? Duration.zero,
                                builder: (_, position, __) => Text(media != null ? formatDuration(position) : '00:00', textAlign: TextAlign.center),
                              ),
                            ),
                            Flexible(
                              child: Selector<MediaProvider, Duration>(
                                selector: (_, provider) => provider.currentMedia?.position ?? Duration.zero,
                                builder: (_, position, __) => Slider(
                                  value: SliderValue.single(media != null ? position.inSeconds.toDouble() : 0.0),
                                  max: media != null && media.duration.inSeconds > 0 ? media.duration.inSeconds.toDouble() : 1.0,
                                  onChanged: media != null
                                      ? (value) {
                                          media.seek(Duration(seconds: value.value.toInt()));
                                        }
                                      : null,
                                ),
                              ),
                            ),
                            SizedBox(width: 60, child: Text(media != null ? formatDuration(media.duration) : '00:00', textAlign: TextAlign.center)),
                            const Spacer(),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          child: SizedBox(
                            width: 100,
                            child: Slider(
                              value: SliderValue.single(media != null ? provider.player.state.volume : 1.0),
                              max: 1.0,
                              onChanged: media != null
                                  ? (value) {
                                      media.setVolume(value.value);
                                      provider.player.state.volume = value.value;
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
      child: Row(
        children: [
          SongList(),
          const Expanded(child: Column(children: [])),
          EffectKnobs(),
        ],
      ),
    );
  }
}
