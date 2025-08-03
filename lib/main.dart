import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:boel_downloader/go_router/router.dart';
import 'package:boel_downloader/pages/media_provider.dart';
// import 'package:boel_downloader/pages/player_page.dart';
import 'package:boel_downloader/services/download_service.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() async {
  await FFMpegHelper.instance.initialize();
  MediaKit.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DownloadService()),
        ChangeNotifierProvider(create: (_) => MediaProvider()),
      ],
      child: ShadcnApp.router(
        title: 'Baixador do BoelLabs',
        // home: MainWidget(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorSchemes.darkZinc(), radius: 0.5),
        routerConfig: AppRouter().router,
      ),
    ),
  );

  doWhenWindowReady(() {
    const initialSize = Size(800, 600);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}
