import 'package:flutter/material.dart';

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

  factory Kegiatan.fromJson(Map<String, dynamic> json, [int index = 0]) {
    DateTime parseDate(dynamic dateVal) {
      if (dateVal == null) return DateTime.now();
      try {
        return DateTime.parse(dateVal.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    const palette = [
      Color(0xFF4C3EC7), // Indigo SIAWI
      Color(0xFF059669), // Emerald
      Color(0xFF0284C7), // Sky Blue
      Color(0xFFD97706), // Amber
      Color(0xFF7C3AED), // Violet
      Color(0xFFE11D48), // Rose
    ];

    return Kegiatan(
      namaKegiatan: json['namaKegiatan']?.toString() ?? 'Kegiatan Sekolah',
      from: parseDate(json['tglMulai']),
      to: parseDate(json['tglAkhir']),
      background: palette[index % palette.length],
      isAllDay: false,
    );
  }
}
