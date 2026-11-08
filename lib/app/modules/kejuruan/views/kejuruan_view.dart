import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/modules/kejuruan/subviews/jadwal_praktik_view.dart';
import 'package:siawi_app/app/modules/kejuruan/subviews/modul_praktik_view.dart';
import 'package:siawi_app/app/modules/kejuruan/subviews/nilai_praktik_view.dart';
import 'package:siawi_app/app/modules/kejuruan/subviews/uji_kompetensi_view.dart';
import 'package:siawi_app/app/modules/kejuruan/subviews/sertifikat_portofolio_view.dart';
import 'package:siawi_app/app/modules/kejuruan/subviews/tes_teori_tkk_view.dart';
import 'package:siawi_app/app/modules/kejuruan/subviews/peminjaman_alat_view.dart';
import 'package:siawi_app/app/modules/kejuruan/subviews/presensi_bengkel_view.dart';
import 'package:siawi_app/app/modules/kejuruan/subviews/detail_modul_praktik_view.dart';
import 'package:url_launcher/url_launcher.dart';

class KejuruanView extends StatefulWidget {
  final VoidCallback? signOut;
  final String? idSiswa;
  const KejuruanView({this.signOut, this.idSiswa, super.key});

  @override
  State<KejuruanView> createState() => _KejuruanViewState();
}

class _KejuruanViewState extends State<KejuruanView> {
  bool isLoading = true;
  String? idSiswa;

  // Header & Student data
  String namaSiswa = "Siswa";
  String namaJurusan = "Program Keahlian";
  String namaKelas = "Kelas Siswa";
  String subtitle = "Program Keahlian · Kelas Siswa";

  // Praktik berikutnya data
  Map<String, dynamic>? praktikBerikutnya;
  List<Map<String, dynamic>> praktikHariIniList = [];
  int? _selectedSesiIndex;

  // Stats & Remedial data
  String kehadiranPraktik = "0%";
  String kehadiranSesi = "(0/0 Sesi)";
  String kehadiranBadge = "-";
  String rataRataNilai = "0";
  String predikatNilai = "-";
  String kompetensiBadge = "-";
  String statusRemedialModul = "";
  String remedialTopik = "";
  String remedialTarget = "";

  // Peminjaman Alat data
  Map<String, dynamic>? peminjamanAlat;

  // Job sheets data
  List<Map<String, dynamic>> jobSheets = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _getTodayName() {
    switch (DateTime.now().weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
      default:
        return 'Minggu';
    }
  }

