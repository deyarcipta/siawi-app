import 'package:flutter/material.dart';

class AbsenList {
  final String keterangan;
  final String status;
  final String tanggal;
  final String hari;
  final Color warna;
  final String jamMasuk;
  final String jamPulang;
  final String tipeAbsen;

  AbsenList({
    required this.keterangan,
    required this.tanggal,
    required this.hari,
    required this.warna,
    required this.jamMasuk,
    required this.jamPulang,
    required this.tipeAbsen,
  }) : status = _getStatus(keterangan);

  static String _getStatus(String keterangan) {
    if (keterangan.toLowerCase() == 'sakit' ||
        keterangan.toLowerCase() == 'izin' ||
        keterangan.toLowerCase() == 'alfa') {
      return 'Tidak masuk sekolah ($keterangan)'; // Jika sakit, izin, atau alfa
    } else {
      return 'Masuk sekolah'; // Jika hadir
    }
  }

  factory AbsenList.fromJson(Map<String, dynamic> json) {
    Color parseColor(String colorString) {
      switch (colorString.toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'blue':
          return Colors.blue;
        // Tambahkan kasus lain sesuai kebutuhan
        default:
          return Colors.black; // Warna default jika tidak cocok
      }
    }

    return AbsenList(
      keterangan: json['kehadiran'],
      tanggal: json['tanggal'],
      hari: json['hari'],
      warna: parseColor(json['warna']),
      jamMasuk: json['jam_masuk'] ?? '-',
      jamPulang: json['jam_pulang'] ?? '-',
      tipeAbsen: json['tipe_absen'] ?? 'Manual oleh Guru',
    );
  }
}

// import 'package:flutter/material.dart';
// // import 'package:flutter/src/widgets/text.dart';

// class AbsenList {
//   final String tanggal;
//   final String keterangan;
//   final String img;
//   final Color warna;

//   AbsenList(
//       {required this.tanggal,
//       required this.keterangan,
//       required this.img,
//       required this.warna});

//   // Data dari kelas AbsenList
// }

// List<AbsenList> myData = [
//   AbsenList(
//       tanggal: 'Rabu, 12 Januari 2024',
//       keterangan: 'Masuk Sekolah',
//       img: "assets/icon/absen.png",
//       warna: Colors.blue),
//   AbsenList(
//       tanggal: 'Rabu, 12 Januari 2024',
//       keterangan: 'Masuk Sekolah',
//       img: "assets/icon/absen.png",
//       warna: Colors.blue),
//   AbsenList(
//       tanggal: 'Rabu, 12 Januari 2024',
//       keterangan: 'Tidak Masuk Sekolah',
//       img: "assets/icon/absen.png",
//       warna: Colors.red),
//   AbsenList(
//       tanggal: 'Rabu, 12 Januari 2024',
//       keterangan: 'Masuk Sekolah',
//       img: "assets/icon/absen.png",
//       warna: Colors.blue),
//   AbsenList(
//       tanggal: 'Rabu, 12 Januari 2024',
//       keterangan: 'Masuk Sekolah',
//       img: "assets/icon/absen.png",
//       warna: Colors.blue),
//   AbsenList(
//       tanggal: 'Rabu, 12 Januari 2024',
//       keterangan: 'Masuk Sekolah',
//       img: "assets/icon/absen.png",
//       warna: Colors.blue),
// ];
