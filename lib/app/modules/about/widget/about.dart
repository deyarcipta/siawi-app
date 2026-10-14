class About {
  String? title;
  String? tentang;

  About(this.title, this.tentang);

  static const String visi =
      "Menghasilkan peserta didik yang berwawasan global, mandiri, dan unggul di bidang Perhotelan, Kuliner, serta Teknologi Informasi dengan dilandasi akhlak mulia.";

  static const List<String> misiList = [
    "Menanamkan keimanan, ketaqwaan, dan keikhlasan kepada Tuhan Yang Maha Esa.",
    "Menyelenggarakan pendidikan dan pelatihan kejuruan yang efektif, efisien, dan bermutu tinggi.",
    "Membekali peserta didik secara maksimal untuk mengembangkan potensi dan karakter kepemimpinan diri.",
    "Meningkatkan kompetensi pendidik dan tenaga kependidikan secara berkelanjutan.",
    "Menjalin kemitraan strategis dengan Dunia Usaha dan Dunia Industri (DUDI) skala nasional maupun internasional.",
    "Meningkatkan pelayanan pendidikan terpadu dengan menyelaraskan kemajuan teknologi digital.",
  ];

  static const List<Map<String, dynamic>> jurusanList = [
    {
      "kode": "PH",
      "nama": "Perhotelan",
      "deskripsi": "Front Office, Housekeeping, Laundry & F&B Service berstandar hotel berbintang.",
      "icon": "hotel_rounded",
    },
    {
      "kode": "KUL",
      "nama": "Kuliner",
      "deskripsi": "Seni tata boga, pengolahan masakan nusantara, kontinental, pastry & bakery.",
      "icon": "restaurant_rounded",
    },
    {
      "kode": "TJKT",
      "nama": "Teknik Jaringan Komputer & Telekomunikasi",
      "deskripsi": "Infrastruktur jaringan kabel/nirkabel, administrasi server, fiber optic & cyber security.",
      "icon": "computer_rounded",
    },
  ];

  static List<About> aboutData = [
    About(
      "Tentang Sekolah",
      "SMK Wisata Indonesia merupakan sekolah kejuruan berprestasi yang berdedikasi mencetak lulusan siap kerja, wirausaha, dan berdaya saing global melalui 3 kompetensi keahlian unggulan: Perhotelan, Kuliner, dan Teknik Jaringan Komputer & Telekomunikasi.",
    ),
    About(
      "Tentang Aplikasi",
      "Aplikasi Sistem Informasi Akademik SMK Wisata Indonesia (SIAWI) merupakan platform digital terpadu yang memfasilitasi siswa dan orang tua dalam memantau kehadiran biometrik, jadwal belajar, laporan kedisiplinan, nilai akademik, hingga layanan pengajuan PKL secara realtime.",
    ),
  ];
}
