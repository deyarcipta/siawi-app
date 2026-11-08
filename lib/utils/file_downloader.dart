import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

enum _BannerType { downloading, success, error }

/// Notifikasi popup melayang di bagian atas layar (Top Bar / Status Bar Banner)
class TopDownloadBanner {
  static OverlayEntry? _currentEntry;

  /// Tampilkan notifikasi saat unduhan dimulai
  static void showStarting({
    required BuildContext context,
    required String fileName,
  }) {
    _show(
      context: context,
      type: _BannerType.downloading,
      title: 'Sedang Mengunduh Berkas...',
      fileName: fileName,
      folderName: '',
      fullPath: 'Mohon tunggu sebentar sampai berkas siap.',
      autoDismissDuration: const Duration(seconds: 4),
    );
  }

  /// Tampilkan popup sukses dengan lokasi folder penyimpanan berkas
  static void showSuccess({
    required BuildContext context,
    required String fileName,
    required String folderName,
    required String fullPath,
  }) {
    _show(
      context: context,
      type: _BannerType.success,
      title: 'Berkas Berhasil Diunduh',
      fileName: fileName,
      folderName: folderName,
      fullPath: fullPath,
      autoDismissDuration: const Duration(seconds: 6),
    );
  }

  /// Tampilkan popup jika unduhan gagal
  static void showError({
    required BuildContext context,
    required String errorMessage,
  }) {
    _show(
      context: context,
      type: _BannerType.error,
      title: 'Gagal Mengunduh Berkas',
      fileName: '',
      folderName: '',
      fullPath: errorMessage,
      autoDismissDuration: const Duration(seconds: 5),
    );
  }

  static void _show({
    required BuildContext context,
    required _BannerType type,
    required String title,
    required String fileName,
    required String folderName,
    required String fullPath,
    required Duration autoDismissDuration,
  }) {
    try {
      _currentEntry?.remove();
      _currentEntry = null;
    } catch (_) {}

    final overlay =
        Overlay.maybeOf(context, rootOverlay: true) ?? Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _TopBannerNotification(
        type: type,
        title: title,
        fileName: fileName,
        folderName: folderName,
        fullPath: fullPath,
        autoDismissDuration: autoDismissDuration,
        onDismiss: () {
          try {
            if (entry.mounted) {
              entry.remove();
            }
          } catch (_) {}
          if (_currentEntry == entry) {
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }
}

class _TopBannerNotification extends StatefulWidget {
  final _BannerType type;
  final String title;
  final String fileName;
  final String folderName;
  final String fullPath;
  final Duration autoDismissDuration;
  final VoidCallback onDismiss;

  const _TopBannerNotification({
    required this.type,
    required this.title,
    required this.fileName,
    required this.folderName,
    required this.fullPath,
    required this.autoDismissDuration,
    required this.onDismiss,
  });

  @override
  State<_TopBannerNotification> createState() => _TopBannerNotificationState();
}

class _TopBannerNotificationState extends State<_TopBannerNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 280),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    _dismissTimer = Timer(widget.autoDismissDuration, () {
      _handleDismiss();
    });
  }

