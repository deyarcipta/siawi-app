class JadwalHariIni {
  final String namaMapel;
  final String namaGuru;
  final String jamAwal;
  final String jamAkhir;
  final String waktuAwal;
  final String waktuAkhir;
  final String statusKehadiran;
  final String? fotoGuru;

  JadwalHariIni({
    required this.namaMapel,
    required this.namaGuru,
    required this.jamAwal,
    required this.jamAkhir,
    required this.waktuAwal,
    required this.waktuAkhir,
    required this.statusKehadiran,
    this.fotoGuru,
  });

  String? get fotoGuruUrl {
    if (fotoGuru == null || fotoGuru!.trim().isEmpty || fotoGuru == 'null') {
      return null;
    }
    if (fotoGuru!.startsWith('http://') || fotoGuru!.startsWith('https://')) {
      return fotoGuru;
    }
    return 'https://siawi.smkwisataindonesia.sch.id/storage/foto_guru/$fotoGuru';
  }

  factory JadwalHariIni.fromJson(Map<String, dynamic> json) {
    return JadwalHariIni(
      namaMapel: json['nama_mapel']?.toString() ?? '',
      namaGuru: json['nama_guru']?.toString() ?? '',
      jamAwal: json['jam_awal']?.toString() ?? '',
      jamAkhir: json['jam_akhir']?.toString() ?? '',
      waktuAwal: json['waktu_awal']?.toString() ?? '',
      waktuAkhir: json['waktu_akhir']?.toString() ?? '',
      statusKehadiran: json['status_kehadiran']?.toString() ?? '',
      fotoGuru: json['foto_guru']?.toString() ?? json['foto']?.toString(),
    );
  }
}
