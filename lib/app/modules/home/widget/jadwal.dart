import 'dart:convert';
// import 'dart:ffi';

import 'package:flutter/material.dart';
// import 'package:siawi_app/app/models/api.dart';
import 'package:siawi_app/app/models/jadwal_hari_ini.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/utils/colors.dart';
// import 'package:percent_indicator/percent_indicator.dart';

class JadwalToday extends StatefulWidget {
  final VoidCallback signOut;
  const JadwalToday(this.signOut, {Key? key}) : super(key: key);

  @override
  State<JadwalToday> createState() => _JadwalState();
}

class _JadwalState extends State<JadwalToday> {
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
        _fetchJadwalToday(idSiswa);
      }
    });
  }

  List<JadwalHariIni> jadwalHariIniList = [];
  Future<void> _fetchJadwalToday(String idSiswa) async {
    final response = await http
        .get(Uri.parse('http://203.194.113.46/api/jadwalToday/$idSiswa'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> jadwalData = responseData['data'];
      setState(() {
        jadwalHariIniList.clear();
        for (var item in jadwalData) {
          JadwalHariIni jadwal = JadwalHariIni.fromJson(item);
          jadwalHariIniList.add(jadwal);
        }
      });
    } else {
      print('Failed to load jadwal hari ini');
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Wrap(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: 20,
          ),
          child: Column(
            children: [
              Container(
                height: size.height * .18,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.secondColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "Jadwal Hari Ini",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        child: SizedBox(
                          height: 100,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (_, index) => Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                width: size.width * .44,
                                // height: size.height * 1,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/background.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: ClipRRect(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          jadwalHariIniList[index]
                                                      .namaMapel
                                                      .length >
                                                  20 // Misalnya, Anda ingin membatasi hingga 10 karakter
                                              ? jadwalHariIniList[index]
                                                      .namaMapel
                                                      .substring(0, 20) +
                                                  '...' // Jika panjang string lebih dari 10 karakter, potong dan tambahkan tanda titik-titik
                                              : jadwalHariIniList[index]
                                                  .namaMapel,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              jadwalHariIniList[index].jamAwal,
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              ' s/d ',
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              jadwalHariIniList[index].jamAkhir,
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              ' | ',
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              jadwalHariIniList[index]
                                                  .waktuAwal,
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              ' s/d ',
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              jadwalHariIniList[index]
                                                  .waktuAkhir,
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          jadwalHariIniList[index].namaGuru,
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            separatorBuilder: (_, index) =>
                                const SizedBox(width: 8),
                            itemCount: jadwalHariIniList.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
