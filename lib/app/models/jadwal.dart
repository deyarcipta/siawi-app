class Jadwal {
  String namaMapel;
  String namaGuru;
  String jamAwal;
  String jamAkhir;
  String waktuAwal;
  String waktuAkhir;
  final String statusKehadiran;
  String hari;
  String? fotoGuru;

  Jadwal({
    required this.namaMapel,
    required this.namaGuru,
    required this.jamAwal,
    required this.jamAkhir,
    required this.waktuAwal,
    required this.waktuAkhir,
    required this.statusKehadiran,
    required this.hari,
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

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      namaMapel: json['nama_mapel'] ?? '',
      namaGuru: json['nama_guru'] ?? '',
      jamAwal: json['jam_awal'] ?? '',
      jamAkhir: json['jam_akhir'] ?? '',
      waktuAwal: json['waktu_awal'] ?? '',
      waktuAkhir: json['waktu_akhir'] ?? '',
      statusKehadiran: json['status_kehadiran'] ?? '',
      hari: json['hari'] ?? '', // Ubah menjadi 'hari'
      fotoGuru: json['foto_guru']?.toString() ?? json['foto']?.toString(),
    );
  }
}
