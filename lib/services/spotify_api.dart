library;

import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyApi {
  static final _spotifyUrlRegex = RegExp(
      r'(https?:\/\/(open\.)?spotify\.com\/(intl-[a-zA-Z-]+\/)?(?:track|user|artist|album|playlist|episode|show)\/([a-zA-Z0-9]+)(\?.*)?|spotify:(?:track|user|artist|album|playlist|episode|show):([a-zA-Z0-9]+)(?:|:playlist:[a-zA-Z0-9]+)|https?:\/\/spotify\.link\/[a-zA-Z0-9]+)');

  static Future<SpotifyMetadata> getData(String link) async {
    if (!_spotifyUrlRegex.hasMatch(link)) throw 'Invalid Spotify link';
    final match = _spotifyUrlRegex.firstMatch(link);
    final trackId = match?.group(4) ?? match?.group(6);
    if (trackId == null) throw 'No track ID found';
    final embedUri = Uri.parse('https://open.spotify.com/embed/track/$trackId');

    final response = await http.get(embedUri);
    if (response.statusCode != 200) throw 'Failed to fetch metadata';

    // Extract __NEXT_DATA__ JSON from HTML
    final regex = RegExp(r'<script id="__NEXT_DATA__" type="application/json">([\s\S]*?)<\/script>');
    final matchJson = regex.firstMatch(response.body);
    if (matchJson == null || matchJson.group(1) == null) throw 'Failed to parse metadata';
    final jsonData = jsonDecode(matchJson.group(1)!);
    final entity = jsonData['props']['pageProps']['state']['data']['entity'];

    // Generate embed URL
    final embedUrl = 'https://open.spotify.com/embed/track/$trackId';

    return SpotifyMetadata.fromMap({
      ...entity,
      'html': '<iframe style="border-radius:12px" src="$embedUrl" width="100%" height="152" frameborder="0" allowfullscreen allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture" loading="lazy"></iframe>',
      'width': 456,
      'height': 152,
      'version': '1.0',
      'provider_name': 'Spotify',
      'provider_url': 'https://spotify.com',
      'type': 'rich',
    });
  }
}

class SpotifyMetadata {
  SpotifyMetadata({
    required this.html,
    required this.width,
    required this.height,
    required this.version,
    required this.providerName,
    required this.providerUrl,
    required this.type,
    required this.title,
    required this.artist,
    required this.releaseDate,
    required this.duration,
    required this.thumbnailUrl,
  });

  final String? html;
  final int? width;
  final int? height;
  final String? version;
  final String? providerName;
  final String? providerUrl;
  final String? type;
  final String? title;
  final String? artist;
  final String? releaseDate;
  final int? duration;
  final String? thumbnailUrl;

  factory SpotifyMetadata.fromMap(Map<String, dynamic> json) => SpotifyMetadata(
        html: json['html'],
        width: json['width'],
        height: json['height'],
        version: json['version'],
        providerName: json['provider_name'],
        providerUrl: json['provider_url'],
        type: json['type'],
        title: json['title'],
        artist: json['artists'] != null && json['artists'].isNotEmpty ? json['artists'][0]['name'] : null,
        releaseDate: json['releaseDate']?['isoString'],
        duration: json['duration'],
        thumbnailUrl: json['visualIdentity']?['image'] != null && json['visualIdentity']['image'].isNotEmpty
            ? json['visualIdentity']['image'][0]['url']
            : null,
      );

  Map<String, dynamic> toMap() => {
        'html': html,
        'width': width,
        'height': height,
        'version': version,
        'provider_name': providerName,
        'provider_url': providerUrl,
        'type': type,
        'title': title,
        'artist': artist,
        'releaseDate': releaseDate,
        'duration': duration,
        'thumbnailUrl': thumbnailUrl,
      };

  String toJson() => jsonEncode(toMap());
}