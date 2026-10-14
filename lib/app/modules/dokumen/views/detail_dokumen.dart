import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/dokumen/widget/dokumen_list.dart';
import 'package:siawi_app/utils/file_downloader.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DetailDokumen extends StatefulWidget {
  final DokumenList dokumen;

  DetailDokumen(this.dokumen, {super.key}) {
    dokumen.fileDokumen = Uri.encodeComponent(dokumen.fileDokumen);
  }

  @override
  State<DetailDokumen> createState() => _DetailDokumenState();
}

class _DetailDokumenState extends State<DetailDokumen> {
  final String baseUrl =
      'https://siawi.smkwisataindonesia.sch.id/storage/file_dokumen/';
  bool _isDownloading = false;

  Future<void> _downloadFile() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 12),
              Text('Sedang mengunduh dokumen...'),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }

    final fileUrl = '$baseUrl${widget.dokumen.fileDokumen}';
    final fileName = widget.dokumen.jenis_dokumen.isNotEmpty
        ? '${widget.dokumen.jenis_dokumen}.pdf'
        : 'Dokumen_${Uri.decodeComponent(widget.dokumen.fileDokumen)}';

    await FileDownloader.downloadFile(
      context: context,
      url: fileUrl,
      defaultFileName: fileName,
    );

    if (mounted) {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF4C3EC7),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.dokumen.jenis_dokumen.isNotEmpty
                  ? widget.dokumen.jenis_dokumen
                  : 'Detail Dokumen',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Text(
              'Pratinjau Berkas PDF',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          _isDownloading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  tooltip: 'Unduh Dokumen',
                  onPressed: _downloadFile,
                ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Image.asset(
                'assets/logo/logo-splash.png',
                width: 26,
                height: 26,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Header info bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 18,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.dokumen.jenis_dokumen,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: _isDownloading ? null : _downloadFile,
                  icon: _isDownloading
                      ? const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            color: Color(0xFF4C3EC7),
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 15),
                  label: Text(
                    _isDownloading ? "Mengunduh..." : "Unduh PDF",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4C3EC7),
                    backgroundColor: const Color(0xFFEEF2FF),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PDF Viewer
          Expanded(
            child: SfPdfViewer.network(
              '$baseUrl${widget.dokumen.fileDokumen}',
            ),
          ),
        ],
      ),
    );
  }
}
