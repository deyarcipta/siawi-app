class JadwalHariIni {
  final String namaMapel;
  final String namaGuru;
  final String jamAwal;
  final String jamAkhir;
  final String waktuAwal;
  final String waktuAkhir;
  final String statusKehadiran;

  JadwalHariIni({
    required this.namaMapel,
    required this.namaGuru,
    required this.jamAwal,
    required this.jamAkhir,
    required this.waktuAwal,
    required this.waktuAkhir,
    required this.statusKehadiran,
  });

  factory JadwalHariIni.fromJson(Map<String, dynamic> json) {
    return JadwalHariIni(
      namaMapel: json['nama_mapel']?.toString() ?? '',
      namaGuru: json['nama_guru']?.toString() ?? '',
      jamAwal: json['jam_awal']?.toString() ?? '',
      jamAkhir: json['jam_akhir']?.toString() ?? '',
      waktuAwal: json['waktu_awal']?.toString() ?? '',
      waktuAkhir: json['waktu_akhir']?.toString() ?? '',
      statusKehadiran: json['status_kehadiran']?.toString() ?? '',
    );
  }
}
