import 'package:flutter/material.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class LupaPasswordView extends StatefulWidget {
  @override
  _LupaPasswordViewState createState() => _LupaPasswordViewState();
}

class _LupaPasswordViewState extends State<LupaPasswordView> {
  final TextEditingController nisController = TextEditingController();
  final TextEditingController namaController = TextEditingController();

  final String adminPhoneNumber = "6285172331507"; // Ganti dengan nomor admin

  void _kirimKeWhatsApp() async {
    String nis = nisController.text.trim();
    String nama = namaController.text.trim();

    if (nis.isEmpty || nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi NIS dan Nama Siswa")),
      );
      return;
    }

    String message =
        "Halo Admin,\nSaya ingin reset password akun saya.\n\nNIS: $nis\nNama: $nama";

    String url =
        "https://wa.me/$adminPhoneNumber?text=${Uri.encodeFull(message)}";

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuka WhatsApp")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        leading: BackButton(color: AppColors.white),
        title: Text(
          'SI AWI',
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: Image.asset(
              'assets/logo/logo-splash.png',
              width: 30,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Masukkan NIS dan Nama Siswa untuk reset password"),
            const SizedBox(height: 10),
            TextField(
              controller: nisController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "NIS",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: "Nama Siswa",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _kirimKeWhatsApp,
                child: const Text("Kirim ke WhatsApp"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
