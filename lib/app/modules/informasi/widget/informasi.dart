class Informasi {
  final String informasi;
  final String ketInformasi;
  final String hari;
  final String tanggalAwal;
  final String tanggalAkhir;
  final String file;

  Informasi({
    required this.informasi,
    required this.ketInformasi,
    required this.hari,
    required this.tanggalAwal,
    required this.tanggalAkhir,
    required this.file,
  });

  factory Informasi.fromJson(Map<String, dynamic> json) {
    return Informasi(
      informasi: json['informasi']?.toString() ?? '',
      ketInformasi: json['ket_informasi']?.toString() ?? '',
      hari: json['hari']?.toString() ?? '',
      tanggalAwal: json['tanggal_awal']?.toString() ?? '',
      tanggalAkhir: json['tanggal_akhir']?.toString() ?? '',
      file: json['file']?.toString() ?? '',
    );
  }
}
