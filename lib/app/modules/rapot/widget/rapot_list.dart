// Kelas RapotList
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/text.dart';

class RapotList {
  final String judul;
  final String pdf;

  RapotList({required this.judul, required this.pdf});

  // Data dari kelas RapotList
}

List<RapotList> myRapot = [
  RapotList(
    judul: 'Semester 1',
    pdf: "https://smkwisataindonesia.sch.id/file/contoh.pdf",
  ),
  RapotList(
    judul: 'Semester 2',
    pdf: "https://smkwisataindonesia.sch.id/file/contoh2.pdf",
  ),
  RapotList(
    judul: 'Semester 3',
    pdf: "https://smkwisataindonesia.sch.id/file/contoh2.pdf",
  ),
  RapotList(
    judul: 'Semester 4',
    pdf: "https://smkwisataindonesia.sch.id/file/contoh.pdf",
  ),
  RapotList(
    judul: 'Semester 5',
    pdf: "https://smkwisataindonesia.sch.id/file/contoh2.pdf",
  ),
  RapotList(
    judul: 'Semester 6',
    pdf: " https://smkwisataindonesia.sch.id/file/contoh.pdf",
  ),
];
