import 'package:boel_downloader/pages/equalizer.dart';
import 'package:boel_downloader/services/media_provider.dart';
import 'package:boel_downloader/services/playlist_provider.dart';
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
  final Throttler buttonThrottler = Throttler(milliseconds: 1200);
  final Throttler sliderThrottler = Throttler(milliseconds: 200);
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
                builder: (context, mediaProvider, child) {
                  final title = mediaProvider.currentMedia?.title ?? '';
                  final author = mediaProvider.currentMedia?.artist ?? '';
                  final image = mediaProvider.currentMedia?.image;
                  return Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => buttonThrottler.run(() {
                              switchHeight();
                            }),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ValueListenableBuilder<bool>(
                                      valueListenable: _isExpanded,
                                      builder: (context, value, child) {
                                        return AnimatedRotation(
                                          turns: !value ? 0.5 : 0.0, // Rotate 180 degrees (0.5 turns) when expanded
                                          duration: const Duration(milliseconds: 300), // Smooth rotation over 300ms
                                          curve: Curves.easeInOut, // Smooth easing for natural feel
                                          child: const Icon(HugeIcons.strokeRoundedArrowDown01, size: 20),
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
                                                      onPressed: () => buttonThrottler.run(() => mediaProvider.previousMedia()),
                                                      child: const Icon(HugeIcons.strokeRoundedPrevious, size: 20),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Button(
                                                      style: ButtonVariance.primary.withBorderRadius(borderRadius: const BorderRadius.all(Radius.circular(20))),
                                                      disableHoverEffect: true,
                                                      onPressed: () => mediaProvider.togglePlayPause(),
                                                      child: Icon(size: 20, mediaProvider.currentMedia != null && mediaProvider.isPlaying ? HugeIcons.strokeRoundedPause : HugeIcons.strokeRoundedPlay),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Button(
                                                      style: ButtonVariance.ghost,
                                                      onPressed: () => buttonThrottler.run(() => mediaProvider.nextMedia()),
                                                      child: const Icon(HugeIcons.strokeRoundedNext, size: 20),
                                                    ),
                                                  ],
                                                ),
                                                ConstrainedBox(
                                                  constraints: const BoxConstraints(maxWidth: 500),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        width: 80,
                                                        child: Text(mediaProvider.currentMedia != null ? formatDuration(mediaProvider.position) : '00:00', textAlign: TextAlign.left),
                                                      ),
                                                      Expanded(
                                                        child: Slider(
                                                          value: SliderValue.single(mediaProvider.currentMedia != null ? mediaProvider.position.inSeconds.toDouble() : 0.0),
                                                          max: mediaProvider.currentMedia != null && mediaProvider.duration.inSeconds > 0 ? mediaProvider.duration.inSeconds.toDouble() : 1.0,
                                                          onChanged: mediaProvider.currentMedia != null
                                                              ? (value) {
                                                                  // if (mediaProvider.currentMedia!.duration < Duration(minutes: 10)) {
                                                                    sliderThrottler.run(() => mediaProvider.seek(Duration(seconds: value.value.toInt())));
                                                                  // }
                                                                }
                                                              : null,
                                                          // onChangeEnd: mediaProvider.currentMedia != null
                                                          //     ? (value) {
                                                          //         mediaProvider.seek(Duration(seconds: value.value.toInt()));
                                                          //       }
                                                          //     : null,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 80,
                                                        height: 20,
                                                        child: Text(mediaProvider.currentMedia != null ? formatDuration(mediaProvider.duration) : '00:00', textAlign: TextAlign.right),
                                                      ),
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
                                                                    value: SliderValue.single(mediaProvider.currentMedia != null ? provider.player.state.volume : 1.0),
                                                                    max: 1.0,
                                                                    onChanged: mediaProvider.currentMedia != null
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
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0),
                                          child: SizedBox(
                                            height: 60,
                                            width: 60,
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                                              child: MouseRegion(
                                                cursor: SystemMouseCursors.click,
                                                child: image != null ? Image.memory(image, fit: BoxFit.cover) : const Center(child: Icon(HugeIcons.strokeRoundedMusicNote01, size: 60)),
                                              ),
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
                              : AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: isExpanded ? 0.0 : 1.0,
                                  child: GestureDetector(
                                    onTap: () => buttonThrottler.run(() {
                                      switchHeight();
                                    }),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Row(
                                        children: [
                                          SizedBox(width: 72),
                                          Expanded(
                                            child: Text(truncateText(title, 40), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15)),
                                          ),
                                        ],
                                      ),
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
