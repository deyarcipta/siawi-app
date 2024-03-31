class JadwalHariIni {
  String mapel;
  String jamMulai;
  String jamAkhir;
  String waktuMulai;
  String waktuAkhir;
  String guru;
  // List<String> imgs;
  JadwalHariIni(
    this.mapel,
    this.jamMulai,
    this.jamAkhir,
    this.waktuMulai,
    this.waktuAkhir,
    this.guru,
    // this.imgs,
  );
  static List<JadwalHariIni> generateJadwalHariIni() {
    return [
      JadwalHariIni(
        'Bahasa Indonesia',
        '1',
        '4',
        '06.30',
        '09.30',
        'Saidah, S.Pd.',
      ),
      JadwalHariIni(
        'Matematika',
        '5',
        '8',
        '10.00',
        '11.30',
        'Muhammad Makmur, S.Pd.',
      ),
      JadwalHariIni(
        'Produktif TKJ',
        '9',
        '11',
        '12.30',
        '14.30',
        'Deyar Cipta Rizky',
      ),
    ];
  }
}
