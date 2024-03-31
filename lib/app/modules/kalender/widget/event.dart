import 'dart:ui';

class Kegiatan {
  Kegiatan(
      this.namaKegiatan, this.from, this.to, this.background, this.isAllDay);

  String namaKegiatan;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
