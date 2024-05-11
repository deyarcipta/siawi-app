class JadwalHariIni {
  final String namaMapel;
  final String namaGuru;
  final String jamAwal;
  final String jamAkhir;
  final String waktuAwal;
  final String waktuAkhir;

  JadwalHariIni({
    required this.namaMapel,
    required this.namaGuru,
    required this.jamAwal,
    required this.jamAkhir,
    required this.waktuAwal,
    required this.waktuAkhir,
  });

  factory JadwalHariIni.fromJson(Map<String, dynamic> json) {
    return JadwalHariIni(
      namaMapel: json['nama_mapel'],
      namaGuru: json['nama_guru'],
      jamAwal: json['jam_awal'],
      jamAkhir: json['jam_akhir'],
      waktuAwal: json['waktu_awal'],
      waktuAkhir: json['waktu_akhir'],
    );
  }
}
