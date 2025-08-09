import 'package:boel_downloader/pages/equalizer.dart';
import 'package:boel_downloader/services/media_provider.dart';
import 'package:boel_downloader/tools/Throttler.dart';
import 'package:boel_downloader/widgets/effect_knobs.dart';
import 'package:flutter/gestures.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';

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
  final ValueNotifier<bool> _isExpanded = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showContent = ValueNotifier<bool>(false);
  final Throttler _throttler = Throttler(milliseconds: 1200);
  @override
  void dispose() {
    _isExpanded.dispose();
    _showContent.dispose();
    super.dispose();
  }

  void switchHeight() async {
    if (!_isExpanded.value) {
      _isExpanded.value = true;
      _showContent.value = true;
    } else {
      _isExpanded.value = false;
      await Future.delayed(const Duration(milliseconds: 700));
      _showContent.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isExpanded,
        builder: (context, isExpanded, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastEaseInToSlowEaseOut,
            // width: widgetWidth,
            height: isExpanded ? 90 : 20,
            child: ClipRect(
              child: Consumer<MediaProvider>(
                builder: (context, provider, child) {
                  final title = provider.currentMedia?.title ?? '';
                  final author = provider.currentMedia?.artist ?? '';
                  final image = provider.currentMedia?.image;
                  return Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => _throttler.run(() {
                                switchHeight();
                              }),
                              child: SizedBox(
                                height: 15,
                                width: double.infinity,
                                child: Center(
                                  child: ValueListenableBuilder<bool>(
                                    valueListenable: _isExpanded,
                                    builder: (context, isExpanded, child) {
                                      return Icon(isExpanded ? HugeIcons.strokeRoundedArrowDown01 : HugeIcons.strokeRoundedArrowUp01, size: 20);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: _showContent,
                            builder: (context, showContent, child) {
                              return showContent
                                  ? Expanded(
                                      child: AnimatedOpacity(
                                        duration: const Duration(milliseconds: 300),
                                        opacity: isExpanded ? 1.0 : 0.0,
                                        curve: Curves.easeInOut,
                                        child: Stack(
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Button(
                                                      style: ButtonVariance.ghost,
                                                      onPressed: () => _throttler.run(() => provider.previousMedia()),
                                                      child: const Icon(HugeIcons.strokeRoundedPrevious, size: 20),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Button(
                                                      style: ButtonVariance.primary.withBorderRadius(borderRadius: const BorderRadius.all(Radius.circular(20))),
                                                      disableHoverEffect: true,
                                                      onPressed: () =>  provider.togglePlayPause(),
                                                      child: Icon(size: 20, provider.currentMedia != null && provider.isPlaying ? HugeIcons.strokeRoundedPause : HugeIcons.strokeRoundedPlay),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Button(
                                                      style: ButtonVariance.ghost,
                                                      onPressed: () => _throttler.run(() => provider.nextMedia()),
                                                      child: const Icon(HugeIcons.strokeRoundedNext, size: 20),
                                                    ),
                                                  ],
                                                ),
                                                ConstrainedBox(
                                                  constraints: const BoxConstraints(maxWidth: 600),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SizedBox(width: 60, child: Text(provider.currentMedia != null ? formatDuration(provider.position) : '00:00', textAlign: TextAlign.left)),
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
                                                      SizedBox(width: 60, child: Text(provider.currentMedia != null ? formatDuration(provider.duration) : '00:00', textAlign: TextAlign.right)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 16.0),
                                                    child: Wrap(
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
                                                                  constraints: const BoxConstraints(maxWidth: 900),
                                                                  child: AlertDialog(
                                                                    title: const Text('Efeitos'),
                                                                    content: Column(
                                                                      children: [
                                                                        const EffectKnobs(),
                                                                        const SizedBox(height: 100, child: Equalizer()),
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
                                                              return Listener(
                                                                onPointerSignal: (event) {
                                                                  if (event is PointerScrollEvent) {
                                                                    final dy = event.scrollDelta.dy;
                                                                    if (dy < 0) {
                                                                      provider.setVolume(provider.player.state.volume + 0.1);
                                                                    } else {
                                                                      provider.setVolume(provider.player.state.volume - 0.1);
                                                                    }
                                                                  }
                                                                },
                                                                child: SizedBox(
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
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _showContent,
                        builder: (context, showContent, child) {
                          return showContent
                              ? AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: isExpanded ? 1.0 : 0.0,
                                  curve: Curves.easeInOut,
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 90,
                                          width: 90,
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: image != null ? Image.memory(image, fit: BoxFit.cover) : const Center(child: Icon(HugeIcons.strokeRoundedMusicNote01, size: 60)),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(truncateText(title, 30), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15)),
                                              Text(truncateText(author, 30), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)).muted,
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : IgnorePointer(
                                  ignoring: true,
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: isExpanded ? 0.0 : 1.0,
                                    child: Row(
                                      children: [Text(truncateText(title, 40), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15))],
                                    ),
                                  ),
                                );
                        },
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
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
