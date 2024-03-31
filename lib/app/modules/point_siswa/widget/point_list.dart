// Kelas PointList
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/text.dart';

class PointList {
  final String tanggal;
  final String keterangan;
  final String img;
  final String point;

  PointList(
      {required this.tanggal,
      required this.keterangan,
      required this.img,
      required this.point});

  // Data dari kelas PointList
}

List<PointList> myData = [
  PointList(
    tanggal: 'Rabu, 12 Januari 2024',
    keterangan: 'Masuk Sekolah',
    img: "assets/icon/point1.png",
    point: '+5 Point',
  ),
  PointList(
    tanggal: 'Rabu, 12 Januari 2024',
    keterangan: 'Masuk Sekolah',
    img: "assets/icon/point1.png",
    point: '+5 Point',
  ),
  PointList(
    tanggal: 'Rabu, 12 Januari 2024',
    keterangan: 'Tidak Masuk Sekolah',
    img: "assets/icon/point1.png",
    point: '',
  ),
  PointList(
    tanggal: 'Rabu, 12 Januari 2024',
    keterangan: 'Masuk Sekolah',
    img: "assets/icon/point1.png",
    point: '+5 Point',
  ),
  PointList(
    tanggal: 'Rabu, 12 Januari 2024',
    keterangan: 'Masuk Sekolah',
    img: "assets/icon/point1.png",
    point: '+5 Point',
  ),
  PointList(
    tanggal: 'Rabu, 12 Januari 2024',
    keterangan: 'Masuk Sekolah',
    img: "assets/icon/point1.png",
    point: '+5 Point',
  ),
];
