import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:logging/logging.dart';
import '../models/media.dart';

enum PlaylistMode { none, single, loop, shuffle, repeat }

class PlaylistModel {
  static final Logger _log = Logger('PlaylistModel');
  String name;
  final String hash;
  Uint8List? image;
  String? description;
  List<Media> mediaFiles;
  int _currentIndex = 0;
  PlaylistMode _playlistMode = PlaylistMode.single;
  List<int> _shuffledIndices = [];

  PlaylistModel({
    required this.name,
    this.image,
    this.description,
    List<Media>? mediaFiles,
  })  : hash = name.hashCode.toString(),
        mediaFiles = mediaFiles ?? [] {
    _updateShuffledIndices();
  }

  int get currentIndex => _currentIndex;
  Media? get currentMedia => _currentIndex >= 0 && _currentIndex < mediaFiles.length ? mediaFiles[_currentIndex] : null;
  PlaylistMode get playlistMode => _playlistMode;

  Future<void> setCurrentMedia(Media media) async {
    _currentIndex = mediaFiles.indexWhere((m) => m.file.path == media.file.path);
    if (_currentIndex == -1) {
      await addMedia(media);
      _currentIndex = mediaFiles.length - 1;
    }
    _updateShuffledIndices();
    _log.info('Set current media in playlist "$name" (hash: $hash): ${media.title}');
  }

  Future<void> addMedia(Media media) async {
    if (!mediaFiles.any((m) => m.file.path == media.file.path)) { // Deduplicate
      mediaFiles.add(media);
      _updateShuffledIndices();
      _log.info('Added media to playlist "$name" (hash: $hash): ${media.title}');
    } else {
      _log.info('Media already exists in playlist "$name" (hash: $hash): ${media.title}');
    }
  }

  Future<void> nextMedia() async {
    if (mediaFiles.isEmpty) return;
    int newIndex;
    switch (_playlistMode) {
      case PlaylistMode.none:
        return;
      case PlaylistMode.single:
      case PlaylistMode.loop:
        newIndex = (_currentIndex + 1) % mediaFiles.length;
        break;
      case PlaylistMode.shuffle:
        final currentShuffleIndex = _shuffledIndices.indexOf(_currentIndex);
        final nextShuffleIndex = (currentShuffleIndex + 1) % _shuffledIndices.length;
        newIndex = _shuffledIndices[nextShuffleIndex];
        break;
      case PlaylistMode.repeat:
        newIndex = _currentIndex;
        break;
    }

    if (newIndex != _currentIndex || _playlistMode == PlaylistMode.repeat) {
      _currentIndex = newIndex;
      _log.info('Moved to next media in playlist "$name" (hash: $hash): ${currentMedia?.title}');
    }
  }

  Future<void> previousMedia() async {
    if (mediaFiles.isEmpty) return;
    int newIndex;
    switch (_playlistMode) {
      case PlaylistMode.none:
        return;
      case PlaylistMode.single:
      case PlaylistMode.loop:
        newIndex = (_currentIndex - 1) >= 0 ? _currentIndex - 1 : mediaFiles.length - 1;
        break;
      case PlaylistMode.shuffle:
        final currentShuffleIndex = _shuffledIndices.indexOf(_currentIndex);
        final prevShuffleIndex = (currentShuffleIndex - 1) >= 0 ? currentShuffleIndex - 1 : _shuffledIndices.length - 1;
        newIndex = _shuffledIndices[prevShuffleIndex];
        break;
      case PlaylistMode.repeat:
        newIndex = _currentIndex;
        break;
    }

    if (newIndex != _currentIndex || _playlistMode == PlaylistMode.repeat) {
      _currentIndex = newIndex;
      _log.info('Moved to previous media in playlist "$name" (hash: $hash): ${currentMedia?.title}');
    }
  }

  Future<void> setPlaylistMode(PlaylistMode mode) async {
    _playlistMode = mode;
    if (mode == PlaylistMode.shuffle) {
      _updateShuffledIndices();
    }
    _log.info('Set playlist mode for "$name" (hash: $hash): $mode');
  }

  void _updateShuffledIndices() {
    _shuffledIndices = List.generate(mediaFiles.length, (index) => index)..shuffle(Random());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistModel && runtimeType == other.runtimeType && hash == other.hash;

  @override
  int get hashCode => hash.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hash': hash,
      'image': image != null ? base64Encode(image!) : null,
      'description': description,
      'mediaFiles': mediaFiles.map((m) => m.file.path).toList(),
      'currentIndex': _currentIndex,
      'playlistMode': _playlistMode.toString(),
      'shuffledIndices': _shuffledIndices,
    };
  }

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    final playlist = PlaylistModel(
      name: json['name'] ?? 'Unnamed Playlist',
      image: json['image'] != null ? base64Decode(json['image']) : null,
      description: json['description'],
    );
    playlist._currentIndex = json['currentIndex'] ?? 0;
    playlist._playlistMode = PlaylistMode.values.firstWhere(
      (mode) => mode.toString() == json['playlistMode'],
      orElse: () => PlaylistMode.single,
    );
    playlist._shuffledIndices = List<int>.from(json['shuffledIndices'] ?? []);
    return playlist;
  }
}