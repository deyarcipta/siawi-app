import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FileDownloader {
  /// Mengunduh berkas langsung ke penyimpanan lokal tanpa redirect/membuka browser eksternal
  static Future<File?> downloadFile({
    required BuildContext context,
    required String url,
    required String defaultFileName,
  }) async {
    try {
      // 1. Fetch file bytes via HTTP
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 45),
        onTimeout: () =>
            throw Exception('Koneksi waktu habis saat mengunduh berkas'),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Server mengembalikan kode status: ${response.statusCode}');
      }

      // 2. Sanitasi nama berkas
      String sanitizedName =
          defaultFileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
      if (sanitizedName.isEmpty) {
        sanitizedName = 'dokumen_${DateTime.now().millisecondsSinceEpoch}';
      }
      if (!sanitizedName.toLowerCase().endsWith('.pdf')) {
        sanitizedName = '$sanitizedName.pdf';
      }

      // 3. Tentukan direktori penyimpanan
      Directory? targetDir;
      if (Platform.isAndroid) {
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (await publicDownload.exists()) {
          try {
            // Uji izin tulis ke folder Download publik Android
            final testFile = File(
                '${publicDownload.path}/.test_${DateTime.now().millisecondsSinceEpoch}');
            await testFile.writeAsString('test');
            await testFile.delete();
            targetDir = publicDownload;
          } catch (_) {
            // Scoped storage fallback
          }
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

      // 4. Buat nama file unik jika sudah ada
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

      // 5. Tulis bytes ke penyimpanan
      await file.writeAsBytes(response.bodyBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Berkas Berhasil Diunduh',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tersimpan di: ${targetDir.path.contains('Download') ? 'Folder Download' : targetDir.path}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      return file;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gagal mengunduh berkas: ${e.toString().replaceAll('Exception: ', '')}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return null;
    }
  }
}
