import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:siawi_app/app/models/api.dart';

// import 'berita_terbaru.dart';
// import 'menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/utils/colors.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DataMahasiswa extends StatefulWidget {
  final VoidCallback signOut;
  const DataMahasiswa(this.signOut, {Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const DataMahasiswa(this.signOut, {super.key});

  @override
  State<DataMahasiswa> createState() => _DataMahasiswaState();
}

class _DataMahasiswaState extends State<DataMahasiswa> {
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
  String? namaJurusan;
  String? nis;
  String? nisn;
  String? namaKelas;
  // String? rataRata;
  // String? info;
  int presentaseKehadiran = 0;
  double kehadiran = 0;
  Future<void> _lihatData(String idSiswa) async {
    setState(() {
      loading = true;
    });
    final response = await http.get(
        Uri.parse('https://siawi.smkwisataindonesia.sch.id/api/home/$idSiswa'));

    if (response.statusCode == 200) {
      var datasiswa = json.decode(response.body);
      var siswaData = datasiswa['data'];
      var kelasData = siswaData['kelas'];
      var jurusanData = siswaData['jurusan'];
      if (siswaData['nis'] != null) {
        setState(() {
          nama = siswaData['nama_siswa'].toString().toUpperCase();
          namaKelas = kelasData['nama_kelas'].toString();
          namaJurusan = jurusanData['nama_jurusan']?.toString();
          nis = siswaData['nis']?.toString();
          nisn = siswaData['nisn']?.toString();
          presentaseKehadiran =
              int.tryParse(datasiswa['presentaseKehadiran'].toString()) ?? 0;
          kehadiran = presentaseKehadiran / 100;
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
        Column(
          children: [
            Container(
              width: double.infinity, // Use double.infinity for full width
              height: size.height * .25,
              decoration: BoxDecoration(
                color: AppColors.mainColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the column vertically
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Center the column vertically
                          children: [
                            SizedBox(height: 5),
                            _buildTitleData('Kompetensi Keahlian'),
                            _buildData((namaJurusan ?? 'Loading...').length > 32
                                ? '${(namaJurusan ?? 'Loading...').substring(0, 32)}...'
                                : (namaJurusan ?? 'Loading...')),
                            _buildTitleData('NIS / NISN'),
                            _buildData(
                                '${nis ?? 'Loading...'} / ${nisn ?? 'Loading...'}'),
                            _buildTitleData('Kelas'),
                            _buildData(namaKelas ?? 'Loading...'),
                            _buildTitleData('Rata-Rata Rapot'),
                            Row(
                              children: [
                                _buildRata('-'),
                              ],
                            ),
                          ],
                        ),
                        Flexible(
                          child: CircularPercentIndicator(
                            animation: true,
                            radius:
                                size.width * 0.18, // 20% of the screen width
                            lineWidth: 12.0,
                            percent: kehadiran.clamp(0.0, 1.0),
                            center: Text(
                              '$presentaseKehadiran%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    size.width * 0.08, // Scaled to screen width
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: AppColors.secondColor,
                            progressColor: AppColors.thirdColor,
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleData(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Colors.white,
      ),
    );
  }

  Widget _buildData(String text) {
    return Container(
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

  Widget _buildTitle(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      // width: double.maxFinite,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildRata(String text) {
    return Container(
      padding: const EdgeInsets.only(right: 1),
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

  Widget _buildIcon(icon) {
    return Container(
      padding: const EdgeInsets.only(right: 3),
      // width: double.maxFinite,
      child: Icon(
        icon,
        color: Colors.red,
      ),
    );
  }
}
