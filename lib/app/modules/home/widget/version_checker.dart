import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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
      final response =
          await http.get(Uri.parse('$apiUrl?current_version=$currentVersion'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['update_available'] == true) {
          String downloadUrl = data['download_url'] ?? "";
          _showUpdateDialog(downloadUrl);
        }
      } else {
        print("Gagal memeriksa pembaruan. Status code: ${response.statusCode}");
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
        return WillPopScope(
          onWillPop: () async => false, // Mencegah tombol back
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
