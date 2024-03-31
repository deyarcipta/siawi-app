class Informasi {
  String? title;
  String? hari;
  String? tanggal;
  String? syarat;

  Informasi(this.title, this.hari, this.tanggal, this.syarat);
  static List<Informasi> informasiData = [
    Informasi(
      "Sumatif Tengah Semester",
      "Senin - Jumat",
      "12 - 17 Februari 2024",
      "Melunasi Keuangan Sekolah",
    ),
    Informasi(
      "Sumatif Akhir Semester",
      "Senin - Jumat",
      "12 - 17 Februari 2024",
      "Melunasi Keuangan Sekolah",
    ),
    Informasi(
      "Pembagian Rapot",
      "Jumat",
      "20 Juni 2024",
      "Melunasi Keuangan Sekolah",
    ),
    // {
    //   "title": "Sumatif Tengah Semester",
    //   "hari": "Senin - Jumat",
    //   "tanggal": "12 - 17 Februari 2024",
    //   "syarat": "Melunasi Keuangan Sekolah",
    // },
    // {
    //   "title": "Sumatif Akhir Semester",
    //   "hari": "Senin - Jumat",
    //   "tanggal": "12 - 17 Juni 2024",
    //   "syarat": "Melunasi Keuangan Sekolah",
    // },
    // {
    //   "title": "Pembagian Rapot",
    //   "hari": "Jumat",
    //   "tanggal": "20 Juni 2024",
    //   "syarat": "Melunasi Keuangan Sekolah",
    // }
  ];
}
