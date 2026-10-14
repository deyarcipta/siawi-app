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
      namaPoint: json['nama_point']?.toString() ?? '',
      skorPoint: json['skor_point']?.toString() ?? '0',
      tanggal: json['tanggal']?.toString() ?? '',
      waktu: json['waktu']?.toString() ?? '',
      hari: json['hari']?.toString() ?? '',
    );
  }
}
