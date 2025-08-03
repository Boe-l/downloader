import 'package:boel_downloader/pages/media_provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as mat;

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
          margin: EdgeInsets.all(16),
          // decoration: b,
          // color: Colors.gray[900],
          child: Card(
            child: Consumer<MediaProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Button(
                          style: ButtonVariance.primary,
                          onPressed: provider.togglePlayPause,
                          child: Icon(size: 20, provider.isPlaying ? HugeIcons.strokeRoundedPause : HugeIcons.strokeRoundedPlay),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Spacer(),
                            // Timeline
                            SizedBox(width: 60, child: Text(formatDuration(provider.position), textAlign: TextAlign.center)),
                            Flexible(
                              child: Slider(
                                value: SliderValue.single(provider.position.inSeconds.toDouble()),
                                max: provider.duration.inSeconds.toDouble() > 0 ? provider.duration.inSeconds.toDouble() : 1.0,
                                onChanged: (value) {
                                  provider.seek(Duration(seconds: value.value.toInt()));
                                },
                              ),
                            ),
                            SizedBox(width: 60, child: Text(formatDuration(provider.duration), textAlign: TextAlign.center)),

                            // Volume
                            Spacer(),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          child: SizedBox(
                            width: 100,
                            child: Slider(
                              value: SliderValue.single(provider.player.state.volume),
                              max: 100.0,
                              onChanged: (value) {
                                provider.setVolume(value.value);
                              },
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
          // Painel principal com sidebar, lista de mídia e informações
          Container(
            constraints: BoxConstraints(maxWidth: 300),
            height: double.infinity,
            child: Column(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Button(
                      style: ButtonVariance.menubar,
                      onPressed: () {
                        context.read<MediaProvider>().loadMediaFromFolder();
                      },
                      child: const Text('Abrir Pasta'),
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer<MediaProvider>(
                    builder: (context, provider, child) {
                      return ListView.builder(
                        itemCount: provider.mediaFiles.length,
                        itemBuilder: (context, index) {
                          final file = provider.mediaFiles[index];
                          return Button(
                            style: provider.currentIndex == index ? ButtonVariance.primary : ButtonVariance.menubar,
                            // selected: provider.currentIndex == index,
                            onPressed: () {
                              provider.setCurrentMedia(Media(file.path));
                            },

                            child: Text(file.path.split('\\').last, textAlign: TextAlign.start),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Column(children: [])),
          Expanded(child: Column(children: [])),
          // Expanded(
          //   child: OutlinedContainer(
          //     clipBehavior: Clip.antiAlias,
          //     child: ResizablePanel.horizontal(
          //       children: [
          //         // Sidebar (esquerda)
          //         ResizablePane.controlled(
          //           minSize: 100,
          //           collapsedSize: 40,
          //           controller: controller,
          //           child: AnimatedBuilder(
          //             animation: controller,
          //             builder: (context, child) {
          //               if (controller.collapsed) {
          //                 return const Center(child: RotatedBox(quarterTurns: -1, child: Text('Menu')));
          //               }
          //               return Column(
          //                 children: [
          //                   Padding(
          //                     padding: const EdgeInsets.all(16.0),
          //                     child: Button(
          //                       style: ButtonVariance.menubar,
          //                       onPressed: () {
          //                         context.read<MediaProvider>().loadMediaFromFolder();
          //                       },
          //                       child: const Text('Abrir Pasta'),
          //                     ),
          //                   ),
          //                   const Spacer(),
          //                 ],
          //               );
          //             },
          //           ),
          //         ),
          //         // Lista de mídia (centro)
          //         ResizablePane(
          //           initialSize: 300,
          //           child: Consumer<MediaProvider>(
          //             builder: (context, provider, child) {
          //               return ListView.builder(
          //                 itemCount: provider.mediaFiles.length,
          //                 itemBuilder: (context, index) {
          //                   final file = provider.mediaFiles[index];
          //                   return Button(
          //                     style: provider.currentIndex == index ? ButtonVariance.primary : ButtonVariance.menubar,
          //                     // selected: provider.currentIndex == index,
          //                     onPressed: () {
          //                       provider.setCurrentMedia(Media(file.path));
          //                     },

          //                     child: Text(file.path.split('/').last),
          //                   );
          //                 },
          //               );
          //             },
          //           ),
          //         ),
          //         // Informações da mídia (direita)
          //         ResizablePane.controlled(
          //           minSize: 100,
          //           collapsedSize: 40,
          //           controller: controller2,
          //           child: AnimatedBuilder(
          //             animation: controller2,
          //             builder: (context, child) {
          //               if (controller2.collapsed) {
          //                 return const Center(child: RotatedBox(quarterTurns: -1, child: Text('Info')));
          //               }
          //               return Consumer<MediaProvider>(
          //                 builder: (context, provider, child) {
          //                   return Center(
          //                     child: Column(
          //                       mainAxisAlignment: MainAxisAlignment.center,
          //                       children: [
          //                         Text(
          //                           provider.currentPlaylist != null ? provider.mediaFiles[provider.currentIndex].path.split('/').last : 'Nenhuma mídia selecionada',
          //                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //                         ),
          //                         const SizedBox(height: 16),
          //                         // Futuramente: Adicionar imagem, autor, etc.
          //                       ],
          //                     ),
          //                   );
          //                 },
          //               );
          //             },
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // // Playbar (inferior)
          // Container(
          //   height: 80,
          //   color: Colors.gray[900],
          //   child: Consumer<MediaProvider>(
          //     builder: (context, provider, child) {
          //       return Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Button(style: ButtonVariance.menubar, onPressed: provider.togglePlayPause, child: Icon(provider.isPlaying ? Icons.pause : Icons.play_arrow)),
          //           // Timeline
          //           Expanded(
          //             child: mat.Slider(
          //               value: provider.position.inSeconds.toDouble(),
          //               max: provider.duration.inSeconds.toDouble() > 0 ? provider.duration.inSeconds.toDouble() : 1.0,
          //               onChanged: (value) {
          //                 provider.seek(Duration(seconds: value.toInt()));
          //               },
          //             ),
          //           ),
          //           // Volume
          //           SizedBox(
          //             width: 100,
          //             child: mat.Slider(
          //               value: provider.player.state.volume,
          //               max: 100.0,
          //               onChanged: (value) {
          //                 provider.setVolume(value);
          //               },
          //             ),
          //           ),
          //         ],
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
