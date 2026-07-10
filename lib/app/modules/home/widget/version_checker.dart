import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:siawi_app/app/data/api_service.dart';

class VersionChecker {
  final BuildContext context;
  final String currentVersion;
  final String apiUrl;

  VersionChecker({
    required this.context,
    required this.currentVersion,
    required this.apiUrl,
  });

  Future<void> checkForUpdate() async {
    try {
      final data = await ApiService.get('$apiUrl?current_version=$currentVersion');

      if (data != null && data['update_available'] == true) {
        String downloadUrl = data['download_url'] ?? "";
        _showUpdateDialog(downloadUrl);
      }
    } catch (e) {
      print("Terjadi kesalahan saat memeriksa versi: $e");
    }
  }

  void _showUpdateDialog(String downloadUrl) {
    showDialog(
      context: context,
      barrierDismissible: false, // Mencegah pengguna menutup dialog
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, // Mencegah tombol back
          child: AlertDialog(
            title: Text('Update Tersedia'),
            content: Text(
                'Versi terbaru aplikasi tersedia. Silakan unduh untuk mendapatkan fitur terbaru.'),
            actions: [
              TextButton(
                child: Text('Update'),
                onPressed: () async {
                  final Uri url = Uri.parse(downloadUrl);

                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Gagal membuka link: $downloadUrl")),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
