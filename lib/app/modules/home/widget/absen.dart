// import 'dart:convert';
// import 'dart:ffi';

import 'package:flutter/material.dart';
// import 'package:siawi_app/app/models/api.dart';

// import 'berita_terbaru.dart';
// import 'menu.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:siawi_app/utils/colors.dart';
// import 'package:percent_indicator/percent_indicator.dart';

class Absen extends StatefulWidget {
  Absen({Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const DataMahasiswa(this.signOut, {super.key});

  @override
  State<Absen> createState() => _AbsenState();
}

class _AbsenState extends State<Absen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Wrap(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Kehadiran Hari Ini",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.maxFinite,
                height: size.height * .06,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hari ini kamu masuk sekolah",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Semangat menggapai cita-cita mu",
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
