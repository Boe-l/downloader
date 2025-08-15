import 'dart:async';
import 'dart:typed_data';
import 'package:boel_downloader/models/playlists.dart';
import 'package:boel_downloader/services/files_provider.dart';
import 'package:logging/logging.dart';
import 'media_provider.dart';
import '../models/media.dart';
import 'shared_prefs.dart';

class PlaylistsHandler {
  static final Logger _log = Logger('PlaylistsHandler');
  final FilesHandler _filesHandler;
  late MediaProvider _mediaProvider;
  List<PlaylistModel> playlists = [];
  PlaylistModel? currentPlaylist;

  PlaylistsHandler({FilesHandler? filesHandler}) : _filesHandler = filesHandler ?? FilesHandler() {
    _initialize();
  }

  void setMediaProvider(MediaProvider mediaProvider) {
    _mediaProvider = mediaProvider;
  }

  Future<void> _initialize() async {
    await SharedPrefs().init();
    final savedPlaylists = await SharedPrefs().getPlaylists();
    if (savedPlaylists.isNotEmpty) {
      playlists = savedPlaylists;
      currentPlaylist = playlists.first;
    } else {
      playlists.add(PlaylistModel(name: 'Default Playlist'));
      currentPlaylist = playlists.first;
    }
    _log.info('Initialized with ${playlists.length} playlists.');
  }

  // Playlist management
  Future<void> addPlaylist(String name, {Uint8List? image, String? description}) async {
    final playlist = PlaylistModel(name: name, image: image, description: description);
    playlists.add(playlist);
    currentPlaylist ??= playlist;
    await SharedPrefs().savePlaylists(playlists);
    _mediaProvider.notify();
    _log.info('Added playlist: $name (hash: ${playlist.hash})');
  }

  Future<void> removePlaylist(String playlistId) async {
    final removedPlaylist = playlists.firstWhere(
      (p) => p.hash == playlistId,
      orElse: () => PlaylistModel(name: ''),
    );
    if (removedPlaylist.name.isEmpty) {
      _log.warning('Playlist with hash $playlistId not found.');
      return;
    }
    playlists.removeWhere((p) => p.hash == playlistId);
    if (currentPlaylist?.hash == playlistId) {
      currentPlaylist = playlists.isNotEmpty ? playlists.first : null;
      if (currentPlaylist != null && currentPlaylist!.mediaFiles.isNotEmpty) {
        await _mediaProvider.play(currentPlaylist!.mediaFiles[0], isPaused: true);
      } else {
        await _mediaProvider.stop();
      }
    }
    await SharedPrefs().savePlaylists(playlists);
    _mediaProvider.notify();
    _log.info('Removed playlist: ${removedPlaylist.name} (hash: $playlistId)');
  }

  Future<void> editPlaylist(String playlistId, {String? name, String? description, Uint8List? image}) async {
    final playlist = playlists.firstWhere(
      (p) => p.hash == playlistId,
      orElse: () => PlaylistModel(name: ''),
    );
    if (playlist.name.isEmpty) {
      _log.warning('Playlist with hash $playlistId not found for editing.');
      return;
    }
    if (name != null) playlist.name = name;
    if (description != null) playlist.description = description;
    if (image != null) playlist.image = image;
    await SharedPrefs().savePlaylists(playlists);
    _mediaProvider.notify();
    _log.info('Edited playlist: ${playlist.name} (hash: $playlistId)');
  }

  void setCurrentPlaylist(String playlistId) {
    final playlist = playlists.firstWhere(
      (p) => p.hash == playlistId,
      orElse: () => PlaylistModel(name: ''),
    );
    if (playlist.name.isEmpty) {
      _log.warning('Playlist with hash $playlistId not found.');
      return;
    }
    currentPlaylist = playlist;
    if (currentPlaylist != null && currentPlaylist!.mediaFiles.isNotEmpty) {
      _mediaProvider.play(currentPlaylist!.mediaFiles[0], isPaused: true);
    }
    _mediaProvider.notify();
    _log.info('Set current playlist: ${playlist.name} (hash: $playlistId)');
  }

