// Kelas AbsenList
import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/text.dart';

class AbsenList {
  final String tanggal;
  final String keterangan;
  final String img;
  final Color warna;

  AbsenList(
      {required this.tanggal,
      required this.keterangan,
      required this.img,
      required this.warna});

  // Data dari kelas AbsenList
}

List<AbsenList> myData = [
  AbsenList(
      tanggal: 'Rabu, 12 Januari 2024',
      keterangan: 'Masuk Sekolah',
      img: "assets/icon/absen.png",
      warna: Colors.blue),
  AbsenList(
      tanggal: 'Rabu, 12 Januari 2024',
      keterangan: 'Masuk Sekolah',
      img: "assets/icon/absen.png",
      warna: Colors.blue),
  AbsenList(
      tanggal: 'Rabu, 12 Januari 2024',
      keterangan: 'Tidak Masuk Sekolah',
      img: "assets/icon/absen.png",
      warna: Colors.red),
  AbsenList(
      tanggal: 'Rabu, 12 Januari 2024',
      keterangan: 'Masuk Sekolah',
      img: "assets/icon/absen.png",
      warna: Colors.blue),
  AbsenList(
      tanggal: 'Rabu, 12 Januari 2024',
      keterangan: 'Masuk Sekolah',
      img: "assets/icon/absen.png",
      warna: Colors.blue),
  AbsenList(
      tanggal: 'Rabu, 12 Januari 2024',
      keterangan: 'Masuk Sekolah',
      img: "assets/icon/absen.png",
      warna: Colors.blue),
];
