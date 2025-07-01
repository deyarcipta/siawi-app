import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/utils/colors.dart';

class QrCode extends StatefulWidget {
  final VoidCallback signOut;
  const QrCode(this.signOut, {Key? key}) : super(key: key);

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  bool loading = false;
  String? qrCodeSvg;
  String? namaSiswa;
  String? namaJurusan;
  String? namaKelas;
  String? nis;

  Future<String?> getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('idSiswa');
  }

  @override
  void initState() {
    super.initState();
    getIdSiswa().then((idSiswa) {
      if (idSiswa != null) {
        _lihatData(idSiswa);
      }
    });
  }

  Future<void> _lihatData(String idSiswa) async {
    setState(() {
      loading = true;
    });
    try {
      final response =
          await http.get(Uri.parse('http://103.75.209.90/api/home/$idSiswa'));

      if (response.statusCode == 200) {
        var datasiswa = json.decode(response.body);
        var siswaData = datasiswa['data'];
        var kelasData = siswaData['kelas'];
        var jurusanData = siswaData['jurusan'];
        if (siswaData['nis'] != null) {
          setState(() {
            namaSiswa = siswaData['nama_siswa'].toString().toUpperCase();
            namaKelas = kelasData['nama_kelas'].toString();
            namaJurusan = jurusanData['nama_jurusan'].toString();
            nis = siswaData['nis'].toString();
          });

          fetchQRCode();
        }
      } else {
        print('Failed to load student data');
      }
    } catch (e) {
      print('Error fetching student data: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> fetchQRCode() async {
    if (nis == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://103.75.209.90/api/generate-qrcode?data=$nis'),
      );

      if (response.statusCode == 200) {
        setState(() {
          qrCodeSvg = response.body;
        });
      } else {
        print('Failed to load QR Code');
      }
    } catch (e) {
      print('Error fetching QR Code: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0), // Adjust padding as needed
                child: qrCodeSvg == null
                    ? CircularProgressIndicator()
                    : SvgPicture.string(
                        qrCodeSvg!,
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
    );
  }
}
