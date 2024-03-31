class Jadwal {
  String? namaMapel;
  String? jamMulai;
  String? jamSelesai;
  String? namaGuru;
  String? kodeMatkul;
  String? awalJam;
  String? akhirJam;
  Jadwal({
    this.namaMapel,
    this.jamMulai,
    this.jamSelesai,
    this.namaGuru,
    this.kodeMatkul,
    this.awalJam,
    this.akhirJam,
  });
  static List<Jadwal> generateSenin() {
    return [
      Jadwal(
        namaMapel: 'Matematika',
        namaGuru: 'Muhammad Makmur, S.Pd',
        awalJam: '1',
        akhirJam: '4',
        jamMulai: '06.30',
        jamSelesai: '09.30',
      ),
      Jadwal(
        namaMapel: 'Bahasa Indonesia',
        namaGuru: 'Saidah, S.Pd',
        awalJam: '1',
        akhirJam: '4',
        jamMulai: '06.30',
        jamSelesai: '09.30',
      ),
    ];
  }

  static List<Jadwal> generateSelasa() {
    return [
      Jadwal(
        namaMapel: 'Produktif TKJ',
        namaGuru: 'Muhammad Makmur, S.Pd',
        awalJam: '1',
        akhirJam: '4',
        jamMulai: '06.30',
        jamSelesai: '09.30',
      ),
      Jadwal(
        namaMapel: 'Bahasa Indonesia',
        namaGuru: 'Saidah, S.Pd',
        awalJam: '1',
        akhirJam: '4',
        jamMulai: '06.30',
        jamSelesai: '09.30',
      ),
    ];
  }

  static List<Jadwal> generateRabu() {
    return [
      Jadwal(
        namaMapel: 'Bahasa Inggris',
        namaGuru: 'Muhammad Makmur, S.Pd',
        awalJam: '1',
        akhirJam: '4',
        jamMulai: '06.30',
        jamSelesai: '09.30',
      ),
      Jadwal(
        namaMapel: 'Bahasa Indonesia',
        namaGuru: 'Saidah, S.Pd',
        awalJam: '1',
        akhirJam: '4',
        jamMulai: '06.30',
        jamSelesai: '09.30',
      ),
    ];
  }

  static List<Jadwal> generateKamis() {
    return [
      Jadwal(
        namaMapel: 'Pendidikan Agama Islam',
        namaGuru: 'Muhammad Makmur, S.Pd',
        awalJam: '1',
        akhirJam: '4',
        jamMulai: '06.30',
        jamSelesai: '09.30',
      ),
      Jadwal(
        namaMapel: 'Bahasa Indonesia',
        namaGuru: 'Saidah, S.Pd',
        awalJam: '1',
        akhirJam: '4',
        jamMulai: '06.30',
        jamSelesai: '09.30',
      ),
    ];
  }

  static List<Jadwal> generateJumat() {
    return [
      Jadwal(
        namaMapel: 'Pendidikan Kewarganegaraan',
        namaGuru: 'Muhammad Makmur, S.Pd',
        awalJam: '1',
        akhirJam: '4',
        jamMulai: '06.30',
        jamSelesai: '09.30',
      ),
      Jadwal(
        namaMapel: 'Bahasa Indonesia',
        namaGuru: 'Saidah, S.Pd',
        awalJam: '1',
        akhirJam: '4',
        jamMulai: '06.30',
        jamSelesai: '09.30',
      ),
    ];
  }
}