  Future<void> addMediaToPlaylist(Media media, String playlistId) async {
    final playlist = playlists.firstWhere(
      (p) => p.hash == playlistId,
      orElse: () => PlaylistModel(name: ''),
    );
    if (playlist.name.isEmpty) {
      _log.warning('Playlist with hash $playlistId not found.');
      return;
    }
    // Evitar duplicatas
    if (playlist.mediaFiles.any((m) => m.file.path == media.file.path)) {
      _log.info('Media ${media.title} already exists in playlist ${playlist.name}.');
      return;
    }
    await playlist.addMedia(media);
    await SharedPrefs().savePlaylists(playlists);
    _mediaProvider.notify();
    _log.info('Added media to playlist "${playlist.name}" (hash: $playlistId): ${media.title}');
  }

  Future<void> removeMediaFromPlaylist(Media media, String playlistId) async {
    final playlist = playlists.firstWhere(
      (p) => p.hash == playlistId,
      orElse: () => PlaylistModel(name: ''),
    );
    if (playlist.name.isEmpty) {
      _log.warning('Playlist with hash $playlistId not found.');
      return;
    }
    final wasCurrentMedia = playlist.currentMedia?.file.path == media.file.path;
    playlist.mediaFiles.removeWhere((m) => m.file.path == media.file.path);
    if (wasCurrentMedia) {
      if (playlist.mediaFiles.isNotEmpty) {
        await playlist.setCurrentMedia(playlist.mediaFiles[0]);
        await _mediaProvider.play(playlist.mediaFiles[0], isPaused: true);
      } else {
        await _mediaProvider.stop();
      }
    }
    await SharedPrefs().savePlaylists(playlists);
    _mediaProvider.notify();
    _log.info('Removed media from playlist "${playlist.name}" (hash: $playlistId): ${media.title}');
  }

  Future<void> updatePlaylistOrder(List<String> playlistIds) async {
    final newPlaylists = <PlaylistModel>[];
    for (var id in playlistIds) {
      final playlist = playlists.firstWhere(
        (p) => p.hash == id,
        orElse: () => PlaylistModel(name: ''),
      );
      if (playlist.name.isNotEmpty) {
        newPlaylists.add(playlist);
      }
    }
    if (newPlaylists.length != playlists.length) {
      _log.warning('Some playlist IDs not found during reordering: $playlistIds');
    }
    playlists = newPlaylists;
    await SharedPrefs().savePlaylists(playlists);
    _mediaProvider.notify();
    _log.info('Updated playlist order: ${playlists.map((p) => p.name).toList()}');
  }

  List<PlaylistModel> getAllPlaylists() => playlists;

  // Delegate to currentPlaylist
  Future<void> setCurrentMedia(Media media) async {
    if (currentPlaylist != null) {
      await currentPlaylist!.setCurrentMedia(media);
      if (currentPlaylist!.currentMedia != null) {
        await _mediaProvider.play(currentPlaylist!.currentMedia!, isPaused: false);
      }
      _mediaProvider.notify();
    }
  }

  Future<void> nextMedia() async {
    if (currentPlaylist != null) {
      await currentPlaylist!.nextMedia();
      if (currentPlaylist!.currentMedia != null) {
        await _mediaProvider.play(currentPlaylist!.currentMedia!, isPaused: false);
      }
      _mediaProvider.notify();
    }
  }

  Future<void> previousMedia() async {
    if (currentPlaylist != null) {
      await currentPlaylist!.previousMedia();
      if (currentPlaylist!.currentMedia != null) {
        await _mediaProvider.play(currentPlaylist!.currentMedia!, isPaused: false);
      }
      _mediaProvider.notify();
    }
  }

  Future<void> setPlaylistMode(PlaylistMode mode) async {
    if (currentPlaylist != null) {
      await currentPlaylist!.setPlaylistMode(mode);
      await SharedPrefs().savePlaylists(playlists);
      _mediaProvider.notify();
    }
  }

  // Getters for current playlist
  int get currentIndex => currentPlaylist?.currentIndex ?? 0;
  Media? get currentMedia => currentPlaylist?.currentMedia;
  PlaylistMode get playlistMode => currentPlaylist?.playlistMode ?? PlaylistMode.single;
  List<Media> get mediaFiles => currentPlaylist?.mediaFiles ?? [];
}