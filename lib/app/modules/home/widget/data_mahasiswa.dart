// import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:siawi_app/app/models/api.dart';

// import 'berita_terbaru.dart';
// import 'menu.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
import 'package:siawi_app/utils/colors.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DataMahasiswa extends StatefulWidget {
  DataMahasiswa({Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const DataMahasiswa(this.signOut, {super.key});

  @override
  State<DataMahasiswa> createState() => _DataMahasiswaState();
}

class _DataMahasiswaState extends State<DataMahasiswa> {
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
                            _buildData('Teknik Jaringan Komputer & Tel.'),
                            _buildTitleData('NIS / NISN'),
                            _buildData('12901 / 001268528'),
                            _buildTitleData('Kelas / Semester'),
                            _buildData('XII - TJKT / 5'),
                            _buildTitleData('Rata-Rata Rapot'),
                            Row(
                              children: [
                                _buildRata('80'),
                                _buildIcon(Icons.keyboard_arrow_up)
                              ],
                            ),
                          ],
                        ),
                        CircularPercentIndicator(
                          animation: true,
                          radius: 70.0,
                          lineWidth: 12.0,
                          percent: 0.9,
                          center: new Text(
                            "90",
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
