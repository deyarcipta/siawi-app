import 'package:flutter/material.dart';
import 'package:siawi_app/utils/file_downloader.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DetailModulPraktikView extends StatefulWidget {
  final String judul;
  final String? kode;
  final String? kategori;
  final String? guru;
  final String? fileUrl;
  final String? tujuan;
  final String? alatBahan;
  final String? langkahKerja;
  final List<dynamic>? rubriks;

  const DetailModulPraktikView({
    super.key,
    required this.judul,
    this.kode,
    this.kategori,
    this.guru,
    this.fileUrl,
    this.tujuan,
    this.alatBahan,
    this.langkahKerja,
    this.rubriks,
  });

  @override
  State<DetailModulPraktikView> createState() => _DetailModulPraktikViewState();
}

class _DetailModulPraktikViewState extends State<DetailModulPraktikView> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _hasError = false;
  String _errorMessage = '';
  bool _isDownloading = false;
  bool _showPdfMode = false;

  bool get _hasPdfAttachment {
    final raw = widget.fileUrl?.trim() ?? '';
    return raw.isNotEmpty;
  }

  String get _effectivePdfUrl {
    final raw = widget.fileUrl?.trim() ?? '';
    if (raw.isNotEmpty) {
      if (raw.startsWith('http://') || raw.startsWith('https://')) {
        return raw;
      }
      return 'https://siawi.smkwisataindonesia.sch.id/storage/modul_praktik/${Uri.encodeComponent(raw)}';
    }
    return '';
  }

  String _stripHtml(String? htmlText) {
    if (htmlText == null || htmlText.trim().isEmpty) return '-';
    return htmlText
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  Future<void> _handleDownload() async {
    if (_isDownloading || !_hasPdfAttachment) return;

    setState(() => _isDownloading = true);

    final safeKode = (widget.kode ?? 'MODUL').replaceAll(RegExp(r'\s+'), '_');
    final safeJudul = widget.judul.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final fileName = '${safeKode}_$safeJudul.pdf';

    await FileDownloader.downloadFile(
      context: context,
      url: _effectivePdfUrl,
      defaultFileName: fileName,
    );

    if (mounted) {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasStructuredContent = (widget.tujuan != null && widget.tujuan!.trim().isNotEmpty) ||
        (widget.alatBahan != null && widget.alatBahan!.trim().isNotEmpty) ||
        (widget.langkahKerja != null && widget.langkahKerja!.trim().isNotEmpty);

    final showPdf = _hasPdfAttachment && (_showPdfMode || !hasStructuredContent);

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
              widget.judul.isNotEmpty ? widget.judul : 'Modul & Job Sheet',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15.5,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.kode != null
                  ? '${widget.kode} • Panduan Modul Praktik'
                  : 'Panduan Modul Praktik Siswa',
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
          if (_hasPdfAttachment)
            IconButton(
              tooltip: 'Unduh Lampiran Lembar Kerja',
              icon: _isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download_rounded, color: Colors.white, size: 22),
              onPressed: _isDownloading ? null : _handleDownload,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 14, left: 2),
            child: Center(
              child: Image.asset(
                'assets/logo/logo-splash.png',
                width: 26,
                height: 26,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sub Bar Informasi Modul
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
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 18,
                    color: Color(0xFF4C3EC7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.judul,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.guru != null && widget.guru!.isNotEmpty)
                        Text(
                          'Penyusun: ${widget.guru}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (_hasPdfAttachment && hasStructuredContent) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => setState(() => _showPdfMode = !_showPdfMode),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showPdfMode ? Icons.article_rounded : Icons.picture_as_pdf_rounded,
                            size: 13,
                            color: const Color(0xFF4C3EC7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showPdfMode ? "Lihat Materi" : "Lampiran PDF",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4C3EC7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Area Konten Modul atau PDF Viewer
          Expanded(
            child: showPdf ? _buildPdfViewer() : _buildStructuredModulContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildStructuredModulContent() {
    final tujuanText = _stripHtml(widget.tujuan);
    final alatText = _stripHtml(widget.alatBahan);
    final langkahText = _stripHtml(widget.langkahKerja);
    final rubrikList = widget.rubriks ?? [];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentSection(
            icon: Icons.flag_rounded,
            iconColor: const Color(0xFF4C3EC7),
            bgColor: const Color(0xFFEEF2FF),
            title: "Tujuan Pembelajaran & Praktikum",
            content: tujuanText,
          ),
          const SizedBox(height: 12),
          _buildContentSection(
            icon: Icons.handyman_rounded,
            iconColor: const Color(0xFFD97706),
            bgColor: const Color(0xFFFEF3C7),
            title: "Alat & Bahan Praktik",
            content: alatText,
          ),
          const SizedBox(height: 12),
          _buildContentSection(
            icon: Icons.format_list_numbered_rounded,
            iconColor: const Color(0xFF0284C7),
            bgColor: const Color(0xFFE0F2FE),
            title: "Langkah Kerja (Job Sheet)",
            content: langkahText,
          ),
          if (rubrikList.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.fact_check_rounded,
                          size: 18,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Indikator & Rubrik Penilaian",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...rubrikList.map((r) {
                    final map = r is Map ? r : {};
                    final nama = map['nama_indikator']?.toString() ?? 'Indikator Penilaian';
                    final bobot = map['bobot']?.toString() ?? '100';
                    final deskripsi = map['deskripsi']?.toString() ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    nama,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "Bobot $bobot%",
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (deskripsi.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                deskripsi,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          if (_hasPdfAttachment) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleDownload,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text("Unduh Lampiran Lembar Kerja"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C3EC7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContentSection({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF334155),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
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
                'Gagal Membuka Lampiran Modul',
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
                    : 'Berkas lampiran belum dapat dimuat dari server.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _handleDownload,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Unduh Berkas'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4C3EC7),
                      side: const BorderSide(color: Color(0xFF4C3EC7)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return SfPdfViewer.network(
      _effectivePdfUrl,
      controller: _pdfViewerController,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      canShowPaginationDialog: true,
      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
        setState(() {
          _hasError = true;
          _errorMessage = details.description;
        });
      },
    );
  }
}
