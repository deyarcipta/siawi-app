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
  Future<void> _lihatData(String idSiswa) async {
    setState(() {
      loading = true;
    });
    final response =
        await http.get(Uri.parse('http://103.75.209.90/api/home/$idSiswa'));
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
              kehadiran1 = "Hari ini kamu masuk sekolah".toString();
              kehadiran2 = "Semangat menggapai cita-cita mu".toString();
            } else if (kehadiranToday['kehadiran'] == 'sakit') {
              kehadiran1 = "Hari ini kamu tidak masuk sekolah".toString();
              kehadiran2 = "Lekas sehat yaa".toString();
            } else if (kehadiranToday['kehadiran'] == 'alfa') {
              kehadiran1 = "Hari ini kamu tidak masuk sekolah".toString();
              kehadiran2 = "Kamu kemana ko tidak hadir".toString();
            } else if (kehadiranToday['kehadiran'] == 'izin') {
              kehadiran1 = "Hari ini kamu tidak masuk sekolah".toString();
              kehadiran2 = "Segera dituntaskan yaa urusan mu".toString();
            } else {
              kehadiran1 = "Hari ini belum ada data kehadiran".toString();
              kehadiran2 = "ditunggu yaa segera diperbarui".toString();
            }
          } else {
            kehadiran1 = "Hari ini belum ada data kehadiran".toString();
            kehadiran2 = "ditunggu yaa segera diperbarui".toString();
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
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.maxFinite,
                height: size.height * .06,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
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
