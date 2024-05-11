class PointList {
  final String namaPoint;
  final String skorPoint;
  final String tanggal;
  final String waktu;
  final String hari;

  PointList({
    required this.namaPoint,
    required this.skorPoint,
    required this.tanggal,
    required this.waktu,
    required this.hari,
  });

  factory PointList.fromJson(Map<String, dynamic> json) {
    return PointList(
      namaPoint: json['nama_point'],
      skorPoint: json['skor_point'],
      tanggal: json['tanggal'],
      waktu: json['waktu'],
      hari: json['hari'],
    );
  }
}
