class Jadwal {
  String namaMapel;
  String namaGuru;
  String jamAwal;
  String jamAkhir;
  String waktuAwal;
  String waktuAkhir;
  String hari;

  Jadwal({
    required this.namaMapel,
    required this.namaGuru,
    required this.jamAwal,
    required this.jamAkhir,
    required this.waktuAwal,
    required this.waktuAkhir,
    required this.hari,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      namaMapel: json['nama_mapel'] ?? '',
      namaGuru: json['nama_guru'] ?? '',
      jamAwal: json['jam_awal'] ?? '',
      jamAkhir: json['jam_akhir'] ?? '',
      waktuAwal: json['waktu_awal'] ?? '',
      waktuAkhir: json['waktu_akhir'] ?? '',
      hari: json['hari'] ?? '', // Ubah menjadi 'hari'
    );
  }
}
