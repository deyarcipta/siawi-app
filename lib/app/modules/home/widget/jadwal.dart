import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:siawi_app/app/models/jadwal_hari_ini.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/utils/colors.dart';

class JadwalToday extends StatefulWidget {
  final VoidCallback signOut;
  const JadwalToday(this.signOut, {Key? key}) : super(key: key);

  @override
  State<JadwalToday> createState() => _JadwalState();
}

class _JadwalState extends State<JadwalToday> {
  List<JadwalHariIni> jadwalHariIniList = [];

  @override
  void initState() {
    super.initState();
    getIdSiswa().then((idSiswa) {
      if (idSiswa != null) {
        _fetchJadwalToday(idSiswa);
      }
    });
  }

  Future<String?> getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('idSiswa');
  }

  Future<void> _fetchJadwalToday(String idSiswa) async {
    final response = await http.get(
      Uri.parse('http://103.75.209.90/api/jadwalToday/$idSiswa'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> jadwalData = responseData['data'];
      setState(() {
        jadwalHariIniList =
            jadwalData.map((item) => JadwalHariIni.fromJson(item)).toList();
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
          padding: const EdgeInsets.only(top: 20),
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
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
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
                      SizedBox(
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
                              width: size.width * .44,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: const DecorationImage(
                                  image: AssetImage(
                                    "assets/images/background.jpg",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        jadwalHariIniList[index]
                                                    .namaMapel
                                                    .length >
                                                20
                                            ? '${jadwalHariIniList[index].namaMapel.substring(0, 20)}...'
                                            : jadwalHariIniList[index]
                                                .namaMapel,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            jadwalHariIniList[index].jamAwal,
                                            style:
                                                const TextStyle(fontSize: 10),
                                          ),
                                          const Text(
                                            ' s/d ',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Text(
                                            jadwalHariIniList[index].jamAkhir,
                                            style:
                                                const TextStyle(fontSize: 10),
                                          ),
                                          const Text(
                                            ' | ',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Text(
                                            jadwalHariIniList[index].waktuAwal,
                                            style:
                                                const TextStyle(fontSize: 10),
                                          ),
                                          const Text(
                                            ' s/d ',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Text(
                                            jadwalHariIniList[index].waktuAkhir,
                                            style:
                                                const TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            width: 7,
                                            height: 7,
                                            margin:
                                                const EdgeInsets.only(right: 5),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _getColorForStatus(
                                                  jadwalHariIniList[index]
                                                      .statusKehadiran),
                                            ),
                                          ),
                                          Text(
                                            jadwalHariIniList[index].namaGuru,
                                            style:
                                                const TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      )
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

Color _getColorForStatus(String status) {
  switch (status.toLowerCase()) {
    case 'hadir':
      return Colors.green;
    case 'sakit':
    case 'izin':
      return Colors.yellow;
    case 'tidak hadir':
    case 'alfa':
      return Colors.red;
    default:
      return Colors.grey; // Jika status tidak dikenali
  }
}
