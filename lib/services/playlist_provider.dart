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
    _log.info('Added playlist: $name');
  }

  Future<void> removePlaylist(String name) async {
    playlists.removeWhere((p) => p.name == name);
    if (currentPlaylist?.name == name) {
      currentPlaylist = playlists.isNotEmpty ? playlists.first : null;
      if (currentPlaylist != null && currentPlaylist!.mediaFiles.isNotEmpty) {
        await _mediaProvider.play(currentPlaylist!.mediaFiles[0], isPaused: true);
      } else {
        await _mediaProvider.stop();
      }
    }
    await SharedPrefs().savePlaylists(playlists);
    _log.info('Removed playlist: $name');
  }

  void setCurrentPlaylist(String name) {
    currentPlaylist = playlists.firstWhere((p) => p.name == name, orElse: () => PlaylistModel(name: ''));
    if (currentPlaylist != null && currentPlaylist!.mediaFiles.isNotEmpty) {
      _mediaProvider.play(currentPlaylist!.mediaFiles[0], isPaused: true);
    }
    _log.info('Set current playlist: $name');
  }

  Future<void> addMediaToPlaylist(Media media, String playlistId) async {
    final playlist = playlists.firstWhere((p) => p.hash == playlistId, orElse: () => PlaylistModel(name: ''));
    if (playlist.name.isNotEmpty) {
      await playlist.addMedia(media);
      await SharedPrefs().savePlaylists(playlists);
      _log.info('Added media to playlist "$playlistId": ${media.title}');
    }
  }

  List<PlaylistModel> getAllPlaylists() => playlists;

  // Delegate to currentPlaylist
  Future<void> setCurrentMedia(Media media) async {
    if (currentPlaylist != null) {
      await currentPlaylist!.setCurrentMedia(media);
      if (currentPlaylist!.currentMedia != null) {
        await _mediaProvider.play(currentPlaylist!.currentMedia!, isPaused: false);
      }
    }
  }

  Future<void> nextMedia() async {
    if (currentPlaylist != null) {
      await currentPlaylist!.nextMedia();
      if (currentPlaylist!.currentMedia != null) {
        await _mediaProvider.play(currentPlaylist!.currentMedia!, isPaused: false);
      }
    }
  }

  Future<void> previousMedia() async {
    if (currentPlaylist != null) {
      await currentPlaylist!.previousMedia();
      if (currentPlaylist!.currentMedia != null) {
        await _mediaProvider.play(currentPlaylist!.currentMedia!, isPaused: false);
      }
    }
  }

  Future<void> setPlaylistMode(PlaylistMode mode) async {
    if (currentPlaylist != null) {
      await currentPlaylist!.setPlaylistMode(mode);
      await SharedPrefs().savePlaylists(playlists);
    }
  }

  // Getters for current playlist
  int get currentIndex => currentPlaylist?.currentIndex ?? 0;
  Media? get currentMedia => currentPlaylist?.currentMedia;
  PlaylistMode get playlistMode => currentPlaylist?.playlistMode ?? PlaylistMode.single;
  List<Media> get mediaFiles => currentPlaylist?.mediaFiles ?? [];
}
