import 'dart:async';
import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:boel_downloader/models/media.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'shared_prefs.dart';

class FilesHandler {
  List<Media> mediaList = [];
  List<StreamSubscription<FileSystemEvent>?> folderWatchers = [];
  static final Logger _log = Logger('FilesHandler');
  Function()? _onMediaUpdated; // Callback to notify MediaProvider

  void setOnMediaUpdated(Function() callback) {
    _onMediaUpdated = callback;
  }

  Future<void> loadMediaFromFolders({List<String>? folderPaths, bool isInit = false}) async {
    await _cancelWatchers();
    mediaList.clear();

    final paths = folderPaths ?? await SharedPrefs().getPaths();
    if (paths.isEmpty && !isInit) {
      _log.info('No folder paths provided or saved in SharedPrefs.');
      return;
    }

    for (var folderPath in paths) {
      await _loadMediaFromSingleFolder(folderPath);
    }

    mediaList = mediaList.toSet().toList();
    _onMediaUpdated?.call(); // Notify MediaProvider
    _log.info('Loaded ${mediaList.length} media files');
  }

  Future<void> _loadMediaFromSingleFolder(String folderPath) async {
    final dir = Directory(folderPath);
    if (!dir.existsSync()) {
      _log.warning('Folder does not exist: $folderPath');
      return;
    }

    final mediaFutures = dir.listSync().where((file) => file is File && _isMediaFile(file.path)).map((file) async {
      final metadata = readMetadata(file as File, getImage: true);
      final title = metadata.title ?? path.basenameWithoutExtension(file.path);
      final author = metadata.artist ?? 'Artista desconhecido.';
      final duration = metadata.duration ?? Duration.zero;
      final imageBytes = metadata.pictures.isNotEmpty ? metadata.pictures[0].bytes : null;

      return Media(File(file.path), title: title, image: imageBytes, artist: author, duration: duration);
    }).toList();

    final newMedia = await Future.wait(mediaFutures);
    mediaList.addAll(newMedia);
    _startFolderWatcher(folderPath);
  }

  bool _isMediaFile(String filePath) {
    final supportedExtensions = ['.mp3', '.wav', '.ogg'];
    return supportedExtensions.any((ext) => filePath.toLowerCase().endsWith(ext));
  }

  void _startFolderWatcher(String folderPath) {
    final dir = Directory(folderPath);
    if (!dir.existsSync()) {
      _log.warning('Cannot watch non-existent folder: $folderPath');
      return;
    }

    final watcher = dir.watch(events: FileSystemEvent.all).listen((event) async {
      if (event is FileSystemCreateEvent || event is FileSystemModifyEvent || event is FileSystemDeleteEvent) {
        if (_isMediaFile(event.path)) {
          final mediaFutures = dir.listSync().where((file) => file is File && _isMediaFile(file.path)).map((file) async {
            final metadata = readMetadata(file as File, getImage: true);
            final title = metadata.title ?? path.basenameWithoutExtension(file.path);
            final author = metadata.artist ?? 'Artista desconhecido.';
            final imageBytes = metadata.pictures.isNotEmpty ? metadata.pictures[0].bytes : null;
            final duration = metadata.duration ?? Duration.zero;

            return Media(File(file.path), title: title, image: imageBytes, artist: author, duration: duration);
          }).toList();

          final newMedia = await Future.wait(mediaFutures);
          mediaList.removeWhere((m) => m.file.path.startsWith(folderPath));
          mediaList.addAll(newMedia);
          mediaList = mediaList.toSet().toList();
          _onMediaUpdated?.call(); // Notify MediaProvider
        }
      }
    });

    folderWatchers.add(watcher);
  }

  Future<void> _cancelWatchers() async {
    for (var watcher in folderWatchers) {
      await watcher?.cancel();
    }
    folderWatchers.clear();
  }

  Future<void> addFolderPath() async {
    final folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath == null) {
      _log.info('No folder selected by user.');
      return;
    }

    final paths = await SharedPrefs().getPaths();
    if (!paths.contains(folderPath)) {
      paths.add(folderPath);
      await SharedPrefs().savePaths(paths);
      await _loadMediaFromSingleFolder(folderPath);
      mediaList = mediaList.toSet().toList();
      _log.info('Added folder path: $folderPath');
      _onMediaUpdated?.call(); // Notify MediaProvider
    } else {
      _log.info('Folder path already exists: $folderPath');
    }
  }

  Future<void> removeFolderPath(String folderPath) async {
    final paths = await SharedPrefs().getPaths();
    if (paths.contains(folderPath)) {
      paths.remove(folderPath);
      await SharedPrefs().savePaths(paths);

      final watcherIndex = folderWatchers.indexWhere((w) => w != null && w.toString().contains(folderPath));
      if (watcherIndex != -1) {
        await folderWatchers[watcherIndex]?.cancel();
        folderWatchers.removeAt(watcherIndex);
      }

      mediaList.removeWhere((m) => m.file.path.startsWith(folderPath));
      _log.info('Removed folder path: $folderPath');
      _onMediaUpdated?.call(); // Notify MediaProvider
    } else {
      _log.info('Folder path not found: $folderPath');
    }
  }

  Future<List<String>> listFolderPaths() async {
    return await SharedPrefs().getPaths();
  }

  void addMedia(Media media) {
    mediaList.add(media);
    mediaList = mediaList.toSet().toList();
    _onMediaUpdated?.call(); // Notify MediaProvider
  }

  Future<void> dispose() async {
    await _cancelWatchers();
  }
}