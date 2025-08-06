import 'dart:io';
import 'package:boel_downloader/models/enums.dart';
import 'package:boel_downloader/models/metadata_ffmpeg.dart';
import 'package:boel_downloader/services/shared_prefs.dart';
import 'package:boel_downloader/widgets/toast.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';
// import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadItem {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final DownloadStatus status;
  final double progress; // 0.0 a 1.0
  final String? filePath;
  final MediaFormat format;

  DownloadItem({required this.id, required this.format, required this.imageUrl, required this.title, required this.author, this.status = DownloadStatus.queued, this.progress = 0.0, this.filePath});

  DownloadItem copyWith({String? id, String? title, String? author, DownloadStatus? status, double? progress, String? filePath, String? imageUrl, MediaFormat? format}) {
    return DownloadItem(
      format: format ?? this.format,
      imageUrl: imageUrl ?? this.imageUrl,
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      filePath: filePath ?? this.filePath,
    );
  }
}

class DownloadService with ChangeNotifier {
  final YoutubeExplode _yt = YoutubeExplode();
  final List<DownloadItem> _downloads = [];
  final FFMpegHelper _ffmpeg = FFMpegHelper.instance;
  double _ffmpegDownloadProgress = 0.0;

  List<DownloadItem> get downloads => List.unmodifiable(_downloads);
  double get ffmpegDownloadProgress => _ffmpegDownloadProgress;

  Future<void> _checkFFmpegSetup(BuildContext context) async {
    if (await _ffmpeg.isFFMpegPresent() || _ffmpegDownloadProgress >= 1.0) {
      return; // FFmpeg já está configurado
    }
    if (context.mounted) {
      showToast(
        context: context,
        builder: ToastWarning(title: 'Configurando FFmpeg...', subtitle: '"Download em andamento..."', button: false).show,
        location: ToastLocation.bottomRight,
      );
    }
    if (Platform.isWindows) {
      bool success = await _ffmpeg.setupFFMpegOnWindows(
        onProgress: (FFMpegProgress progress) {
          _ffmpegDownloadProgress = progress.downloaded / (progress.fileSize != 0 ? progress.fileSize : 1);
          notifyListeners();
        },
      );

      if (!success) {
        throw Exception('Falha ao configurar FFmpeg');
      }

      _ffmpegDownloadProgress = 1.0;
      if (context.mounted) {
        showToast(
          context: context,
          builder: ToastWarning(title: 'Configurando FFmpeg...', subtitle: '"Download concluido."', button: false).show,
          location: ToastLocation.bottomRight,
        );
        notifyListeners();
      }
    }
  }

