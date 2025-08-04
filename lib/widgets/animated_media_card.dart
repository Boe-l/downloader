import 'package:boel_downloader/pages/equalizer.dart';
import 'package:boel_downloader/services/media_provider.dart';
import 'package:boel_downloader/widgets/effect_knobs.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';

String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 3)}...';
}

class AnimatedMediaCard extends StatefulWidget {
  const AnimatedMediaCard({super.key});

  @override
  AnimatedMediaCardState createState() => AnimatedMediaCardState();
}

class AnimatedMediaCardState extends State<AnimatedMediaCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widgetWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.of(context).size.width * 0.6;
        return AnimatedContainer(
          clipBehavior: Clip.antiAlias,

          decoration: BoxDecoration(
            color: context.theme.colorScheme.background,
            border: Border.all(width: 1, color: context.theme.colorScheme.border),
            borderRadius: BorderRadius.circular(47),
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutQuart,
          width: _isExpanded ? widgetWidth : 92,
          height: 91,
          child: Consumer<MediaProvider>(
            builder: (context, provider, child) {
              final title = provider.currentMedia?.title ?? '';
              final author = provider.currentMedia?.artist ?? '';
              final image = provider.currentMedia?.image;
              return Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (!_isExpanded) {
                        setState(() {
                          _isExpanded = true;
                        });
                      } else {
                        _isExpanded = false;
                        setState(() {});
                      }
                    },
                    child: SizedBox(
                      height: 90,
                      width: 90,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(60)),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: image != null ? Image.memory(image, fit: BoxFit.cover) : Center(child: const Icon(HugeIcons.strokeRoundedMusicNote01, size: 60)),
                        ),
                      ),
                    ),
                  ),
                  // if (showItems) ...[
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: _isExpanded ? 1 : 0,
                      duration: Duration(milliseconds: 400),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Text(truncateText(title, 20), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15)),
                            Text(truncateText(author, 20), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)).muted,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: _isExpanded ? 1 : 0,
                      duration: Duration(milliseconds: 400),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Button(style: ButtonVariance.ghost, onPressed: provider.previousMedia, child: Icon(HugeIcons.strokeRoundedPrevious, size: 20)),
                                  SizedBox(width: 6),
                                  Button(
                                    style: ButtonVariance.primary.withBorderRadius(borderRadius: BorderRadius.all(Radius.circular(20))),
                                    disableHoverEffect: true,

                                    onPressed: provider.togglePlayPause,
                                    child: Icon(size: 20, provider.currentMedia != null && provider.isPlaying ? HugeIcons.strokeRoundedPause : HugeIcons.strokeRoundedPlay),
                                  ),
                                  SizedBox(width: 6),

                                  Button(style: ButtonVariance.ghost, onPressed: provider.nextMedia, child: Icon(HugeIcons.strokeRoundedNext, size: 20)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // const Spacer(),
                                  SizedBox(width: 60, child: Text(provider.currentMedia != null ? formatDuration(provider.position) : '00:00', textAlign: TextAlign.center)),
                                  Expanded(
                                    child: Slider(
                                      value: SliderValue.single(provider.currentMedia != null ? provider.position.inSeconds.toDouble() : 0.0),
                                      max: provider.currentMedia != null && provider.duration.inSeconds > 0 ? provider.duration.inSeconds.toDouble() : 1.0,
                                      onChanged: provider.currentMedia != null
                                          ? (value) {
                                              provider.seek(Duration(seconds: value.value.toInt()));
                                            }
                                          : null,
                                    ),
                                  ),
                                  SizedBox(width: 60, child: Text(provider.currentMedia != null ? formatDuration(provider.duration) : '00:00', textAlign: TextAlign.center)),
                                  // const Spacer(),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: _isExpanded ? 1 : 0,
                      duration: Duration(milliseconds: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Button(
                                style: ButtonVariance.ghost,
                                child: const Icon(HugeIcons.strokeRoundedFilterHorizontal),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: 900),
                                        child: AlertDialog(
                                          title: const Text('Efeitos'),
                                          content: Column(
                                            children: [
                                              const EffectKnobs(),
                                              SizedBox(height: 100, child: Equalizer()),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Consumer<MediaProvider>(
                                  builder: (context, provider, child) {
                                    return SizedBox(
                                      width: 100,
                                      child: Slider(
                                        value: SliderValue.single(provider.currentMedia != null ? provider.player.state.volume : 1.0),
                                        max: 1.0,
                                        onChanged: provider.currentMedia != null
                                            ? (value) {
                                                provider.setVolume(value.value);
                                                provider.player.state.volume = value.value;
                                              }
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ],
                ],
              );
            },
          ),
        );
      },
    );
  }
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