  String _getFormattedDateToday() {
    final now = DateTime.now();
    const List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${_getTodayName()}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  int? _parseTimeToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty || timeStr == '-') return null;
    final clean = timeStr.trim().replaceAll('.', ':');
    final parts = clean.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0].trim());
    final m = int.tryParse(parts[1].trim().substring(0, parts[1].trim().length >= 2 ? 2 : parts[1].trim().length));
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  Map<String, String> _extractStartEndTime(Map<String, dynamic> item) {
    String jamMulai = (item['jam_mulai'] ?? '').toString().trim();
    String jamSelesai = (item['jam_selesai'] ?? '').toString().trim();

    if (jamMulai.isEmpty || jamSelesai.isEmpty || jamMulai == '-') {
      final String rawJadwal =
          (item['jadwal'] ?? item['jam'] ?? '').toString().trim();
      if (rawJadwal.contains('-')) {
        final parts = rawJadwal.split('-');
        if (parts.length >= 2) {
          jamMulai = parts[0].trim();
          jamSelesai = parts[1].replaceAll('WIB', '').trim();
        }
      }
    }
    if (jamMulai.length >= 5) jamMulai = jamMulai.substring(0, 5);
    if (jamSelesai.length >= 5) jamSelesai = jamSelesai.substring(0, 5);
    return {
      'jam_mulai': jamMulai.isEmpty ? '-' : jamMulai,
      'jam_selesai': jamSelesai.isEmpty ? '-' : jamSelesai,
    };
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    idSiswa = widget.idSiswa ?? prefs.getString('idSiswa');

    // 1. Coba baca data dari cache profil siswa yang ada
    if (idSiswa != null) {
      String? cachedName = prefs.getString('namaSiswa');
      if (cachedName != null && cachedName.isNotEmpty) {
        namaSiswa = cachedName;
      }
      String? headerCache = prefs.getString('cached_student_header_$idSiswa');
      if (headerCache != null && headerCache.isNotEmpty) {
        try {
          var cMap = jsonDecode(headerCache);
          if (cMap['namaSiswa'] != null &&
              cMap['namaSiswa'].toString().isNotEmpty) {
            namaSiswa = cMap['namaSiswa'].toString();
          }
          if (cMap['namaJurusan'] != null &&
              cMap['namaJurusan'].toString().isNotEmpty) {
            namaJurusan = cMap['namaJurusan'].toString();
          }
          if (cMap['namaKelas'] != null &&
              cMap['namaKelas'].toString().isNotEmpty) {
            namaKelas = cMap['namaKelas'].toString();
          }
          subtitle = "$namaJurusan · $namaKelas";
        } catch (_) {}
      }
    }

    // 2. Fetch live data dari API di siawi-admin
    if (idSiswa != null) {
      try {
        final res = await ApiService.get(
          '/kejuruan/dashboard/$idSiswa',
          forceRefresh: true,
          silent: true,
        );
        if (res != null && res['success'] == true && res['data'] != null) {
          final data = res['data'];
          if (data['nama_siswa'] != null) namaSiswa = data['nama_siswa'];
          if (data['subtitle'] != null) subtitle = data['subtitle'];
          if (data['jurusan'] != null) namaJurusan = data['jurusan'];
          if (data['kelas'] != null) namaKelas = data['kelas'];
          praktikBerikutnya = data['praktik_berikutnya'] != null
              ? Map<String, dynamic>.from(data['praktik_berikutnya'])
              : null;
          if (data['praktik_hari_ini'] is List &&
              (data['praktik_hari_ini'] as List).isNotEmpty) {
            final rawList = (data['praktik_hari_ini'] as List)
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
            // Cek apakah jadwal yang dikembalikan benar-benar hari ini
            final firstBadge =
                (rawList.first['badge'] ?? rawList.first['badge_waktu'] ?? '')
                    .toString()
                    .toLowerCase();
            if (firstBadge.contains('hari ini')) {
              praktikHariIniList = rawList;
            } else {
              praktikHariIniList = [];
            }
          } else if (praktikBerikutnya != null) {
            final badgeStr =
                (praktikBerikutnya!['badge'] ??
                        praktikBerikutnya!['badge_waktu'] ??
                        '')
                    .toString()
                    .toLowerCase();
            if (badgeStr.contains('hari ini')) {
              praktikHariIniList = [praktikBerikutnya!];
            } else {
              praktikHariIniList = [];
            }
          } else {
            praktikHariIniList = [];
          }
          if (data['stats'] != null) {
            var stats = data['stats'];
            kehadiranPraktik = stats['kehadiran_praktik'] ?? "0%";
            kehadiranSesi = stats['kehadiran_sesi'] ?? "(0/0 Sesi)";
            kehadiranBadge = stats['kehadiran_badge'] ?? "-";
            rataRataNilai = stats['rata_rata_nilai']?.toString() ?? "0";
            predikatNilai = stats['predikat'] ?? "-";
            kompetensiBadge = stats['kompetensi_badge'] ?? "-";
            statusRemedialModul = stats['remedial_modul'] ?? "";
            remedialTopik = stats['remedial_topik'] ?? "";
            remedialTarget = stats['remedial_kkm'] ?? "";
          }
          peminjamanAlat = data['peminjaman_alat'] != null
              ? Map<String, dynamic>.from(data['peminjaman_alat'])
              : null;
        }

        // Ambil seluruh daftar jadwal praktik siswa agar apabila hari ini ada > 1 jadwal (misal 2 sesi di XII-TKJ), semuanya tampil
        try {
          final resJadwal = await ApiService.get(
            '/kejuruan/jadwal/$idSiswa',
            forceRefresh: true,
            silent: true,
          );
          if (resJadwal != null &&
              resJadwal['success'] == true &&
              resJadwal['data'] is List) {
            final String todayName = _getTodayName().toLowerCase();
            final List rawJadwal = resJadwal['data'];
            final List<Map<String, dynamic>> todayItems = rawJadwal
                .map((e) => Map<String, dynamic>.from(e))
                .where((m) {
                  final String hari =
                      (m['hari'] ?? '').toString().trim().toLowerCase();
                  final bool isActive = m['is_active'] == true;
                  return isActive || hari == todayName;
                })
                .toList();

            // Urutkan berdasarkan jam_mulai dari pagi ke sore
            todayItems.sort((a, b) {
              final minA =
                  _parseTimeToMinutes(a['jam_mulai']?.toString()) ?? 9999;
              final minB =
                  _parseTimeToMinutes(b['jam_mulai']?.toString()) ?? 9999;
              return minA.compareTo(minB);
            });

            if (todayItems.isNotEmpty) {
              final int totalToday = todayItems.length;
              praktikHariIniList = List.generate(totalToday, (idx) {
                final m = todayItems[idx];
                final String jamMulai = m['jam_mulai'] != null &&
                        m['jam_mulai'].toString().length >= 5
                    ? m['jam_mulai'].toString().substring(0, 5)
                    : (m['jam_mulai']?.toString() ?? '-');
                final String jamSelesai = m['jam_selesai'] != null &&
                        m['jam_selesai'].toString().length >= 5
                    ? m['jam_selesai'].toString().substring(0, 5)
                    : (m['jam_selesai']?.toString() ?? '-');
                final String judulMapel = m['mapel'] is Map
                    ? (m['mapel']['nama_mapel'] ?? 'Praktik Kejuruan')
                        .toString()
                    : (m['mapel'] ??
                            m['judul'] ??
                            m['materi'] ??
                            'Praktik Kejuruan')
                        .toString();
                final String namaLab = m['lab'] is Map
                    ? (m['lab']['nama_lab'] ?? 'Lab Praktik').toString()
                    : (m['lab'] ?? m['lokasi'] ?? m['ruangan'] ?? 'Lab Praktik')
                        .toString();
                final String namaGuru = m['guru'] is Map
                    ? (m['guru']['nama_guru'] ?? 'Guru Pengampu').toString()
                    : (m['guru'] ?? 'Guru Pengampu').toString();
                final String? noHpGuru = m['guru'] is Map
                    ? (m['guru']['no_hp'] ??
                            m['guru']['no_telp'] ??
                            m['guru']['telepon'])
                        ?.toString()
                    : m['no_hp_guru']?.toString();
                final String badgeStr = totalToday > 1
                    ? 'Hari ini • Sesi ${idx + 1}'
                    : 'Hari ini';

                return {
                  'id_jadwal_praktik': m['id_jadwal_praktik'],
                  'kode': (m['kode'] ?? '').toString(),
                  'hari': (m['hari'] ?? _getTodayName()).toString(),
                  'frekuensi_label':
                      (m['frekuensi_label'] ?? 'Setiap Minggu').toString(),
                  'judul': judulMapel,
                  'lab': namaLab,
                  'lokasi': namaLab,
                  'jam_mulai': jamMulai,
                  'jam_selesai': jamSelesai,
                  'jam': '$jamMulai - $jamSelesai',
                  'jadwal': '$jamMulai - $jamSelesai',
                  'guru': namaGuru,
                  'no_hp_guru': noHpGuru,
                  'peran_guru': 'Instruktur Kejuruan',
                  'alat_bahan': (m['alat_bahan'] ?? '-').toString(),
                  'badge': badgeStr,
                  'badge_waktu': badgeStr,
                  'sesi_ke': idx + 1,
                  'is_today': true,
                };
              });
              praktikBerikutnya = praktikHariIniList.first;
            } else {
              praktikHariIniList = [];
            }
          }
        } catch (_) {}

        // Ambil daftar modul untuk job sheet
        final resModul =
            await ApiService.get('/kejuruan/modul/$idSiswa', silent: true);
        if (resModul != null &&
            resModul['success'] == true &&
            resModul['data'] is List) {
          jobSheets = List<Map<String, dynamic>>.from(resModul['data']);
        }
      } catch (_) {
        // Fallback default
      }
    }

    if (mounted) {
      setState(() {
        _selectedSesiIndex = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header Modern Lengkung SIAWI Konsisten dengan Menu Lain
          _buildSiawiHeader(),

          // Konten Utama
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4C3EC7),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: const Color(0xFF4C3EC7),
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Sebelum Jadwal Praktik: Kehadiran & Rata-rata Praktik (Gambar 1)
                          _buildStatCardsRow(),
                          const SizedBox(height: 8),

                          // 2. Sebelum Jadwal Praktik: Banner Status Remedial (Hanya muncul jika ada remedial aktif)
                          if (statusRemedialModul.isNotEmpty &&
                              statusRemedialModul != '-' &&
                              !statusRemedialModul
                                  .toLowerCase()
                                  .contains('tidak ada') &&
                              !statusRemedialModul.startsWith('0')) ...[
                            _buildStatusRemedialBanner(),
                            const SizedBox(height: 10),
                          ],

                          // 3. Jadwal Praktik Hari Ini (Tengah)
                          _buildPraktikBerikutnyaCard(),
                          const SizedBox(height: 10),

                          // 4. Setelah Jadwal Praktik: Peminjaman Alat (Hanya muncul jika ada alat aktif)
                          if (peminjamanAlat != null) ...[
                            _buildPeminjamanAlatCard(),
                            const SizedBox(height: 14),
                          ],

                          // 5. 8 Menu Layanan Praktik / Kejuruan
                          _buildMenuGrid(),
                          const SizedBox(height: 18),

                          // 6. Job Sheet & Tugas Praktikum (Gambar 1)
                          _buildJobSheetSection(),
                          const SizedBox(height: 14),

                          // 7. Konsultasi Instruktur (Gambar 2)
                          _buildInstrukturKonsultasiCard(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiawiHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4C3EC7), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x334C3EC7),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Ornamen Lingkaran Halus Background Khas SIAWI
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: 20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris Atas: Back button, Title & Logo (Konsisten SIAWI)
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kompetensi Kejuruan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 17.5,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              "Praktik & Keahlian Vokasi Siswa",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                        tooltip: 'Segarkan Data',
                        onPressed: _loadData,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Image.asset(
                          'assets/logo/logo-splash.png',
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Hero Floating Card Profil Siswa & Program Kejuruan (Konsisten Jadwal/Poin)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Ikon Kotak Kejuruan
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.architecture_rounded,
                            color: Color(0xFF16A34A),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Info Siswa, Kelas & Konsentrasi Keahlian
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (namaSiswa.isNotEmpty && namaSiswa != "Siswa")
                                    ? namaSiswa
                                    : namaJurusan,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1.5),
                              Text(
                                '$namaKelas • $namaJurusan',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Badge Status Kejuruan Aktif
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFC7D2FE),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 12.5,
                                color: Color(0xFF4C3EC7),
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Aktif',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4C3EC7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPraktikBerikutnyaCard() {
    final bool hasTodaySchedule = praktikHariIniList.isNotEmpty;
    final bool hasUpcomingOtherDay =
        !hasTodaySchedule && praktikBerikutnya != null;

    // Kategorisasi berdasarkan waktu sekarang (seperti JadwalToday pada Jadwal Mapel)
    final now = DateTime.now();
    final int nowMinutes = now.hour * 60 + now.minute;

    final List<Map<String, dynamic>> enrichedTodayList = [];
    int? defaultActiveIndex;
    bool allCompleted = false;

    if (hasTodaySchedule) {
      for (int i = 0; i < praktikHariIniList.length; i++) {
        final item = Map<String, dynamic>.from(praktikHariIniList[i]);
        item['sesi_ke'] = item['sesi_ke'] ?? (i + 1);
        final times = _extractStartEndTime(item);
        item['jam_mulai'] = times['jam_mulai'];
        item['jam_selesai'] = times['jam_selesai'];

        final int? startMin = _parseTimeToMinutes(times['jam_mulai']);
        final int? endMin = _parseTimeToMinutes(times['jam_selesai']);

        String statusMode = 'berikutnya';
        if (startMin != null && endMin != null) {
          if (nowMinutes > endMin) {
            statusMode = 'selesai';
          } else if (defaultActiveIndex == null) {
            defaultActiveIndex = i;
            if (nowMinutes >= startMin && nowMinutes <= endMin) {
              statusMode = 'berlangsung';
            } else {
              statusMode = 'berikutnya';
            }
          } else {
            statusMode = 'berikutnya';
          }
        } else {
          if (defaultActiveIndex == null) {
            defaultActiveIndex = i;
          }
        }
        item['_status_mode'] = statusMode;
        enrichedTodayList.add(item);
      }

      if (defaultActiveIndex == null && enrichedTodayList.isNotEmpty) {
        allCompleted = true;
        defaultActiveIndex = enrichedTodayList.length - 1;
      }
    }

    final int currentSelectedIndex = hasTodaySchedule
        ? ((_selectedSesiIndex != null &&
                _selectedSesiIndex! >= 0 &&
                _selectedSesiIndex! < enrichedTodayList.length)
            ? _selectedSesiIndex!
            : (defaultActiveIndex ?? 0))
        : 0;

    final String pillText = hasTodaySchedule
        ? '${enrichedTodayList.length} Jadwal Praktik'
        : (hasUpcomingOtherDay ? 'Jadwal Terdekat' : 'Tidak Ada Jadwal');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER COMPACT: "Jadwal Praktik Hari Ini" + Badge Sesi + "Lihat Semua >"
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Jadwal Praktik Hari Ini',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openSubMenu('Jadwal Praktik'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4C3EC7),
                        ),
                      ),
                      SizedBox(width: 1),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Color(0xFF4C3EC7),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),

          // 2. SUBHEADER: Tanggal Hari Ini & Badge Jumlah Sesi Praktik
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getFormattedDateToday(),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.5, vertical: 2.5),
                decoration: BoxDecoration(
                  color: hasTodaySchedule
                      ? const Color(0xFFEEF2FF)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasTodaySchedule
                        ? const Color(0xFFC7D2FE)
                        : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  pillText,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: hasTodaySchedule
                        ? const Color(0xFF4C3EC7)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),

          // 3. KONTEN JADWAL PRAKTIK
          if (!hasTodaySchedule && !hasUpcomingOtherDay) ...[
            _buildEmptyPraktikTodayState(),
          ] else if (hasUpcomingOtherDay) ...[
            _buildSinglePraktikCard(
              praktikBerikutnya!,
              statusMode: 'terdekat',
              totalToday: 1,
            ),
          ] else ...[
            // Jika semua sesi hari ini sudah selesai, tampilkan strip info hijau ringkas
            if (allCompleted) ...[
              _buildAllPraktikCompletedBanner(enrichedTodayList),
              const SizedBox(height: 8),
            ],

            // Jika hari ini ada > 1 jadwal (misal Sesi 1 & Sesi 2), tampilkan Tab Pilihan Sesi yang menampilkan seluruh jam sesi sekaligus
            if (enrichedTodayList.length > 1) ...[
              _buildSessionSelectorBar(
                enrichedTodayList,
                selectedIndex: currentSelectedIndex,
              ),
              const SizedBox(height: 8),
            ],

            // Kartu Utama Sesi yang Dipilih / Sedang Berlangsung / Berikutnya
            _buildSinglePraktikCard(
              enrichedTodayList[currentSelectedIndex],
              statusMode: (enrichedTodayList[currentSelectedIndex]
                          ['_status_mode'] ??
                      'berikutnya')
                  .toString(),
              totalToday: enrichedTodayList.length,
              isSameMapelToday: _isSameMapelInList(enrichedTodayList),
            ),
          ],
        ],
      ),
    );
  }

  bool _isSameMapelInList(List<Map<String, dynamic>> list) {
    if (list.length <= 1) return true;
    final Set<String> uniqueNames = list
        .map((e) => (e['judul'] ?? '').toString().trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toSet();
    return uniqueNames.length <= 1;
  }

  Widget _buildSessionSelectorBar(
    List<Map<String, dynamic>> sessions, {
    required int selectedIndex,
  }) {
    final bool isSameMapel = _isSameMapelInList(sessions);
    final String prefixLabel = isSameMapel ? 'Sesi' : 'Praktik';
    final bool isScrollable = sessions.length > 2;

    Widget buildTabItem(int idx) {
      final item = sessions[idx];
      final bool isSelected = idx == selectedIndex;
      final String mode = (item['_status_mode'] ?? 'berikutnya').toString();
      final String jamMulai = (item['jam_mulai'] ?? '-').toString();
      final String jamSelesai = (item['jam_selesai'] ?? '-').toString();
      final int nomor = item['sesi_ke'] is int ? item['sesi_ke'] : (idx + 1);

      Color borderColor;
      Color bgColor;
      Color textColor;
      IconData statusIcon;
      Color iconColor;

      if (isSelected) {
        if (mode == 'berlangsung') {
          bgColor = const Color(0xFFECFDF5);
          borderColor = const Color(0xFF10B981);
          textColor = const Color(0xFF065F46);
          statusIcon = Icons.play_circle_fill_rounded;
          iconColor = const Color(0xFF059669);
        } else if (mode == 'selesai') {
          bgColor = const Color(0xFFF1F5F9);
          borderColor = const Color(0xFF64748B);
          textColor = const Color(0xFF1E293B);
          statusIcon = Icons.check_circle_rounded;
          iconColor = const Color(0xFF10B981);
        } else {
          bgColor = const Color(0xFFEEF2FF);
          borderColor = const Color(0xFF4C3EC7);
          textColor = const Color(0xFF312E81);
          statusIcon = Icons.schedule_rounded;
          iconColor = const Color(0xFF4C3EC7);
        }
      } else {
        bgColor = const Color(0xFFF8FAFC);
        borderColor = const Color(0xFFE2E8F0);
        textColor = const Color(0xFF64748B);
        if (mode == 'selesai') {
          statusIcon = Icons.check_circle_outline_rounded;
          iconColor = const Color(0xFF10B981);
        } else if (mode == 'berlangsung') {
          statusIcon = Icons.play_circle_outline_rounded;
          iconColor = const Color(0xFF059669);
        } else {
          statusIcon = Icons.access_time_rounded;
          iconColor = const Color(0xFF94A3B8);
        }
      }

      return InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () {
          setState(() {
            _selectedSesiIndex = idx;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: isScrollable ? 12 : 9,
            vertical: 6.5,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.3 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: isScrollable ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, size: 13, color: iconColor),
              const SizedBox(width: 4.5),
              if (isScrollable)
                Text(
                  '$prefixLabel $nomor • $jamMulai–$jamSelesai',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: textColor,
                  ),
                )
              else
                Flexible(
                  child: Text(
                    '$prefixLabel $nomor • $jamMulai–$jamSelesai',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Desain Hybrid:
    // - Jika 2 jadwal: Tampil rata kiri-kanan (50% : 50%)
    // - Jika >= 3 jadwal: Otomatis menjadi Horizontal Scrollable Pills (tetap 1 baris & tidak sempit)
    if (!isScrollable) {
      return Row(
        children: List.generate(sessions.length, (idx) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: idx == 0 ? 0 : 6),
              child: buildTabItem(idx),
            ),
          );
        }),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(sessions.length, (idx) {
          return Padding(
            padding: EdgeInsets.only(left: idx == 0 ? 0 : 6),
            child: buildTabItem(idx),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyPraktikTodayState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF4C3EC7),
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tidak Ada Praktik Hari Ini',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 1.5),
                Text(
                  'Belum ada jadwal praktik laboratorium/bengkel hari ini.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllPraktikCompletedBanner(
      List<Map<String, dynamic>> completedList) {
    final String waktuAkhir = completedList.isNotEmpty
        ? (completedList.last['jam_selesai'] ?? '-')
        : '-';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.task_alt_rounded,
            color: Color(0xFF059669),
            size: 16,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              'Praktik selesai • Semua jadwal berakhir pukul $waktuAkhir WIB',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF065F46),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinglePraktikCard(
    Map<String, dynamic> data, {
    String statusMode = 'berikutnya',
    int totalToday = 1,
    bool isSameMapelToday = true,
  }) {
    // Parsing daftar peralatan wajib dibawa
    List<String> peralatanList = [];
    if (data['peralatan'] is List) {
      peralatanList = List<String>.from(data['peralatan']);
    } else if (data['alat_bahan'] != null &&
        data['alat_bahan'].toString().isNotEmpty &&
        data['alat_bahan'].toString() != '-') {
      peralatanList = data['alat_bahan']
          .toString()
          .split(RegExp(r'[,;]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final int sesiKe = data['sesi_ke'] is int ? data['sesi_ke'] : 1;
    final String prefixLabel = isSameMapelToday ? 'Sesi' : 'Praktik';
    final String rawBadge =
        (data['badge_waktu'] ?? data['badge'] ?? 'Hari Ini').toString();
    final String judul = (data['judul'] ?? 'Praktik Kejuruan').toString();
    final String lab =
        (data['lab'] ?? data['lokasi'] ?? 'Lab Kejuruan').toString();
    final String jadwal = (data['jadwal'] ?? data['jam'] ?? '-').toString();
    final String guru = (data['guru'] ?? 'Guru Pengampu').toString();
    final String peranGuru =
        (data['peran_guru'] ?? 'Instruktur Kejuruan').toString();

    // Konfigurasi badge status waktu yang dinamis & kontekstual
    String statusLabel;
    Color statusBgColor;
    Color statusTextColor;
    Color statusDotColor;

    if (statusMode == 'berlangsung') {
      statusLabel = totalToday > 1
          ? 'Sedang Berlangsung • $prefixLabel $sesiKe'
          : 'Sedang Berlangsung';
      statusBgColor = const Color(0xFFD1FAE5);
      statusTextColor = const Color(0xFF047857);
      statusDotColor = const Color(0xFF059669);
    } else if (statusMode == 'selesai') {
      statusLabel = totalToday > 1
          ? '$prefixLabel $sesiKe • Selesai'
          : 'Praktik Selesai';
      statusBgColor = const Color(0xFFF1F5F9);
      statusTextColor = const Color(0xFF475569);
      statusDotColor = const Color(0xFF64748B);
    } else if (statusMode == 'terdekat') {
      statusLabel = rawBadge;
      statusBgColor = const Color(0xFFFEF3C7);
      statusTextColor = const Color(0xFFB45309);
      statusDotColor = const Color(0xFFD97706);
    } else {
      statusLabel = totalToday > 1
          ? 'Jadwal Berikutnya • $prefixLabel $sesiKe'
          : 'Jadwal Berikutnya';
      statusBgColor = const Color(0xFFEEF2FF);
      statusTextColor = const Color(0xFF4C3EC7);
      statusDotColor = const Color(0xFF4F46E5);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusMode == 'berlangsung'
              ? const Color(0xFF6EE7B7)
              : const Color(0xFFE2E8F0),
          width: 1.1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction_rounded,
                      size: 11.5,
                      color: Color(0xFF4C3EC7),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Praktik Bengkel / Lab',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4C3EC7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusDotColor,
                        ),
                      ),
                      const SizedBox(width: 4.5),
                      Flexible(
                        child: Text(
                          statusLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 2. Judul Praktik
          Text(
            judul,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),

          // 3. Dua Kolom Ringkas: LOKASI & JADWAL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // Kolom Lokasi
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.dns_rounded,
                            size: 13,
                            color: Color(0xFF4C3EC7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "LOKASI",
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              lab,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 20,
                  width: 1,
                  color: const Color(0xFFE2E8F0),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                ),
                // Kolom Jadwal
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "JADWAL",
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              jadwal,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // 4. Guru / Instruktur Row
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEEF2FF),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 12,
                  color: Color(0xFF4C3EC7),
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  guru,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                "•",
                style: TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  peranGuru,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // 5. Peralatan Wajib Dibawa Inline Bar (Hanya muncul jika ada, desain 1 baris hemat ruang)
          if (peralatanList.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                  width: 0.9,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.home_repair_service_rounded,
                    size: 12,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Wajib Bawa:",
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB45309),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: peralatanList.map((alat) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6.5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFFDE68A),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_rounded,
                                    size: 10,
                                    color: Color(0xFF059669),
                                  ),
                                  const SizedBox(width: 2.5),
                                  Text(
                                    alat,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),

          // 6. Bottom Action Buttons: "Lihat Panduan Job Sheet" + Bookmark Button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () => _openSubMenu("Modul praktik"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C3EC7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_rounded, size: 14.5),
                        SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "Lihat Panduan Job Sheet",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 13),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFC7D2FE),
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.bookmark_border_rounded,
                    color: Color(0xFF4C3EC7),
                    size: 18,
                  ),
                  tooltip: 'Simpan Jadwal',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Jadwal praktik berhasil disimpan.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardsRow() {
    return Row(
      children: [
        // 1. Kehadiran Praktik (96% (24/25 Sesi) - Sangat Disiplin)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Icon + Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 15,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          kehadiranBadge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                const Text(
                  "KEHADIRAN PRAKTIK",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$kehadiranPraktik ",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.4,
                        ),
                      ),
                      TextSpan(
                        text: kehadiranSesi.startsWith("(")
                            ? kehadiranSesi
                            : "($kehadiranSesi)",
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // 2. Rata-Rata Praktik (88.5 Predikat A- - Kompeten)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Icon + Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.school_rounded,
                          size: 15,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          kompetensiBadge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                const Text(
                  "RATA-RATA PRAKTIK",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$rataRataNilai ",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.4,
                        ),
                      ),
                      TextSpan(
                        text: predikatNilai,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRemedialBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon lingkaran info warna amber
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFEF3C7),
            ),
            child: const Center(
              child: Icon(
                Icons.info_rounded,
                color: Color(0xFFB45309),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Teks Tengah: STATUS REMEDIAL + Badge 1 Modul Aktif + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      "STATUS REMEDIAL",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF92400E),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusRemedialModul,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "$remedialTopik • $remedialTarget",
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Tombol Uji Ulang
          InkWell(
            onTap: _showRemedialDialog,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFCD34D),
                  width: 1,
                ),
              ),
              child: const Text(
                "Uji Ulang",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF78350F),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeminjamanAlatCard() {
    if (peminjamanAlat == null) return const SizedBox.shrink();
    final item = peminjamanAlat!;
    final namaAlat = item['nama_alat'] ?? item['nama'] ?? 'Peralatan Praktik';
    final status = item['status'] ?? 'Dipinjam';
    final lokasi = item['lokasi'] ?? 'Lab';
    final batasKembali = item['batas_kembali'] ?? item['tgl_kembali'] ?? '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Barcode Icon Box
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 2.5),
                  Container(
                    width: 2,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 2.5),
                  Container(
                    width: 3.5,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 2.5),
                  Container(
                    width: 2,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 2.5),
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 11),

          // Teks Tengah: Nama Alat + Badge Dipinjam + Subtitle Batas Waktu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        namaAlat,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$lokasi • Kembalikan sebelum ",
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      TextSpan(
                        text: batasKembali,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Tombol Detail
          InkWell(
            onTap: _showPeminjamanDetailDialog,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: const Text(
                "Detail",
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemedialDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFB45309),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Program Uji Remedial",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          "Peningkatan Capaian Nilai Kompetensi",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Materi: $remedialTopik",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Status: $statusRemedialModul • $remedialTarget",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF78350F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Silakan pelajari kembali modul '$remedialTopik' dan hubungi guru pengampu kejuruan untuk menentukan jadwal ujian praktik ulang.",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _openSubMenu("Modul praktik");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C3EC7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Buka Modul Persiapan Remedial",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPeminjamanDetailDialog() {
    if (peminjamanAlat == null) return;
    final item = peminjamanAlat!;
    final namaAlat = item['nama_alat'] ?? item['nama'] ?? 'Peralatan Praktik';
    final status = item['status'] ?? 'Dipinjam';
    final lokasi = item['lokasi'] ?? 'Lab';
    final batasKembali = item['batas_kembali'] ?? item['tgl_kembali'] ?? '-';
    final sn = item['sn'] ?? item['kode'] ?? '-';
    final jamPinjam = item['jam_pinjam'] ?? item['tgl_pinjam'] ?? '-';
    final petugas = item['petugas'] ?? 'Petugas Lab';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.devices_other_rounded,
                      color: Color(0xFF3B82F6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          namaAlat,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          "Status Peminjaman: $status",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0284C7),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildPeminjamanInfoRow("Serial Number", sn),
                    const Divider(height: 16),
                    _buildPeminjamanInfoRow("Lokasi Pemakaian", lokasi),
                    const Divider(height: 16),
                    _buildPeminjamanInfoRow("Waktu Pinjam", jamPinjam),
                    const Divider(height: 16),
                    _buildPeminjamanInfoRow(
                        "Batas Kembali", batasKembali, isHighlight: true),
                    const Divider(height: 16),
                    _buildPeminjamanInfoRow("Instruktur / Toolman", petugas),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Silakan serahkan perangkat ke toolman sebelum batas waktu selesai.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C3EC7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Tutup & Simpan Tiket",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeminjamanInfoRow(String label, String value,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: isHighlight
                  ? const Color(0xFFD97706)
                  : const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      // 1. Jadwal Praktik
      _KejuruanMenuItem(
        title: "Jadwal\nPraktik",
        icon: Icons.calendar_month_rounded,
        bgColor: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFF0284C7),
        onTap: () => _openSubMenu("Jadwal Praktik"),
      ),
      // 2. Modul Praktik
      _KejuruanMenuItem(
        title: "Modul\nPraktik",
        icon: Icons.menu_book_rounded,
        bgColor: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFD97706),
        onTap: () => _openSubMenu("Modul Praktik"),
      ),
      // 3. Nilai Praktik
      _KejuruanMenuItem(
        title: "Nilai\nPraktik",
        icon: Icons.assignment_turned_in_rounded,
        bgColor: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF16A34A),
        onTap: () => _openSubMenu("Nilai Praktik"),
      ),
      // 4. Uji Kompetensi
      _KejuruanMenuItem(
        title: "Uji\nKompetensi",
        icon: Icons.school_rounded,
        bgColor: const Color(0xFFEDE9FE),
        iconColor: const Color(0xFF6366F1),
        onTap: () => _openSubMenu("Uji Kompetensi"),
      ),
      // 5. Sertifikat & Portofolio
      _KejuruanMenuItem(
        title: "Sertifikat &\nPortofolio",
        icon: Icons.layers_rounded,
        bgColor: const Color(0xFFFFE4E6),
        iconColor: const Color(0xFFE11D48),
        onTap: () => _openSubMenu("Sertifikat & Portofolio"),
      ),
      // 6. Tes Teori & TKK
      _KejuruanMenuItem(
        title: "Tes Teori &\nTKK",
        icon: Icons.quiz_rounded,
        bgColor: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF9333EA),
        onTap: () => _openSubMenu("Tes Teori & TKK"),
      ),
      // 7. Peminjaman Alat
      _KejuruanMenuItem(
        title: "Peminjaman\nAlat",
        icon: Icons.home_repair_service_rounded,
        bgColor: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFB45309),
        onTap: () => _openSubMenu("Peminjaman Alat"),
      ),
      // 8. Presensi Bengkel
      _KejuruanMenuItem(
        title: "Presensi\nBengkel",
        icon: Icons.qr_code_scanner_rounded,
        bgColor: const Color(0xFFCCFBF1),
        iconColor: const Color(0xFF0D9488),
        onTap: () => _openSubMenu("Presensi Bengkel"),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section: Icon + MENU LAYANAN PRAKTIK + 8 Menu Kejuruan
        Row(
          children: const [
            Icon(
              Icons.widgets_rounded,
              size: 16,
              color: Color(0xFF4C3EC7),
            ),
            SizedBox(width: 6),
            Text(
              "MENU LAYANAN PRAKTIK",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: 0.3,
              ),
            ),
            Spacer(),
            Text(
              "8 Menu Kejuruan",
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Baris 1: 4 Menu Pertama
        Row(
          children: [
            for (int i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _buildGridButton(menuItems[i]),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),

        // Baris 2: 4 Menu Kedua
        Row(
          children: [
            for (int i = 4; i < 8; i++) ...[
              if (i > 4) const SizedBox(width: 8),
              Expanded(
                child: _buildGridButton(menuItems[i]),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildGridButton(_KejuruanMenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: item.iconColor.withValues(alpha: 0.12),
        highlightColor: item.iconColor.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Squircle Container Icon Warna Pastel Sesuai Gambar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  item.icon,
                  color: item.iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),

              // Title label (fleksibel dan tidak overflow)
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 28),
                child: Center(
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobSheetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: Icon + Judul Section + Lihat Semua
        Row(
          children: [
            const Icon(
              Icons.format_list_bulleted_rounded,
              size: 16.5,
              color: Color(0xFF4C3EC7),
            ),
            const SizedBox(width: 6),
            const Text(
              "JOB SHEET & TUGAS PRAKTIKUM",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: 0.3,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () => _openSubMenu("Modul Praktik"),
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  "Lihat Semua",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4C3EC7),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (jobSheets.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Belum Ada Job Sheet Aktif",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Modul atau tugas praktikum laboratorium akan ditampilkan di sini.",
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ...jobSheets.take(2).map((item) {
            final kode = item['kode_modul'] ?? 'MODUL';
            final judul = item['judul'] ?? 'Praktik Mandiri';
            final deskripsi = item['deskripsi'] ??
                (item['kompetensi']?['nama_kompetensi'] ??
                    'Materi Praktik Kejuruan');
            final guru = item['guru']?['nama_guru'] ?? 'Instruktur Kejuruan';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Text(
                          kode,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Tersedia",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    judul,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    deskripsi,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 15,
                              color: Color(0xFF4C3EC7),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                guru,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          final String kategori =
                              (item['kategori'] ?? 'Konsentrasi Keahlian')
                                  .toString();
                          final String fileUrl = (item['file_url'] ??
                                  item['file_lembar_kerja'] ??
                                  item['file'] ??
                                  '')
                              .toString();
                          final String tujuan =
                              (item['tujuan'] ?? '').toString();
                          final String alatBahan =
                              (item['alat_bahan'] ?? '').toString();
                          final String langkahKerja =
                              (item['langkah_kerja'] ?? '').toString();
                          final List<dynamic> rubriks =
                              item['rubriks'] is List ? item['rubriks'] : [];

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailModulPraktikView(
                                judul: judul.toString(),
                                kode: kode.toString(),
                                kategori: kategori,
                                guru: guru.toString(),
                                fileUrl: fileUrl,
                                tujuan: tujuan,
                                alatBahan: alatBahan,
                                langkahKerja: langkahKerja,
                                rubriks: rubriks,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C3EC7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Buka Modul",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildInstrukturKonsultasiCard() {
    String namaGuru = "Guru Pengampu Kejuruan";
    String peranGuru = "Instruktur Bengkel & Lab Kejuruan";
    if (praktikBerikutnya != null &&
        praktikBerikutnya!['guru'] != null &&
        praktikBerikutnya!['guru'].toString().isNotEmpty) {
      namaGuru = praktikBerikutnya!['guru'];
      peranGuru = praktikBerikutnya!['peran_guru'] ?? "Guru Pengampu Praktik";
    } else if (jobSheets.isNotEmpty &&
        jobSheets.first['guru']?['nama_guru'] != null) {
      namaGuru = jobSheets.first['guru']['nama_guru'];
      peranGuru = "Guru Pengampu Kejuruan";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar bulat instruktur
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEEF2FF),
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: Color(0xFF4C3EC7),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info Instruktur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  namaGuru,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  peranGuru,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Tombol Konsultasi
          InkWell(
            onTap: _showKonsultasiBottomSheet,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFC7D2FE),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 15,
                    color: Color(0xFF4C3EC7),
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Konsultasi",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4C3EC7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showKonsultasiBottomSheet() {
    String namaGuru = "Guru Pengampu Kejuruan";
    String peranGuru = "Instruktur Bengkel & Lab Kejuruan";
    String? noHpGuru;
    if (praktikBerikutnya != null &&
        praktikBerikutnya!['guru'] != null &&
        praktikBerikutnya!['guru'].toString().isNotEmpty) {
      namaGuru = praktikBerikutnya!['guru'];
      peranGuru = praktikBerikutnya!['peran_guru'] ?? "Guru Pengampu Praktik";
      noHpGuru = praktikBerikutnya!['no_hp_guru']?.toString();
    } else if (jobSheets.isNotEmpty &&
        jobSheets.first['guru']?['nama_guru'] != null) {
      namaGuru = jobSheets.first['guru']['nama_guru'];
      peranGuru = "Guru Pengampu Kejuruan";
      noHpGuru = (jobSheets.first['guru']['no_hp'] ??
              jobSheets.first['guru']['no_telp'] ??
              jobSheets.first['guru']['telepon'])
          ?.toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEEF2FF),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: Color(0xFF4C3EC7),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          namaGuru,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          peranGuru,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Jadwal Konsultasi & Bimbingan Bengkel:",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "• Setiap hari kerja pada jam operasional sekolah di Ruang Instruktur Bengkel / Lab.\n• Silakan konsultasikan kendala konfigurasi job sheet, persiapan UKK, atau perbaikan nilai remedial.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    String cleanHp =
                        (noHpGuru ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                    if (cleanHp.startsWith('0')) {
                      cleanHp = '62${cleanHp.substring(1)}';
                    }
                    if (cleanHp.length >= 9) {
                      final msg = Uri.encodeComponent(
                        'Halo Bapak/Ibu $namaGuru, saya $namaSiswa ($namaKelas) ingin berkonsultasi terkait pembelajaran dan praktikum kejuruan.',
                      );
                      final waUrl = Uri.parse('https://wa.me/$cleanHp?text=$msg');
                      if (await canLaunchUrl(waUrl)) {
                        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
                        return;
                      }
                    }
                    if (!this.mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Silakan temui $namaGuru di Ruang Instruktur Lab / Bengkel pada jam operasional sekolah.'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: const Text(
                    "Hubungi Guru Pengampu",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C3EC7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSubMenu(String title) {
    String clean = title.replaceAll("\n", " ").toLowerCase();
    Widget targetPage;

    if (clean.contains("jadwal")) {
      targetPage = JadwalPraktikView(idSiswa: idSiswa);
    } else if (clean.contains("modul")) {
      targetPage = ModulPraktikView(idSiswa: idSiswa);
    } else if (clean.contains("nilai")) {
      targetPage = NilaiPraktikView(idSiswa: idSiswa);
    } else if (clean.contains("uji") || clean.contains("ukk")) {
      targetPage = UjiKompetensiView(idSiswa: idSiswa);
    } else if (clean.contains("sertifikat") || clean.contains("portofolio")) {
      targetPage = SertifikatPortofolioView(idSiswa: idSiswa);
    } else if (clean.contains("tkk") || clean.contains("teori")) {
      targetPage = TesTeoriTkkView(idSiswa: idSiswa);
    } else if (clean.contains("pinjam") || clean.contains("alat")) {
      targetPage = PeminjamanAlatView(idSiswa: idSiswa);
    } else if (clean.contains("presensi") || clean.contains("bengkel")) {
      targetPage = PresensiBengkelView(idSiswa: idSiswa);
    } else {
      targetPage = JadwalPraktikView(idSiswa: idSiswa);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }



}

class _KejuruanMenuItem {
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  _KejuruanMenuItem({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });
}