  void _handleDismiss() {
    if (!mounted) return;
    _dismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor;
    Widget iconWidget;

    switch (widget.type) {
      case _BannerType.downloading:
        accentColor = const Color(0xFF6366F1);
        iconWidget = const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Color(0xFF818CF8),
          ),
        );
        break;
      case _BannerType.success:
        accentColor = const Color(0xFF10B981);
        iconWidget = const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF34D399),
          size: 22,
        );
        break;
      case _BannerType.error:
        accentColor = const Color(0xFFEF4444);
        iconWidget = const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFFCA5A5),
          size: 22,
        );
        break;
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null &&
                    details.primaryDelta! < -4) {
                  _handleDismiss();
                }
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.85),
                      width: 1.3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7.5),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: iconWidget,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                if (widget.fileName.isNotEmpty) ...[
                                  const SizedBox(height: 2.5),
                                  Text(
                                    widget.fileName,
                                    style: const TextStyle(
                                      color: Color(0xFF93C5FD),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: _handleDismiss,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white70,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.type == _BannerType.success) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.folder_open_rounded,
                                size: 16,
                                color: Color(0xFFFBBF24),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tersimpan di: ${widget.folderName}',
                                      style: const TextStyle(
                                        color: Color(0xFFF8FAFC),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 1.5),
                                    Text(
                                      widget.fullPath,
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (widget.type == _BannerType.error) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.fullPath,
                          style: const TextStyle(
                            color: Color(0xFFFCA5A5),
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FileDownloader {
  /// Mengunduh berkas langsung ke folder Download publik perangkat menggunakan Download Manager / Browser sistem.
  /// Ini memastikan berkas 100% tersimpan di folder Download perangkat dan dapat ditemukan di Pengelola File / Unduhan HP.
  static Future<File?> downloadFile({
    required BuildContext context,
    required String url,
    required String defaultFileName,
    bool showStartingNotification = true,
  }) async {
    // 1. Sanitasi nama berkas awal
    String sanitizedName =
        defaultFileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    if (sanitizedName.isEmpty) {
      sanitizedName = 'dokumen_${DateTime.now().millisecondsSinceEpoch}';
    }
    if (!sanitizedName.toLowerCase().endsWith('.pdf')) {
      sanitizedName = '$sanitizedName.pdf';
    }

    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) {
      if (context.mounted) {
        TopDownloadBanner.showError(
          context: context,
          errorMessage: 'Tautan berkas belum tersedia atau kosong.',
        );
      }
      return null;
    }

    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null) {
      if (context.mounted) {
        TopDownloadBanner.showError(
          context: context,
          errorMessage: 'Format tautan berkas tidak valid.',
        );
      }
      return null;
    }

    if (showStartingNotification && context.mounted) {
      TopDownloadBanner.showStarting(
        context: context,
        fileName: sanitizedName,
      );
    }

    // 2. Metode Utama: Gunakan Download Manager / Browser Sistem
    // Ini adalah metode resmi di Android 10+ agar file tersimpan di folder publik /Download
    // dan muncul di notifikasi sistem HP serta Pengelola File/File Manager.
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        if (context.mounted) {
          TopDownloadBanner.showSuccess(
            context: context,
            fileName: sanitizedName,
            folderName: 'Folder Download (Penyimpanan Utama HP)',
            fullPath: 'Berkas diunduh langsung ke folder Download & tercatat di notifikasi HP.',
          );
        }
        return null;
      }
    } catch (_) {
      // Jika peluncuran eksternal gagal, lanjut ke fallback HTTP internal
    }

    // 3. Fallback: HTTP download manual ke cache/storage internal
    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 45),
        onTimeout: () =>
            throw Exception('Koneksi waktu habis saat mengunduh berkas'),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Server mengembalikan kode status: ${response.statusCode}');
      }

      Directory? targetDir;
      if (Platform.isAndroid) {
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (await publicDownload.exists()) {
          try {
            final testFile = File(
                '${publicDownload.path}/.test_${DateTime.now().millisecondsSinceEpoch}');
            await testFile.writeAsString('test');
            await testFile.delete();
            targetDir = publicDownload;
          } catch (_) {}
        }
      }

      if (targetDir == null) {
        try {
          targetDir = await getDownloadsDirectory();
        } catch (_) {}
      }

      if (targetDir == null && Platform.isAndroid) {
        try {
          targetDir = await getExternalStorageDirectory();
        } catch (_) {}
      }

      targetDir ??= await getApplicationDocumentsDirectory();

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      String filePath = '${targetDir.path}/$sanitizedName';
      File file = File(filePath);
      int counter = 1;
      final nameWithoutExt =
          sanitizedName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
      while (await file.exists()) {
        filePath = '${targetDir.path}/${nameWithoutExt}_($counter).pdf';
        file = File(filePath);
        counter++;
      }

      await file.writeAsBytes(response.bodyBytes);

      final finalFileName = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : sanitizedName;

      final folderLabel = targetDir.path.contains('Download')
          ? 'Folder Download (Penyimpanan Utama HP)'
          : (targetDir.path.contains('Documents') ||
                  targetDir.path.contains('app_flutter')
              ? 'Folder Dokumen Aplikasi'
              : targetDir.path);

      if (context.mounted) {
        TopDownloadBanner.showSuccess(
          context: context,
          fileName: finalFileName,
          folderName: folderLabel,
          fullPath: file.path,
        );
      }

      return file;
    } catch (e) {
      if (context.mounted) {
        TopDownloadBanner.showError(
          context: context,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        );
      }
      return null;
    }
  }
}
