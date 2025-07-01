class DokumenList {
  late String jenis_dokumen;
  late String fileDokumen;

  DokumenList({
    required this.jenis_dokumen,
    required this.fileDokumen,
  });

  factory DokumenList.fromJson(Map<String, dynamic> json) {
    return DokumenList(
      jenis_dokumen: json['jenis_dokumen'],
      fileDokumen: json['file_dokumen'],
    );
  }
}
