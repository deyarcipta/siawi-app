class RapotList {
  final String semester;
  late String fileRapot;

  RapotList({
    required this.semester,
    required this.fileRapot,
  });

  factory RapotList.fromJson(Map<String, dynamic> json) {
    return RapotList(
      semester: json['semester'],
      fileRapot: json['file_rapot'],
    );
  }
}
