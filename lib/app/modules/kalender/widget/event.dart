import 'dart:ui';

import 'package:flutter/material.dart';

// class Kegiatan {
//   Kegiatan(
//       this.namaKegiatan, this.from, this.to, this.background, this.isAllDay);

//   String namaKegiatan;
//   DateTime from;
//   DateTime to;
//   Color background;
//   bool isAllDay;
// }

class Kegiatan {
  String namaKegiatan;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;

  Kegiatan({
    required this.namaKegiatan,
    required this.from,
    required this.to,
    required this.background,
    required this.isAllDay,
  });

  factory Kegiatan.fromJson(Map<String, dynamic> json) {
    return Kegiatan(
      namaKegiatan: json['namaKegiatan'],
      from: DateTime.parse(json['tglMulai']),
      to: DateTime.parse(json['tglAkhir']),
      background: Colors.blue,
      isAllDay: false,
    );
  }
}
