import 'package:boel_downloader/services/enums.dart';
import 'package:boel_downloader/tools/url_lancher.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:boel_downloader/services/download_service.dart';
import 'package:flutter/material.dart' as mat;

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadService>(
      builder: (context, downloadService, child) {
        final downloads = downloadService.downloads;
        return Scaffold(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // const Text('Downloads', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    if (downloads.any((item) => item.status == DownloadStatus.completed))
                      Button(style: ButtonVariance.secondary, child: const Text('Limpar Concluídos'), onPressed: () => downloadService.clearCompletedDownloads()),
                  ],
                ),
              ),
              Expanded(
                child: downloads.isEmpty
                    ? const Center(child: Text('Nenhum download'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: downloads.length,
                        itemBuilder: (context, index) {
                          final download = downloads[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Button(
                                    // padding: EdgeInsets.all(0),
                                    style: ButtonVariance.outline,
                                    onPressed: () {
                                      UrlLancher.go(download.filePath!);
                                    },
                                    child: Stack(
                                      children: [
                                        IgnorePointer(
                                          ignoring: true,

                                          child: mat.ListTile(
                                            leading: ClipRRect(borderRadius: BorderRadiusGeometry.all(Radius.circular(6)), child: Image.network(download.imageUrl)),
                                            title: Text(download.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(download.author),

                                                Text(
                                                  download.status == DownloadStatus.completed
                                                      ? 'Concluído'
                                                      : download.status == DownloadStatus.failed
                                                      ? 'Falhou'
                                                      : download.status == DownloadStatus.queued
                                                      ? 'Na fila'
                                                      : 'Baixando (${(download.progress * 100).toStringAsFixed(0)}%)',
                                                ),
                                                if (download.status == DownloadStatus.downloading)
                                                  SizedBox(
                                                    height: 5,
                                                    width: double.infinity,
                                                    child: LinearProgressIndicator(value: download.progress),
                                                  ),
                                              ],
                                            ),
                                            trailing: null,
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 8,
                                          child: Icon(size: 26, download.format == MediaFormat.mp3 ? HugeIcons.strokeRoundedMusicNoteSquare02 : HugeIcons.strokeRoundedVideoReplay),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 50,
                                    height: 100,
                                    child: download.status == DownloadStatus.downloading
                                        ? Button(style: ButtonVariance.destructive, child: const Icon(HugeIcons.strokeRoundedCancel01), onPressed: () => downloadService.cancelDownload(download.id))
                                        : Button(
                                            style: ButtonVariance.outline,
                                            onPressed: () {
                                              String? getDirectoryPath(String filePath) {
                                                // Regex to match the directory path
                                                final regex = RegExp(r'^(.*[\\/])[^\\\\/]*$');
                                                final match = regex.firstMatch(filePath);
                                                return match?.group(1);
                                              }

                                              UrlLancher.go(getDirectoryPath(download.filePath!) ?? '');
                                            },
                                            child: Icon(HugeIcons.strokeRoundedFolder01),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
