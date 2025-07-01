import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class WaliScreen extends StatefulWidget {
  final VoidCallback signOut;
  const WaliScreen(this.signOut, {super.key});
  // final VoidCallback signOut;
  // const ProfileScreen(this.signOut, {super.key});

  @override
  State<WaliScreen> createState() => _WaliScreenState();
}

class _WaliScreenState extends State<WaliScreen> {
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
  String? nikWali;
  String? namaWali;
  String? tmptLahirWali;
  String? tglLahirWali;
  String? pendidikanWali;
  String? pekerjaanWali;
  String? penghasilanWali;
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
      if (siswaData['nis'] != null) {
        setState(() {
          nikWali = siswaData['nik_wali'].toString();
          namaWali = siswaData['nama_wali'].toString();
          tglLahirWali = siswaData['tmpt_lahir_wali'].toString();
          tglLahirWali = siswaData['tgl_lahir_wali'].toString();
          pendidikanWali = siswaData['pendidikan_wali'].toString();
          pekerjaanWali = siswaData['pekerjaan_wali'].toString();
          penghasilanWali = siswaData['penghasilan_wali'].toString();
          // print(namaIbu);
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
    // var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: _buildTitle('Data Wali'),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleData('NIK'),
                          _buildData('${nikWali ?? 'Loading...'}'),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleData('Nama Wali'),
                          _buildData('${namaWali ?? 'Loading...'}'),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleData('Tempat, Tanggal Lahir'),
                          _buildData(
                              '${tmptLahirWali ?? 'Loading...'}, ${tglLahirWali ?? 'Loading...'}'),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleData('Pendidikan'),
                          _buildData('${pendidikanWali ?? 'Loading...'}'),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleData('Pekerjaan'),
                          _buildData('${pekerjaanWali ?? 'Loading...'}'),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleData('Penghasilan'),
                          _buildData('${penghasilanWali ?? 'Loading...'}'),
                        ],
                      ),
                    ),
                  ],
                ),
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
    child: Text(
      text,
      maxLines: 2,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}

Widget _buildTitleData(String text) {
  return Container(
    child: Text(
      text,
      maxLines: 2,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.grey,
      ),
    ),
  );
}

Widget _buildData(String text) {
  return Container(
    // padding: const EdgeInsets.only(bottom: 5),
    // width: double.maxFinite,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.black,
      ),
    ),
  );
}
