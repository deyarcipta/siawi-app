import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/dokumen/widget/dokumen_list.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class DetailDokumen extends StatelessWidget {
  final DokumenList dokumen;

  DetailDokumen(this.dokumen, {Key? key}) : super(key: key) {
    dokumen.fileDokumen = Uri.encodeComponent(dokumen.fileDokumen);
  }

  final String baseUrl =
      'https://siawi.smkwisataindonesia.sch.id/storage/file_dokumen/';

  /// Function untuk membuka PDF di browser (otomatis akan terunduh jika browser support)
  Future<void> _downloadFile() async {
    final url = Uri.parse('$baseUrl${dokumen.fileDokumen}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak dapat membuka URL: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'SI AWI',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Image.asset(
              'assets/logo/logo-splash.png',
              width: 30,
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: AppColors.fiveColor,
            height: size.height * 0.08,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  'Jenis Dokumen: ${dokumen.jenis_dokumen}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  onPressed: _downloadFile,
                  tooltip: 'Download Dokumen',
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SfPdfViewer.network(
                '$baseUrl${dokumen.fileDokumen}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
