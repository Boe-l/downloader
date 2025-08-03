import 'package:url_launcher/url_launcher.dart';

class UrlLancher {
  static Future<void> go(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
