import 'dart:convert';
// import 'dart:ffi';

import 'package:flutter/material.dart';
// import 'package:siawi_app/app/models/api.dart';

// import 'berita_terbaru.dart';
// import 'menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
// import 'package:siawi_app/utils/colors.dart';
// import 'package:percent_indicator/percent_indicator.dart';

class Absen extends StatefulWidget {
  final VoidCallback signOut;
  const Absen(this.signOut, {Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const DataMahasiswa(this.signOut, {super.key});

  @override
  State<Absen> createState() => _AbsenState();
}

class _AbsenState extends State<Absen> {
  Future<String?> getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? idSiswa = preferences.getString('idSiswa');
    return idSiswa;
  }

  @override
  void initState() {
    super.initState();
    // Panggil getIdSiswa dan tunggu hasilnya
    getIdSiswa().then((idSiswa) {
      // Jika idSiswa tidak null, panggil _lihatData
      if (idSiswa != null) {
        _lihatData(idSiswa);
      }
    });
  }

  bool loading = false;
  String? nama;
  String? kehadiran1;
  String? kehadiran2;
  Color? warna;
  Future<void> _lihatData(String idSiswa) async {
    setState(() {
      loading = true;
    });
    final response = await http.get(
        Uri.parse('https://siawi.smkwisataindonesia.sch.id/api/home/$idSiswa'));
    // print(response.statusCode);

    if (response.statusCode == 200) {
      var datasiswa = json.decode(response.body);
      var siswaData = datasiswa['data'];
      var kehadiranToday = datasiswa['kehadiranToday'];
      if (siswaData['nis'] != null) {
        setState(() {
          nama = siswaData['nama_siswa'].toString();
          if (datasiswa['kehadiranToday'] != null) {
            if (kehadiranToday['kehadiran'] == 'hadir') {
              kehadiran1 = "Kamu Hadir".toString();
              kehadiran2 = "Semangat".toString();
              warna = Colors.greenAccent;
            } else if (kehadiranToday['kehadiran'] == 'sakit') {
              kehadiran1 = "Kamu Sedang Sakit".toString();
              kehadiran2 = "Lekas sehat yaa".toString();
              warna = Colors.orangeAccent;
            } else if (kehadiranToday['kehadiran'] == 'alfa') {
              kehadiran1 = "Kamu Alfa".toString();
              kehadiran2 = "Ayo Semangat Sekolah".toString();
              warna = Colors.redAccent;
            } else if (kehadiranToday['kehadiran'] == 'izin') {
              kehadiran1 = "Hari Sedang Izin".toString();
              kehadiran2 = "Segera Masuk Yaa.".toString();
              warna = Colors.orangeAccent;
            } else {
              kehadiran1 = "Belum Ada Data".toString();
              kehadiran2 = "ditunggu yaa".toString();
            }
          } else {
            kehadiran1 = "Belum Ada Data".toString();
            kehadiran2 = "ditunggu yaa".toString();
            warna = Colors.blueAccent;
          }
        });
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Wrap(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Kehadiran Hari Ini",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.maxFinite,
                height: size.height * .06,
                decoration: BoxDecoration(
                  color: warna,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      kehadiran1 ?? 'Loading...',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      kehadiran2 ?? 'Loading...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
