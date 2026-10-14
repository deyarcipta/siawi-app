import 'package:flutter/material.dart';

class AbsenList {
  final String keterangan; // 'hadir', 'sakit', 'izin', 'alfa'
  final String status;
  final String tanggal;
  final String hari;
  final Color warna;
  final String jamMasuk;
  final String jamPulang;
  final String tipeAbsen;
  final String? catatan;
  final String? tipeMasuk;
  final String? tipePulang;

  AbsenList({
    required this.keterangan,
    required this.tanggal,
    required this.hari,
    required this.warna,
    required this.jamMasuk,
    required this.jamPulang,
    required this.tipeAbsen,
    this.catatan,
    this.tipeMasuk,
    this.tipePulang,
  }) : status = _getStatus(keterangan);

  bool get isHadir => keterangan.toLowerCase() == 'hadir';
  bool get isSakit => keterangan.toLowerCase() == 'sakit';
  bool get isIzin => keterangan.toLowerCase() == 'izin';
  bool get isAlfa => keterangan.toLowerCase() == 'alfa';

  // Cek apakah sudah absen pulang
  bool get hasPulang =>
      jamPulang.isNotEmpty && jamPulang != '-' && jamPulang != '--:--';

  // Cek apakah pulang menggunakan mesin biometrik
  bool get isPulangMesin =>
      hasPulang &&
      ((tipePulang ?? '').toLowerCase().contains('mesin') ||
          (tipePulang ?? '').toLowerCase().contains('face') ||
          (tipePulang ?? '').toLowerCase().contains('biometrik'));

  // Deteksi jika kehadiran adalah hadir dan masuknya dilakukan secara manual
  bool get isManualHadir {
    if (!isHadir) return false;
    final tm = (tipeMasuk ?? '').toLowerCase().trim();
    final ta = tipeAbsen.toLowerCase().trim();
    if (tm == 'manual' || ta.contains('manual')) return true;
    if (!ta.contains('otomatis') &&
        !ta.contains('face') &&
        !ta.contains('biometrik') &&
        !ta.contains('piket') &&
        !ta.contains('mesin')) {
      return true;
    }
    return false;
  }

  // Teks deskripsi keterangan dinamis (cerdas saat masuk manual & pulang mesin)
  String get keteranganDeskripsi {
    final cleanCatatan = (catatan ?? '').trim();
    final hasValidCatatan = cleanCatatan.isNotEmpty && cleanCatatan != '-';

    if (hasValidCatatan) {
      return cleanCatatan;
    }

    if (isManualHadir) {
      if (hasPulang) {
        return isPulangMesin
            ? "Masuk dicatat manual Guru • Pulang tap mesin Biometrik ($jamPulang)."
            : "Masuk dicatat manual Guru • Pulang tercatat ($jamPulang).";
      } else {
        return "Absensi masuk dicatat secara manual oleh Guru / Wali Kelas.";
      }
    } else if (isSakit) {
      return "Izin sakit telah diverifikasi oleh pihak sekolah.";
    } else if (isIzin) {
      return "Izin telah tercatat dan disetujui pihak sekolah.";
    } else if (isAlfa) {
      return "Siswa tidak hadir tanpa konfirmasi kehadiran.";
    } else {
      if (hasPulang) {
        return "Kehadiran masuk & pulang tercatat via mesin Biometrik Face Recognition.";
      } else {
        return "Kehadiran masuk tercatat via mesin Biometrik Face Recognition.";
      }
    }
  }

  static String _getStatus(String keterangan) {
    switch (keterangan.toLowerCase()) {
      case 'sakit':
        return 'Sakit (Izin Medis)';
      case 'izin':
        return 'Izin (Keperluan)';
      case 'alfa':
        return 'Tanpa Keterangan (Alfa)';
      default:
        return 'Hadir Tepat Waktu';
    }
  }

  static Color getStatusColor(String keterangan) {
    switch (keterangan.toLowerCase()) {
      case 'hadir':
        return const Color(0xFF10B981); // Emerald Green
      case 'sakit':
        return const Color(0xFFF59E0B); // Amber
      case 'izin':
        return const Color(0xFF0EA5E9); // Sky Blue
      case 'alfa':
        return const Color(0xFFEF4444); // Red Rose
      default:
        return const Color(0xFF64748B);
    }
  }

  factory AbsenList.fromJson(Map<String, dynamic> json) {
    String kehadiran = (json['kehadiran'] ?? 'hadir').toString();
    Color statusColor = getStatusColor(kehadiran);

    return AbsenList(
      keterangan: kehadiran,
      tanggal: json['tanggal'] ?? '-',
      hari: json['hari'] ?? '-',
      warna: statusColor,
      jamMasuk: json['jam_masuk'] ?? '-',
      jamPulang: json['jam_pulang'] ?? '-',
      tipeAbsen: json['tipe_absen'] ?? 'Manual oleh Guru',
      catatan: json['ket']?.toString(),
      tipeMasuk: json['tipe_masuk']?.toString(),
      tipePulang: json['tipe_pulang']?.toString(),
    );
  }
}
