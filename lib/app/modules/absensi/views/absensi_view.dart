import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:siawi_app/app/modules/absensi/widget/absen_list.dart';
// import 'package:siawi_app/app/modules/absensi/widget/absen.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/app/data/api_service.dart';

// import 'package:get/get.dart';

// import '../controllers/absensi_controller.dart';

class AbsensiView extends StatefulWidget {
  final VoidCallback signOut;
  const AbsensiView(this.signOut, {Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const AbsensiView(this.signOut, {super.key});

  @override
  State<AbsensiView> createState() => _AbsensiViewState();
}

class _AbsensiViewState extends State<AbsensiView> {
  var appBarHeight = AppBar().preferredSize.height;
  Future<String?> getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? idSiswa = preferences.getString('idSiswa');
    return idSiswa;
  }

  @override
  void initState() {
    super.initState();
    getIdSiswa().then((idSiswa) {
      // Jika idSiswa tidak null, panggil _lihatData
      if (idSiswa != null) {
        _fetchPoint(idSiswa);
      }
    });
  }

  List<AbsenList> absenList = [];
  String? jumlahIzin;
  String? namaSiswa;
  String? jumlahAlfa;
  String? jumlahSakit;
  String? jumlahHadir;
  String? jumlahTidakHadir;
  int presentaseKehadiran = 0;
  double kehadiran = 0;
  Future<void> _fetchPoint(String idSiswa) async {
    final response = await http.get(Uri.parse(
        'https://siawi.smkwisataindonesia.sch.id/api/absensi/$idSiswa'));
    if (response.statusCode == 200) {
      var dataAbsen = json.decode(response.body);
      var siswaData = dataAbsen['dataSiswa'];
      // var kelasData = siswaData['kelas'];
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> absenData = responseData['data'];
      setState(() {
        namaSiswa = siswaData['nama_siswa'].toString();
        jumlahSakit = dataAbsen['jumlahSakit'].toString();
        jumlahIzin = dataAbsen['jumlahIzin'].toString();
        jumlahAlfa = dataAbsen['jumlahAlfa'].toString();
        jumlahHadir = dataAbsen['jumlahHadir'].toString();
        jumlahTidakHadir = dataAbsen['jumlahTidakHadir'].toString();
        presentaseKehadiran =
            int.tryParse(dataAbsen['presentaseKehadiran'].toString()) ?? 0;
        kehadiran = presentaseKehadiran / 100;
        absenList.clear();
        for (var item in absenData) {
          AbsenList absen = AbsenList.fromJson(item);
          absenList.add(absen);
        }
      });
    } else {
      print('Failed to load absen siswa');
    }
  }

  IconData _getAttendanceIcon(String keterangan) {
    switch (keterangan.toLowerCase()) {
      case 'sakit':
        return Icons.medical_services_outlined;
      case 'izin':
        return Icons.assignment_turned_in_outlined;
      case 'alfa':
        return Icons.cancel_outlined;
      default:
        return Icons.check_circle_outline_rounded;
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
      body: SingleChildScrollView(
        child: Wrap(
          children: <Widget>[
            SafeArea(
              child: Container(
                height: size.height * .25,
                decoration: BoxDecoration(
                  color: AppColors.fiveColor,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircularPercentIndicator(
                        animation: true,
                        radius: 60.0,
                        lineWidth: 10.0,
                        percent: kehadiran,
                        center: new Text(
                          "${presentaseKehadiran}",
                          style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 26.0,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: AppColors.mainColor,
                        progressColor: AppColors.thirdColor,
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          _buildTitle('${namaSiswa}'),
                          Container(
                            width: size.width * 0.5,
                            // child: Padding(
                            // padding: EdgeInsets.only(right: 100),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    _buildTitleData('Hadir'),
                                    _buildData(': ${jumlahHadir}'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildTitleData('Sakit'),
                                    _buildData(': ${jumlahSakit}'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildTitleData('Izin'),
                                    _buildData(': ${jumlahIzin}'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildTitleData('Alfa'),
                                    _buildData(': ${jumlahAlfa}'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildTitleData('Tidak Hadir'),
                                    _buildData(': ${jumlahTidakHadir}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                children: <Widget>[
                  Text(
                    "Data Kehadiran",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: absenList.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: item.warna.withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon Status Kehadiran
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: item.warna.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getAttendanceIcon(item.keterangan),
                                color: item.warna,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Informasi Utama (Tanggal & Status)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.hari.toUpperCase()}, ${item.tanggal}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.sixColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.status,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Baris Waktu Absen (Jam Masuk / Jam Pulang)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.login_rounded,
                                        size: 13,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.jamMasuk,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.logout_rounded,
                                        size: 13,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.jamPulang,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Badge Tipe Absen (Kanan)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.tipeAbsen.contains('Otomatis')
                                        ? Colors.green.withOpacity(0.12)
                                        : Colors.orange.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        item.tipeAbsen.contains('Otomatis')
                                            ? Icons.face_retouching_natural
                                            : Icons.person_rounded,
                                        size: 12,
                                        color: item.tipeAbsen.contains('Otomatis')
                                            ? Colors.green[800]
                                            : Colors.orange[850],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.tipeAbsen.contains('Otomatis')
                                            ? 'Otomatis'
                                            : 'Manual',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: item.tipeAbsen.contains('Otomatis')
                                              ? Colors.green[800]
                                              : Colors.orange[850],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTitle(String text) {
  return Container(
    width: 200,
    padding: const EdgeInsets.only(top: 25),
    child: Text(
      text,
      maxLines: 2,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Colors.white,
      ),
    ),
  );
}

Widget _buildTitleData(String text) {
  return Container(
    width: 65,
    padding: const EdgeInsets.only(bottom: 8),
    // width: double.maxFinite,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.white,
      ),
    ),
  );
}

Widget _buildData(String text) {
  return Container(
    width: 50,
    padding: const EdgeInsets.only(bottom: 8),
    // width: double.maxFinite,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.white,
      ),
    ),
  );
}
