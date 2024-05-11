class Berita {
  final String judulBerita;
  final String isiBerita;
  final String pembuat;
  final String tanggal;
  final String cover;

  Berita({
    required this.judulBerita,
    required this.isiBerita,
    required this.pembuat,
    required this.tanggal,
    required this.cover,
  });

  factory Berita.fromJson(Map<String, dynamic> json) {
    return Berita(
      judulBerita: json['judul_berita'],
      isiBerita: json['isi_berita'],
      pembuat: json['pembuat'],
      tanggal: json['tanggal'],
      cover: json['cover'],
    );
  }
}
