import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class Absen extends StatefulWidget {
  final VoidCallback signOut;
  const Absen(this.signOut, {Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const DataMahasiswa(this.signOut, {super.key});

  @override
  State<Absen> createState() => _AbsenState();
}

class _AbsenState extends State<Absen> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
  Future<void> _showNotification(String status, Color color) async {
    Get.snackbar(
      'Absensi Berhasil',
      'Kamu telah melakukan absensi hari ini: ${status.toUpperCase()}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: color.withOpacity(0.9),
      colorText: Colors.black87,
      icon: Icon(Icons.check_circle_outline, color: Colors.green[800]),
      margin: const EdgeInsets.all(15),
      borderRadius: 15,
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> _checkAndNotify(String status, Color color) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String todayDate = DateTime.now().toString().substring(0, 10);
    String lastNotifiedDate = preferences.getString('last_notified_date') ?? '';
    String lastNotifiedStatus = preferences.getString('last_notified_status') ?? '';

    if (lastNotifiedDate != todayDate || lastNotifiedStatus != status) {
      _showNotification(status, color);
      await preferences.setString('last_notified_date', todayDate);
      await preferences.setString('last_notified_status', status);
    }
  }

  Future<void> _checkAttendanceSilently(String idSiswa) async {
    try {
      final response = await http.get(
          Uri.parse('https://siawi.smkwisataindonesia.sch.id/api/home/$idSiswa'));
      if (response.statusCode == 200) {
        var datasiswa = json.decode(response.body);
        var kehadiranToday = datasiswa['kehadiranToday'];
        if (kehadiranToday != null) {
          String status = kehadiranToday['kehadiran'].toString();
          Color activeColor = Colors.blueAccent;
          String k1 = "Belum Ada Data";
          String k2 = "ditunggu yaa";
          
          if (status == 'hadir') {
            k1 = "Kamu Hadir";
            k2 = "Semangat";
            activeColor = Colors.greenAccent;
          } else if (status == 'sakit') {
            k1 = "Kamu Sedang Sakit";
            k2 = "Lekas sehat yaa";
            activeColor = Colors.orangeAccent;
          } else if (status == 'alfa') {
            k1 = "Kamu Alfa";
            k2 = "Ayo Semangat Sekolah";
            activeColor = Colors.redAccent;
          } else if (status == 'izin') {
            k1 = "Hari Sedang Izin";
            k2 = "Segera Masuk Yaa.";
            activeColor = Colors.orangeAccent;
          }

          setState(() {
            kehadiran1 = k1;
            kehadiran2 = k2;
            warna = activeColor;
            _timer?.cancel();
            _timer = null;
          });
          _checkAndNotify(status, activeColor);
        }
      }
    } catch (e) {
      print('Error checking attendance silently: $e');
    }
  }

  Future<void> _lihatData(String idSiswa) async {
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(
          Uri.parse('https://siawi.smkwisataindonesia.sch.id/api/home/$idSiswa'));

      if (response.statusCode == 200) {
        var datasiswa = json.decode(response.body);
        var siswaData = datasiswa['data'];
        var kehadiranToday = datasiswa['kehadiranToday'];
        if (siswaData['nis'] != null) {
          setState(() {
            nama = siswaData['nama_siswa'].toString();
            if (kehadiranToday != null) {
              String status = kehadiranToday['kehadiran'].toString();
              Color activeColor = Colors.blueAccent;
              if (status == 'hadir') {
                kehadiran1 = "Kamu Hadir";
                kehadiran2 = "Semangat";
                activeColor = Colors.greenAccent;
              } else if (status == 'sakit') {
                kehadiran1 = "Kamu Sedang Sakit";
                kehadiran2 = "Lekas sehat yaa";
                activeColor = Colors.orangeAccent;
              } else if (status == 'alfa') {
                kehadiran1 = "Kamu Alfa";
                kehadiran2 = "Ayo Semangat Sekolah";
                activeColor = Colors.redAccent;
              } else if (status == 'izin') {
                kehadiran1 = "Hari Sedang Izin";
                kehadiran2 = "Segera Masuk Yaa.";
                activeColor = Colors.orangeAccent;
              } else {
                kehadiran1 = "Belum Ada Data";
                kehadiran2 = "ditunggu yaa";
              }
              warna = activeColor;
              _timer?.cancel();
              _timer = null;
              
              _checkAndNotify(status, activeColor);
            } else {
              kehadiran1 = "Belum Ada Data";
              kehadiran2 = "ditunggu yaa";
              warna = Colors.blueAccent;

              if (_timer == null) {
                _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
                  getIdSiswa().then((idSiswa) {
                    if (idSiswa != null) {
                      _checkAttendanceSilently(idSiswa);
                    }
                  });
                });
              }
            }
          });
        }
      }
    } catch (e) {
      print('Error loading attendance: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
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
