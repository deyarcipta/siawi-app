import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/modul/widget/modul_list.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ModulView extends StatefulWidget {
  final ModulItem modul;
  final String? namaMapel;

  const ModulView(this.modul, {super.key, this.namaMapel});

  @override
  State<ModulView> createState() => _ModulViewState();
}

class _ModulViewState extends State<ModulView> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _hasError = false;
  String _errorMessage = '';

  final String _baseUrl =
      'https://siawi.smkwisataindonesia.sch.id/storage/file_modul/';

  @override
  Widget build(BuildContext context) {
    final fileName = widget.modul.fileModul;
    final encodedFile = Uri.encodeComponent(fileName);
    final fullUrl = '$_baseUrl$encodedFile';

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
              widget.modul.namaModul.isNotEmpty
                  ? widget.modul.namaModul
                  : 'Modul Pembelajaran',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.namaMapel ?? 'Pratinjau Modul Digital',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
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
        children: [
          // Sub Bar Informasi File (Mode Baca)
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.modul.namaModul,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.namaMapel != null)
                        Text(
                          widget.namaMapel!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        size: 13,
                        color: Color(0xFF64748B),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Mode Baca",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Area PDF Viewer atau State Error
          Expanded(
            child: _hasError
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              size: 40,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Gagal Membuka File Modul',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage.isNotEmpty
                                ? _errorMessage
                                : 'File modul belum tersedia di server atau format berkas tidak didukung.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _hasError = false;
                                _errorMessage = '';
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4C3EC7),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SfPdfViewer.network(
                    fullUrl,
                    controller: _pdfViewerController,
                    canShowScrollHead: true,
                    canShowScrollStatus: true,
                    onDocumentLoadFailed:
                        (PdfDocumentLoadFailedDetails details) {
                      setState(() {
                        _hasError = true;
                        _errorMessage = details.description;
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
