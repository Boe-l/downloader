import 'package:boel_downloader/pages/file_path_widget.dart';
import 'package:boel_downloader/services/download_service.dart';
import 'package:boel_downloader/models/enums.dart';
import 'package:boel_downloader/services/shared_prefs.dart';
import 'package:boel_downloader/services/spotify_api.dart';
import 'package:boel_downloader/widgets/format_widget.dart';
import 'package:boel_downloader/widgets/toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final YoutubeExplode yt = YoutubeExplode();
  List<Video> _searchResults = [];
  bool _isLoading = false;
  final _youtubeUrlRegex = RegExp(r'^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/(watch\?v=|shorts\/)?[A-Za-z0-9_-]+');
  final _spotifyUrlRegex = RegExp(
    r'(https?:\/\/(open\.)?spotify\.com\/(intl-[a-zA-Z-]+\/)?(?:track|user|artist|album|playlist|episode|show)\/[a-zA-Z0-9]+(\?.*)?|spotify:(?:track|user|artist|album|playlist|episode|show):[a-zA-Z0-9]+(?:|:playlist:[a-zA-Z0-9]+)|https?:\/\/spotify\.link\/[a-zA-Z0-9]+)',
  );
  MediaFormat format = MediaFormat.mp4;

  @override
  void initState() {
    super.initState();
  }

  onInit() async {
    format = (await SharedPrefs().getLastFormat() == 'MP3') ? MediaFormat.mp3 : MediaFormat.mp4;
  }

  changeFormat(MediaFormat type) async {
    SharedPrefs().saveLastFormat(type == MediaFormat.mp3 ? "MP3" : "MP4");
    format = type;
  }

  void _handleSearch(String query) async {
    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      if (_youtubeUrlRegex.hasMatch(query)) {
        final videoId = VideoId.parseVideoId(query);
        if (videoId != null) {
          final video = await yt.videos.get(videoId);
          setState(() {
            _searchResults = [video];
          });
        }
      } else if (_spotifyUrlRegex.hasMatch(query)) {
        SpotifyMetadata metaData = await SpotifyApi.getData(query);
        final searchStream = yt.search.search('${metaData.title} ${metaData.artist}');
        final videos = await searchStream;
        final results = videos.take(10).toList();
        setState(() {
          _searchResults = results;
        });
      } else {
        // Busca por título
        final searchStream = yt.search.search(query);
        final videos = await searchStream;
        final results = videos.take(10).toList();
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      // Mostrar erro com toast
      if (mounted) {
        showToast(
          context: context,
          builder: ToastWarning(title: 'Erro ao baixar.', subtitle: e.toString()).show,
          location: ToastLocation.bottomRight,
        );
      }
      // showToast(context, title: const Text('Erro'), description: Text('Falha ao buscar: $e'), variant: ToastVariant.destructive);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    yt.close();
    _controller.dispose();
    super.dispose();
  }

  downloadVideo(video, MediaFormat format) {
    Provider.of<DownloadService>(context, listen: false).startDownload(video, context, format);
  }

  @override
  Widget build(BuildContext mainContext) {
    return Scaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 770),
              child: TextField(
                controller: _controller,
                placeholder: Text('Insira o termo de busca ou link.'),
                features: [
                  InputFeature.trailing(
                    Row(
                      children: [
                        Button(
                          style: ButtonVariance.ghost,
                          child: Icon(HugeIcons.strokeRoundedCopy02),
                          onPressed: () async {
                            final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                            if (clipboardData != null && clipboardData.text != null) {
                              _controller.text = clipboardData.text!;
                            }
                          },
                        ),
                        SizedBox(width: 2),
                        Button(style: ButtonVariance.ghost, child: Icon(HugeIcons.strokeRoundedSearch01), onPressed: () => _handleSearch(_controller.text)),
                      ],
                    ),
                  ),
                ],
                onSubmitted: _handleSearch,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(size: 32))
                : _searchResults.isEmpty
                ? const Center(child: Text('Nenhum resultado encontrado'))
                : ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(dragDevices: {PointerDeviceKind.mouse}, scrollbars: false),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 800),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final video = _searchResults[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Card(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Miniatura
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          video.thumbnails.mediumResUrl,
                                          width: 120,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(width: 120, height: 90, color: Colors.gray[300], child: const Icon(HugeIcons.strokeRoundedVideo01)),
                                        ),
                                      ),
                                      Positioned(
                                        right: 4,
                                        bottom: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4)),
                                          child: Text(
                                            formatDuration(video.duration!),
                                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  // Informações do vídeo
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          video.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          video.author,
                                          // style: TextStyle(color: Colors.gray[600], fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ).muted,
                                        Text(
                                          '${formatViewCount(video.engagement.viewCount)}${video.uploadDate != null ? ' - ${formatUploadDate(video.uploadDate!)}' : ''}',
                                          // style: TextStyle(color: Colors.gray[600], fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ).muted,
                                      ],
                                    ),
                                  ),

                                  Builder(
                                    builder: (context) {
                                      return PrimaryButton(
                                        onPressed: () {
                                          showPopover(
                                            context: context,
                                            alignment: Alignment.topCenter,
                                            offset: const Offset(0, 8),
                                            // Unless you have full opacity surface,
                                            // you should explicitly set the overlay barrier.
                                            overlayBarrier: OverlayBarrier(borderRadius: context.theme.borderRadiusLg),
                                            builder: (context) {
                                              return ModalContainer(
                                                child: SizedBox(
                                                  width: 300,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      const Text('Configurar Download').large().medium(),
                                                      const Text('Escolha o formato').muted(),

                                                      FormatWidget(onFormatChanged: (value) => changeFormat(value)),
                                                      const Text('Escolha onde salvar o arquivo').muted(),

                                                      FilePathWidget(),
                                                      PrimaryButton(
                                                        onPressed: () {
                                                          downloadVideo(video, format);
                                                          if (mounted) {
                                                            showToast(
                                                              context: mainContext,
                                                              builder: ToastWarning(title: 'Baixando Video...', subtitle: '"${video.title}"').show,
                                                              location: ToastLocation.bottomRight,
                                                            );
                                                          }
                                                          closeOverlay(context);
                                                        },
                                                        child: const Text('Continuar'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ).future.then((_) {});
                                        },
                                        child: const Text('Baixar'),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
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
  } else {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

String formatViewCount(int viewCount) {
  if (viewCount == 1) {
    return '1 Visualização';
  } else if (viewCount < 1000) {
    return '$viewCount Visualizações';
  } else if (viewCount < 1000000) {
    final viewsInK = (viewCount / 1000).floor();
    return '$viewsInK K Visualizações';
  } else if (viewCount < 1000000000) {
    final viewsInM = (viewCount / 1000000).floor();
    return '$viewsInM M Visualizações';
  } else {
    final viewsInB = (viewCount / 1000000000).floor();
    return '$viewsInB B Visualizações';
  }
}

String formatUploadDate(DateTime uploadDate) {
  final now = DateTime.now();
  final difference = now.difference(uploadDate);

  if (difference.inDays < 1) {
    final hours = difference.inHours;
    if (hours < 1) {
      return 'Há ${difference.inMinutes} minuto${difference.inMinutes == 1 ? '' : 's'}';
    }
    return 'Há $hours hora${hours == 1 ? '' : 's'}';
  } else if (difference.inDays < 30) {
    return 'Há ${difference.inDays} dia${difference.inDays == 1 ? '' : 's'}';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return 'Há $months mês${months == 1 ? '' : 'es'}';
  } else {
    final years = (difference.inDays / 365).floor();
    return 'Há $years ano${years == 1 ? '' : 's'}';
  }
}
