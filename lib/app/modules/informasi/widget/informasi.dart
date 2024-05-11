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
      informasi: json['informasi'],
      ketInformasi: json['ket_informasi'],
      hari: json['hari'],
      tanggalAwal: json['tanggal_awal'],
      tanggalAkhir: json['tanggal_akhir'],
      file: json['file'],
    );
  }
}