  Future<void> startDownload(Video video, BuildContext context, MediaFormat type) async {
    String? savedPath = await SharedPrefs().getPath();
    Directory directory = Directory(savedPath ?? (await getDownloadsDirectory())!.path);
    // Only check FFmpeg setup for downloads

    if (context.mounted) {
      await _checkFFmpegSetup(context);
    }
    // Save the selected format to SharedPrefs
    await SharedPrefs().saveLastFormat(type == MediaFormat.mp3 ? 'MP3' : 'MP4');
    final downloadItem = DownloadItem(id: video.id.value, title: video.title, author: video.author, imageUrl: video.thumbnails.mediumResUrl, format: type);
    _downloads.add(downloadItem);
    notifyListeners();

    try {
      // Obter o manifesto do vídeo
      final manifest = await _yt.videos.streamsClient.getManifest(video.id);
      final audioStreams = manifest.audioOnly.sortByBitrate();

      if (audioStreams.isEmpty) {
        throw Exception('Nenhum stream de áudio disponível');
      }

      // Definir o diretório de downloads
      final safeTitle = video.title.replaceAll(RegExp(r'[^\w\s-]', unicode: true), '');
      final outputExtension = type == MediaFormat.mp3 ? '.mp3' : '.mp4';
      final outputPath = '${directory.path}/$safeTitle$outputExtension';

      // Baixar stream de áudio
      final audioStreamInfo = audioStreams.first; // Melhor qualidade de áudio
      final tempAudioPath = '${directory.path}/${video.id.value}_audio_temp.m4a';
      await _downloadStream(video, audioStreamInfo, tempAudioPath, DownloadStatus.downloading, type);

      if (type == MediaFormat.mp3) {
        // Converter o arquivo de áudio para MP3 verdadeiro
        final thumbnailResponse = await http.get(Uri.parse(video.thumbnails.mediumResUrl));
        if (thumbnailResponse.statusCode != 200) {
          throw Exception('Failed to download thumbnail');
        }
        final thumbnailBytes = thumbnailResponse.bodyBytes;
        final metadataArg = AddMetadataAndCoverArgument(
          metadata: {
            'title': video.title,
            'artist': video.author,
            'album': '', // Empty string is fine, but avoid empty keys
            'year': '',
            'genre': 'Music', // Added a default genre to avoid empty metadata
          },
          coverImageBytes: thumbnailBytes,
          imageFormat: 'jpg',
          useId3v2Version3: true,
          writeId3v1: true,
        );
        final cliCommand = FFMpegCommand(
          inputs: [FFMpegInput.asset(tempAudioPath), ...metadataArg.additionalInputs],
          args: [const CopyVideoCodecArgument(), const AudioBitrateArgument(192000), metadataArg, const OverwriteArgument()],

          outputFilepath: outputPath,
        );

        await _ffmpeg.runAsync(
          cliCommand,
          statisticsCallback: (Statistics statistics) {},
          onComplete: (File? outputFile) async {
            if (outputFile == null) {
              throw Exception('Falha ao converter áudio para MP3');
            }
            // // Limpar arquivo temporário
            // updateMetadata(outputFile, (metadata) {
            //   metadata.setTitle(video.title);
            //   metadata.setArtist(video.author);
            //   // metadata.setAlbum(video.);
            //   metadata.setTrackNumber(1);
            //   // metadata.setYear(DateTime(2014));
            //   // metadata.setLyrics("I'm singing");
            //   metadata.setGenres(["Baixador do Boel"]);
            //   metadata.setPictures([Picture(thumbnailBytes, "image/jpeg", PictureType.coverFront)]);
            // });

            await File(tempAudioPath).delete();
            if (context.mounted) {
              showToast(
                context: context,
                builder: ToastWarning(title: 'Download finalizado.', subtitle: '"${video.title}"', button: false).show,
                location: ToastLocation.bottomRight,
              );
            }
            // Atualizar status para concluído
            final index = _downloads.indexWhere((item) => item.id == video.id.value);
            if (index != -1) {
              _downloads[index] = _downloads[index].copyWith(status: DownloadStatus.completed, progress: 1.0, filePath: outputPath);
              notifyListeners();
            }
          },
        );
      } else {
        // Para MP4, baixar vídeo e combinar com áudio
        final videoStreams = manifest.videoOnly.sortByVideoQuality();
        if (videoStreams.isEmpty) {
          throw Exception('Nenhum stream de vídeo disponível');
        }

        // Baixar stream de vídeo
        final videoStreamInfo = videoStreams.first; // Melhor qualidade de vídeo
        final tempVideoPath = '${directory.path}/${video.id.value}_video_temp.mp4';
        final videoFilePath = await _downloadStream(video, videoStreamInfo, tempVideoPath, DownloadStatus.downloading, type);

        // Atualizar status para combinando
        final index = _downloads.indexWhere((item) => item.id == video.id.value);
        if (index != -1) {
          _downloads[index] = _downloads[index].copyWith(status: DownloadStatus.combining, progress: 0.9);
          notifyListeners();
        }

        // Combinar vídeo e áudio com FFmpeg
        final cliCommand = FFMpegCommand(
          inputs: [FFMpegInput.asset(videoFilePath), FFMpegInput.asset(tempAudioPath)],
          args: [const CopyVideoCodecArgument(), const CopyAudioCodecArgument(), const OverwriteArgument()],
          outputFilepath: outputPath,
        );

        await _ffmpeg.runAsync(
          cliCommand,
          statisticsCallback: (Statistics statistics) {},
          onComplete: (File? outputFile) async {
            if (outputFile == null) {
              throw Exception('Falha ao combinar vídeo e áudio');
            }
            showToast(
              context: context,
              builder: ToastWarning(title: 'Download finalizado.', subtitle: '"${video.title}"', button: false).show,
              location: ToastLocation.bottomRight,
            );
            // Limpar arquivos temporários
            await Future.delayed(Duration(milliseconds: 1000));
            await File(videoFilePath).delete();
            await File(tempAudioPath).delete();
            // Atualizar status para concluído
            if (index != -1) {
              _downloads[index] = _downloads[index].copyWith(status: DownloadStatus.completed, progress: 1.0, filePath: outputPath);
              notifyListeners();
            }
          },
        );
      }
    } catch (e) {
      // Atualizar status para falha
      final index = _downloads.indexWhere((item) => item.id == video.id.value);
      if (index != -1) {
        _downloads[index] = _downloads[index].copyWith(status: DownloadStatus.failed, progress: 0.0);
        notifyListeners();
      }
    }
  }

  Future<String> _downloadStream(Video video, StreamInfo streamInfo, String filePath, DownloadStatus status, MediaFormat type) async {
    final file = File(filePath);
    final stream = _yt.videos.streamsClient.get(streamInfo);
    final fileSink = file.openWrite();

    final contentLength = streamInfo.size.totalBytes;
    var downloadedBytes = 0;

    await for (final chunk in stream) {
      downloadedBytes += chunk.length;
      final progress = downloadedBytes / contentLength;
      final index = _downloads.indexWhere((item) => item.id == video.id.value);
      if (index != -1) {
        _downloads[index] = _downloads[index].copyWith(
          status: status,
          progress: progress * (type == MediaFormat.mp3 ? 1.0 : 0.9), // 100% for MP3, 90% for MP4
        );
        notifyListeners();
      }
      fileSink.add(chunk);
    }

    await fileSink.close();
    return filePath;
  }

  void cancelDownload(String id) {
    final index = _downloads.indexWhere((item) => item.id == id);
    if (index != -1) {
      _downloads[index] = _downloads[index].copyWith(status: DownloadStatus.failed, progress: 0.0);
      notifyListeners();
    }
  }

  void clearCompletedDownloads() {
    _downloads.removeWhere((item) => item.status == DownloadStatus.completed);
    notifyListeners();
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  Future<bool> pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      await SharedPrefs().savePath(selectedDirectory);
      return true;
    } else {
      return false;
    }
  }
}
