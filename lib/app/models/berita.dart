class Berita {
  String bgImg;
  String name;
  String type;
  // List<String> imgs;
  Berita(
    this.bgImg,
    this.name,
    this.type,
    // this.imgs,
  );
  static List<Berita> generateBerita() {
    return [
      Berita(
        'assets/images/background2.jpg',
        'Berita 1',
        'Pendidikan',
      ),
      Berita(
        'assets/images/background2.jpg',
        'Berita 2',
        'Perkuliahaan',
      ),
      Berita(
        'assets/images/background2.jpg',
        'Berita 2',
        'Perkuliahaan',
      ),
    ];
  }
}
