class ModulList {
  final String namaMapel;
  final List<ModulItem> modulItems;

  ModulList({
    required this.namaMapel,
    required this.modulItems,
  });

  factory ModulList.fromJson(Map<String, dynamic> json) {
    List<dynamic> modulJson = json['modul'];
    List<ModulItem> modulItems =
        modulJson.map((item) => ModulItem.fromJson(item)).toList();

    return ModulList(
      namaMapel: json[
          'namaMapel'], // Perubahan disini, nama kunci pada JSON adalah 'namaMapel'
      modulItems: modulItems,
    );
  }
}

class ModulItem {
  final String namaModul;
  final String fileModul;

  ModulItem({
    required this.namaModul,
    required this.fileModul,
  });

  factory ModulItem.fromJson(Map<String, dynamic> json) {
    return ModulItem(
      namaModul: json['namaModul'],
      fileModul: json['file_modul'],
    );
  }
}
