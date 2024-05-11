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
    final response =
        await http.get(Uri.parse('http://203.194.113.46/api/home/$idSiswa'));
    // print(response.statusCode);

    if (response.statusCode == 200) {
      var datasiswa = json.decode(response.body);
      var siswaData = datasiswa['data'];
      var kelasData = siswaData['kelas'];
      var jurusanData = siswaData['jurusan'];
      if (siswaData['nis'] != null) {
        setState(() {
          nama = siswaData['nama_siswa'].toString();
          nis = siswaData['nis'].toString();
          nisn = siswaData['nisn'].toString();
          namaKelas = kelasData['nama_kelas'].toString();
          namaJurusan = jurusanData['nama_jurusan'].toString();
          // rataRata = datasiswa['rapotTerakhir'].toString();
          // info = datasiswa['pesan'].toString();
          presentaseKehadiran =
              int.tryParse(datasiswa['presentaseKehadiran'].toString()) ?? 0;
          kehadiran = presentaseKehadiran / 100;
          if (namaJurusan!.length > 10) {
            namaJurusan = namaJurusan?.substring(0, 32);
          }
          // print(nama);
          // print('Nama Kelas: $presentaseKehadiran');
        });
      }
    } else {
      // print(idSiswa);
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
              width: double.maxFinite,
              height: size.height * .25,
              decoration: BoxDecoration(
                color: AppColors.secondColor,
                borderRadius: BorderRadius.circular(25),
                // image: DecorationImage(
                //   image: AssetImage('assets/images/background2.jpg')
                //       as ImageProvider,
                //   fit: BoxFit.cover,
                // ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            _buildTitleData('Kompetensi Keahlian'),
                            _buildData(namaJurusan ?? 'Loading...'),
                            _buildTitleData('NIS / NISN'),
                            _buildData(
                                '${nis ?? 'Loading...'} / ${nisn ?? 'Loading...'}'),
                            _buildTitleData('Kelas'),
                            _buildData(namaKelas ?? 'Loading...'),
                            _buildTitleData('Rata-Rata Rapot'),
                            Row(
                              children: [
                                _buildRata('-'),
                                // _buildIcon()
                                // _buildRata('${rataRata ?? 'Loading...'}'),
                                // _buildIcon(info)
                              ],
                            ),
                          ],
                        ),
                        CircularPercentIndicator(
                          animation: true,
                          radius: 70.0,
                          lineWidth: 12.0,
                          percent: kehadiran,
                          center: new Text(
                            '${presentaseKehadiran}',
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: AppColors.mainColor,
                          progressColor: AppColors.thirdColor,
                          circularStrokeCap: CircularStrokeCap.round,
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
}

Widget _buildTitleData(String text) {
  return Container(
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Colors.white,
      ),
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
