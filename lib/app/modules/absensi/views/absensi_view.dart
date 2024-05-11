import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:siawi_app/app/modules/absensi/widget/absen_list.dart';
// import 'package:siawi_app/app/modules/absensi/widget/absen.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
    final response =
        await http.get(Uri.parse('http://203.194.113.46/api/absensi/$idSiswa'));
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
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: absenList.map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        // side: BorderSide(width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      tileColor: AppColors.thirdColor,
                      leading: Image.asset(
                        'assets/icon/absen.png',
                        width: 25,
                        height: 25,
                      ),
                      title: Text('${item.hari}, ${item.tanggal}'),
                      titleTextStyle: TextStyle(
                          fontSize: 10,
                          color: AppColors.sixColor,
                          fontWeight: FontWeight.w500),
                      subtitle: Text(item.status),
                      subtitleTextStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      trailing: Container(
                        width: 15, // Lebar lingkaran
                        height: 15, // Tinggi lingkaran
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // Mengatur bentuk lingkaran
                          color: item.warna, // Mengatur warna lingkaran
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
