import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/app/data/api_service.dart';
import 'dart:convert';
import 'package:siawi_app/app/models/jadwal.dart';
import 'package:siawi_app/utils/colors.dart';

class JadwalList extends StatelessWidget {
  final VoidCallback signOut;
  final String scrollKey;
  final String hari;

  JadwalList(
      {required this.scrollKey, required this.hari, required this.signOut});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getIdSiswa(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final String? idSiswa = snapshot.data;
          if (idSiswa == null) {
            return Center(child: Text('Error: idSiswa is null'));
          }
          return FutureBuilder<List<Jadwal>>(
            future: fetchDataFromAPI(idSiswa, hari),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Tidak ada jadwal'));
              } else {
                final List<Jadwal> jadwals = snapshot.data!;
                if (jadwals.isEmpty) {
                  return Center(child: Text('Tidak ada jadwal'));
                } else {
                  return ListView.separated(
                    key: PageStorageKey(scrollKey),
                    padding:
                        const EdgeInsets.only(top: 15, right: 20, left: 20),
                    // itemBuilder: (_, index) => BidderCard(jadwalList[index]),
                    itemBuilder: (_, index) => Container(
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          // side: BorderSide(width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        tileColor: AppColors.thirdColor,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: Image.asset(
                          'assets/icon/jadwal.png',
                          width: 25,
                          height: 25,
                        ),
                        title: Text(
                            "Jam ke ${jadwals[index].jamAwal} s/d ${jadwals[index].jamAkhir}"),
                        titleTextStyle: TextStyle(
                            fontSize: 10,
                            color: AppColors.sixColor,
                            fontWeight: FontWeight.w500),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${jadwals[index].namaMapel.length > 25 ? jadwals[index].namaMapel.substring(0, 25) + '...' : jadwals[index].namaMapel}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  "${jadwals[index].namaGuru}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "${jadwals[index].waktuAwal} s/d ${jadwals[index].waktuAkhir}",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.mainColor,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    separatorBuilder: (_, index) => SizedBox(height: 15),
                    itemCount: jadwals.length,
                  );
                }
              }
            },
          );
        }
      },
    );
  }

  Future<String?> getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? idSiswa = preferences.getString('idSiswa');
    return idSiswa;
  }

  Future<List<Jadwal>> fetchDataFromAPI(String idSiswa, String hari) async {
    String encodedIdSiswa = Uri.encodeComponent(idSiswa);
    String encodedHari = Uri.encodeComponent(hari);

    try {
      final responseData = await ApiService.get('/jadwal/$encodedIdSiswa/$encodedHari');
      if (responseData != null && responseData['data'] != null && responseData['data'][hari] != null) {
        // Ambil data jadwal berdasarkan hari dari respons
        List<dynamic> jadwalsByDay = responseData['data'][hari];

        // Ubah data jadwal menjadi model Jadwal
        List<Jadwal> jadwals =
            jadwalsByDay.map((data) => Jadwal.fromJson(data)).toList();
        return jadwals;
      } else {
        throw Exception('Data jadwal tidak lengkap');
      }
    } catch (e) {
      throw Exception('Failed to load data from API: $e');
    }
  }
}
