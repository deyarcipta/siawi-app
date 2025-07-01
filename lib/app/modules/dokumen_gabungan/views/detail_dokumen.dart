import 'package:flutter/material.dart';

class DetailDokumenView extends StatelessWidget {
  final Map dokumen;
  const DetailDokumenView(this.dokumen, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(dokumen['nama_dokumen'] ?? 'Dokumen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Jenis Dokumen: ${dokumen['jenis_dokumen']}"),
            SizedBox(height: 16),
            Text("URL File:"),
            Text(dokumen['file_url'] ?? '-',
                style: TextStyle(color: Colors.blue)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Bisa pakai `url_launcher` untuk membuka file
              },
              child: Text("Buka Dokumen"),
            )
          ],
        ),
      ),
    );
  }
}
