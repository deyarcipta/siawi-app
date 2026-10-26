import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';

class KejuruanView extends StatefulWidget {
  final VoidCallback? signOut;
  const KejuruanView({this.signOut, super.key});

  @override
  State<KejuruanView> createState() => _KejuruanViewState();
}

class _KejuruanViewState extends State<KejuruanView> {
  bool isLoading = true;
  String? idSiswa;

  // Header & Student data
  String namaSiswa = "Siswa";
  String namaJurusan = "Teknik Komputer dan Jaringan";
  String namaKelas = "Kelas XI";
  String subtitle = "Teknik Komputer dan Jaringan · Kelas XI";

  // Praktik berikutnya data
  Map<String, dynamic> praktikBerikutnya = {
    'tipe': 'Praktik Bengkel / Lab',
    'badge_waktu': 'Hari Ini • 08.00 WIB',
    'modul_nomor': 'MODUL 04',
    'topik_modul': 'MikroTik RouterOS',
    'judul': 'Praktik Konfigurasi Routing & Switching',
    'lab': 'Lab Jaringan 2',
    'jadwal': '08.00–10.15 (Senin)',
    'guru': 'Pak Hendra, S.Kom',
    'peran_guru': 'Instruktur Kejuruan',
    'alat_bahan': 'Kabel UTP Cat6, Crimping Tool, Laptop / Winbox',
    'peralatan': ['Kabel UTP Cat6', 'Crimping Tool', 'Laptop / Winbox'],
  };

  // Stats & Remedial data (Gambar 1)
  String kehadiranPraktik = "96%";
  String kehadiranSesi = "(24/25 Sesi)";
  String kehadiranBadge = "Sangat Disiplin";
  String rataRataNilai = "88.5";
  String predikatNilai = "Predikat A-";
  String kompetensiBadge = "Kompeten";
  String statusRemedialModul = "1 Modul Aktif";
  String remedialTopik = "Subnetting & CIDR";
  String remedialTarget = "Target Nilai KKM 75";

  // Peminjaman Alat data (Gambar 2)
  Map<String, dynamic> peminjamanAlat = {
    'nama_alat': '1 MikroTik RB951',
    'status': 'Dipinjam',
    'lokasi': 'Lab 2',
    'batas_kembali': '11.00 WIB',
    'keterangan': 'Lab 2 • Kembalikan sebelum 11.00 WIB',
    'sn': 'RB951-2HnD-7489',
    'jam_pinjam': '08.00 WIB',
    'petugas': 'Pak Hendra, S.Kom (Instruktur Lab)',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    idSiswa = prefs.getString('idSiswa');

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
        final res =
            await ApiService.get('/kejuruan/dashboard/$idSiswa', silent: true);
        if (res != null && res['success'] == true && res['data'] != null) {
          final data = res['data'];
          if (data['nama_siswa'] != null) namaSiswa = data['nama_siswa'];
          if (data['subtitle'] != null) subtitle = data['subtitle'];
          if (data['jurusan'] != null) namaJurusan = data['jurusan'];
          if (data['kelas'] != null) namaKelas = data['kelas'];
          if (data['praktik_berikutnya'] != null) {
            praktikBerikutnya =
                Map<String, dynamic>.from(data['praktik_berikutnya']);
          }
          if (data['stats'] != null) {
            var stats = data['stats'];
            kehadiranPraktik = stats['kehadiran_praktik'] ?? kehadiranPraktik;
            kehadiranSesi = stats['kehadiran_sesi'] ?? kehadiranSesi;
            kehadiranBadge = stats['kehadiran_badge'] ?? kehadiranBadge;
            rataRataNilai = stats['rata_rata_nilai'] ?? rataRataNilai;
            predikatNilai = stats['predikat'] ?? predikatNilai;
            kompetensiBadge = stats['kompetensi_badge'] ?? kompetensiBadge;
            statusRemedialModul =
                stats['remedial_modul'] ?? statusRemedialModul;
            remedialTopik = stats['remedial_topik'] ?? remedialTopik;
            remedialTarget = stats['remedial_kkm'] ?? remedialTarget;
          }
          if (data['peminjaman_alat'] != null) {
            peminjamanAlat =
                Map<String, dynamic>.from(data['peminjaman_alat']);
          }
        }
      } catch (_) {
        // Fallback default
      }
    }

    if (mounted) {
      setState(() {
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
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Sebelum Jadwal Praktik: Kehadiran & Rata-rata Praktik (Gambar 1)
                          _buildStatCardsRow(),
                          const SizedBox(height: 10),

                          // 2. Sebelum Jadwal Praktik: Banner Status Remedial (Gambar 1)
                          _buildStatusRemedialBanner(),
                          const SizedBox(height: 12),

                          // 3. Jadwal Praktik Hari Ini (Tengah)
                          _buildPraktikBerikutnyaCard(),
                          const SizedBox(height: 12),

                          // 4. Setelah Jadwal Praktik: Peminjaman Alat (Gambar 2)
                          _buildPeminjamanAlatCard(),
                          const SizedBox(height: 16),

                          // 5. 6 Tombol Sub-Menu Kejuruan (2 x 3)
                          _buildMenuGrid(),
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
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x334C3EC7),
            blurRadius: 18,
            offset: Offset(0, 8),
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
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris Atas: Back button, Title & Logo (Konsisten SIAWI)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
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
                                fontSize: 18,
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
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        tooltip: 'Segarkan Data',
                        onPressed: _loadData,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Image.asset(
                          'assets/logo/logo-splash.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Hero Floating Card Profil Siswa & Program Kejuruan (Konsisten Jadwal/Poin)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Ikon Kotak Kejuruan
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.architecture_rounded,
                            color: Color(0xFF16A34A),
                            size: 22,
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$namaKelas • $namaJurusan',
                                style: const TextStyle(
                                  fontSize: 12,
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
                            horizontal: 9,
                            vertical: 5,
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
                                size: 13,
                                color: Color(0xFF4C3EC7),
                              ),
                              SizedBox(width: 3.5),
                              Text(
                                'Aktif',
                                style: TextStyle(
                                  fontSize: 11,
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
    // Parsing daftar peralatan wajib dibawa
    List<String> peralatanList = [];
    if (praktikBerikutnya['peralatan'] is List) {
      peralatanList = List<String>.from(praktikBerikutnya['peralatan']);
    } else if (praktikBerikutnya['alat_bahan'] != null &&
        praktikBerikutnya['alat_bahan'].toString().isNotEmpty) {
      peralatanList = praktikBerikutnya['alat_bahan']
          .toString()
          .split(RegExp(r'[,;]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (peralatanList.isEmpty) {
      peralatanList = ['Kabel UTP Cat6', 'Crimping Tool', 'Laptop / Winbox'];
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C3EC7).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Badges Row: "Praktik Bengkel / Lab" and "• Hari Ini • 08.00 WIB"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Pill: Praktik Bengkel / Lab
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.construction_rounded,
                      size: 12,
                      color: Color(0xFF4C3EC7),
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Praktik Bengkel / Lab",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4C3EC7),
                      ),
                    ),
                  ],
                ),
              ),
              // Right Pill: Hari Ini • 08.00 WIB
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5.5,
                      height: 5.5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF059669),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      praktikBerikutnya['badge_waktu'] ??
                          praktikBerikutnya['badge'] ??
                          "Hari Ini • 08.00 WIB",
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2. Modul & Topic tags
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  praktikBerikutnya['modul_nomor'] ?? "MODUL 04",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF475569),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  praktikBerikutnya['topik_modul'] ?? "MikroTik RouterOS",
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 3. Judul Praktik
          Text(
            praktikBerikutnya['judul'] ??
                "Praktik Konfigurasi Routing & Switching",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),

          // 4. Dua Kolom: LOKASI & JADWAL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // Kolom Lokasi
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.dns_rounded,
                            size: 14,
                            color: Color(0xFF4C3EC7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "LOKASI",
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              praktikBerikutnya['lab'] ??
                                  praktikBerikutnya['lokasi'] ??
                                  "Lab Jaringan 2",
                              style: const TextStyle(
                                fontSize: 11.5,
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
                  height: 22,
                  width: 1,
                  color: const Color(0xFFE2E8F0),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                ),
                // Kolom Jadwal
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "JADWAL",
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              praktikBerikutnya['jadwal'] ??
                                  praktikBerikutnya['jam'] ??
                                  "08.00–10.15 (Senin)",
                              style: const TextStyle(
                                fontSize: 11.5,
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
          const SizedBox(height: 7),

          // 5. Guru / Instruktur Row
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEEF2FF),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 13,
                  color: Color(0xFF4C3EC7),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                praktikBerikutnya['guru'] ?? "Pak Hendra, S.Kom",
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                "•",
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  praktikBerikutnya['peran_guru'] ?? "Instruktur Kejuruan",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 6. Peralatan Wajib Dibawa Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFDE68A),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.home_repair_service_rounded,
                      size: 13,
                      color: Color(0xFFD97706),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "PERALATAN WAJIB DIBAWA:",
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB45309),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: peralatanList.map((alat) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFDE68A),
                          width: 0.9,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            size: 11,
                            color: Color(0xFF059669),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            alat,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 7. Bottom Action Buttons: "Lihat Panduan Job Sheet" + Bookmark Button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => _openSubMenu("Modul praktik"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C3EC7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.description_rounded, size: 16),
                        SizedBox(width: 6),
                        Text(
                          "Lihat Panduan Job Sheet",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFC7D2FE),
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.bookmark_border_rounded,
                    color: Color(0xFF4C3EC7),
                    size: 20,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 17,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        kehadiranBadge,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "KEHADIRAN PRAKTIK",
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$kehadiranPraktik ",
                        style: const TextStyle(
                          fontSize: 19,
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
          ),
        ),
        const SizedBox(width: 10),

        // 2. Rata-Rata Praktik (88.5 Predikat A- - Kompeten)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.school_rounded,
                          size: 17,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        kompetensiBadge,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "RATA-RATA PRAKTIK",
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$rataRataNilai ",
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.4,
                        ),
                      ),
                      TextSpan(
                        text: predikatNilai,
                        style: const TextStyle(
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
    final namaAlat = peminjamanAlat['nama_alat'] ?? '1 MikroTik RB951';
    final status = peminjamanAlat['status'] ?? 'Dipinjam';
    final lokasi = peminjamanAlat['lokasi'] ?? 'Lab 2';
    final batasKembali = peminjamanAlat['batas_kembali'] ?? '11.00 WIB';

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
                    const Text(
                      "Silakan pelajari Job Sheet Modul 03 dan hubungi guru pengampu kejuruan untuk menentukan jadwal ujian praktik ulang.",
                      style: TextStyle(
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
    final namaAlat = peminjamanAlat['nama_alat'] ?? '1 MikroTik RB951';
    final status = peminjamanAlat['status'] ?? 'Dipinjam';
    final lokasi = peminjamanAlat['lokasi'] ?? 'Lab 2';
    final batasKembali = peminjamanAlat['batas_kembali'] ?? '11.00 WIB';
    final sn = peminjamanAlat['sn'] ?? 'RB951-2HnD-7489';
    final jamPinjam = peminjamanAlat['jam_pinjam'] ?? '08.00 WIB';
    final petugas =
        peminjamanAlat['petugas'] ?? 'Pak Hendra, S.Kom (Instruktur Lab)';

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
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: isHighlight
                ? const Color(0xFFD97706)
                : const Color(0xFF0F172A),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
              const SizedBox(height: 8),

              // Title label (2 baris pas dan presisi)
              SizedBox(
                height: 28,
                child: Center(
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
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

  Future<dynamic> _fetchSubMenuData(String title) async {
    if (idSiswa == null) return null;
    String clean = title.replaceAll("\n", " ");
    String endpoint = '';
    if (clean.contains("Jadwal")) {
      endpoint = '/kejuruan/jadwal/$idSiswa';
    } else if (clean.contains("Modul")) {
      endpoint = '/kejuruan/modul/$idSiswa';
    } else if (clean.contains("Nilai")) {
      endpoint = '/kejuruan/nilai/$idSiswa';
    } else if (clean.contains("Uji")) {
      endpoint = '/kejuruan/ukk/$idSiswa';
    } else if (clean.contains("Sertifikat") || clean.contains("Portofolio")) {
      endpoint = '/kejuruan/portofolio/$idSiswa';
    } else if (clean.contains("TKK") || clean.contains("Teori")) {
      endpoint = '/kejuruan/tkk/$idSiswa';
    }

    if (endpoint.isEmpty) return null;

    try {
      final res = await ApiService.get(endpoint, silent: true);
      if (res != null && res['success'] == true) {
        return res['data'];
      }
    } catch (_) {}
    return null;
  }

  void _openSubMenu(String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailBottomSheet(title),
    );
  }

  Widget _buildDetailBottomSheet(String title) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.replaceAll("\n", " "),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const Divider(color: Color(0xFFECEFF5), height: 18),

          // Content body
          Expanded(
            child: _buildSubMenuContent(title),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMenuContent(String title) {
    return FutureBuilder<dynamic>(
      future: _fetchSubMenuData(title),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4C3EC7)),
          );
        }

        final liveData = snapshot.data;
        String cleanTitle = title.replaceAll("\n", " ");

        // 1. Jadwal Praktik
        if (cleanTitle.contains("Jadwal")) {
          if (liveData is List && liveData.isNotEmpty) {
            return ListView.builder(
              itemCount: liveData.length,
              itemBuilder: (context, i) {
                var item = liveData[i];
                String mapel = item['mapel']?['nama_mapel'] ??
                    item['materi'] ??
                    'Praktik Kejuruan';
                String lab = item['lab']?['nama_lab'] ?? 'Lab Praktik';
                String hari = item['hari'] ?? 'Senin';
                String jamMulai = item['jam_mulai'] != null
                    ? item['jam_mulai'].toString().substring(0, 5)
                    : '08.00';
                String jamSelesai = item['jam_selesai'] != null
                    ? item['jam_selesai'].toString().substring(0, 5)
                    : '10.15';
                String guru = item['guru']?['nama_guru'] ?? '-';
                String alat = item['alat_bahan'] ?? '-';

                return _buildInfoTile(
                  title: mapel,
                  subtitle:
                      "$lab · $hari, $jamMulai - $jamSelesai\nGuru: $guru\nAlat: $alat",
                  badge: hari,
                  badgeColor: const Color(0xFF0284C7),
                  icon: Icons.access_time_rounded,
                );
              },
            );
          }
          return ListView(
            children: [
              _buildInfoTile(
                title: "Instalasi Jaringan LAN & Server",
                subtitle:
                    "Lab 2 · Senin, 08.00 - 10.15\nGuru: Pak Andi\nAlat: Kabel UTP, Crimping tool, Tester",
                badge: "Hari Ini",
                badgeColor: const Color(0xFF0284C7),
                icon: Icons.access_time_rounded,
              ),
              _buildInfoTile(
                title: "Konfigurasi Mikrotik Router",
                subtitle:
                    "Lab Jaringan 1 · Rabu, 10.30 - 12.45\nGuru: Bu Sarah\nAlat: Routerboard RB941, Kabel Console",
                badge: "Mendatang",
                badgeColor: const Color(0xFF64748B),
                icon: Icons.router_rounded,
              ),
            ],
          );
        }

        // 2. Modul Praktik
        else if (cleanTitle.contains("Modul")) {
          if (liveData is List && liveData.isNotEmpty) {
            return ListView.builder(
              itemCount: liveData.length,
              itemBuilder: (context, i) {
                var item = liveData[i];
                String judul = item['judul_modul'] ??
                    item['nama_modul'] ??
                    'Modul Praktik';
                String komp = item['kompetensi']?['nama_kompetensi'] ??
                    'Kompetensi Kejuruan';
                String status = item['status'] ?? 'Tersedia';

                return _buildInfoTile(
                  title: judul,
                  subtitle:
                      "Kompetensi: $komp\nGuru: ${item['guru']?['nama_guru'] ?? '-'}",
                  badge: status.toUpperCase(),
                  badgeColor: const Color(0xFF0D9488),
                  icon: Icons.menu_book_rounded,
                );
              },
            );
          }
          return ListView(
            children: [
              _buildInfoTile(
                title: "Modul 01: Perakitan & Pengkabelan UTP",
                subtitle:
                    "Revisi 2.0 · 18 Halaman · PDF\nKompetensi: Pengkabelan Jaringan Lokal",
                badge: "Tersedia",
                badgeColor: const Color(0xFF0D9488),
                icon: Icons.menu_book_rounded,
              ),
              _buildInfoTile(
                title: "Modul 02: Routing Statis & Dinamis",
                subtitle:
                    "Revisi 1.2 · 24 Halaman · PDF\nKompetensi: Jaringan Skala Menengah",
                badge: "Tersedia",
                badgeColor: const Color(0xFF0D9488),
                icon: Icons.menu_book_rounded,
              ),
            ],
          );
        }

        // 3. Nilai Praktik
        else if (cleanTitle.contains("Nilai")) {
          if (liveData is List && liveData.isNotEmpty) {
            return ListView.builder(
              itemCount: liveData.length,
              itemBuilder: (context, i) {
                var item = liveData[i];
                String judul = item['penilaian']?['judul_penilaian'] ??
                    item['penilaian']?['modul']?['judul_modul'] ??
                    'Penilaian Praktik';
                num nilai = item['nilai_akhir'] ?? 0;
                bool isRemedial = item['is_remedial'] == true || nilai < 75;

                return _buildInfoTile(
                  title: judul,
                  subtitle:
                      "Nilai: $nilai · Status: ${isRemedial ? 'Perlu Remedial' : 'Kompeten'}\nCatatan: ${item['catatan'] ?? '-'}",
                  badge: isRemedial ? "Remedial" : "Kompeten",
                  badgeColor: isRemedial
                      ? const Color(0xFFEA580C)
                      : const Color(0xFF16A34A),
                  icon: isRemedial
                      ? Icons.warning_amber_rounded
                      : Icons.fact_check_rounded,
                );
              },
            );
          }
          return ListView(
            children: [
              _buildInfoTile(
                title: "Praktik Pengkabelan Straight & Cross",
                subtitle:
                    "Nilai: 88 · KKM: 75 · Sangat Baik\nCatatan: Rapih, urutan warna presisi",
                badge: "Kompeten",
                badgeColor: const Color(0xFF16A34A),
                icon: Icons.fact_check_rounded,
              ),
              _buildInfoTile(
                title: "Konfigurasi Dasar MikroTik",
                subtitle:
                    "Nilai: 70 · KKM: 75 · Perlu Remedial\nCatatan: Pelajari kembali subnetting",
                badge: "Remedial",
                badgeColor: const Color(0xFFEA580C),
                icon: Icons.warning_amber_rounded,
              ),
            ],
          );
        }

        // 4. Uji Kompetensi
        else if (cleanTitle.contains("Uji kompetensi")) {
          if (liveData is Map && liveData.isNotEmpty) {
            String namaKegiatan = liveData['kegiatan']?['nama_kegiatan'] ??
                'UKK LSP-P1 SMK Wisata Indonesia';
            String nilai = liveData['nilai_akhir'] != null
                ? liveData['nilai_akhir'].toString()
                : 'Terdaftar';
            return ListView(
              children: [
                _buildInfoTile(
                  title: namaKegiatan,
                  subtitle:
                      "Status: Terdaftar Peserta Resmi\nNilai Akhir: $nilai\nPenguji: LSP-P1 SMK Wisata Indonesia",
                  badge: "Terdaftar",
                  badgeColor: const Color(0xFF7C3AED),
                  icon: Icons.workspace_premium_rounded,
                ),
              ],
            );
          }
          return ListView(
            children: [
              _buildInfoTile(
                title: "UKK Skema Teknisi Madya Jaringan",
                subtitle:
                    "Status: Terdaftar Peserta Resmi\nUnit Kompetensi: 10 Unit\nPenguji: LSP-P1 SMK Wisata Indonesia",
                badge: "Terdaftar",
                badgeColor: const Color(0xFF7C3AED),
                icon: Icons.workspace_premium_rounded,
              ),
            ],
          );
        }

        // 5. Sertifikat & Portofolio
        else if (cleanTitle.contains("Sertifikat")) {
          if (liveData is List && liveData.isNotEmpty) {
            return ListView.builder(
              itemCount: liveData.length,
              itemBuilder: (context, i) {
                var item = liveData[i];
                return _buildInfoTile(
                  title: item['nama_kegiatan'] ??
                      item['judul'] ??
                      'Portofolio Siswa',
                  subtitle:
                      "Tanggal: ${item['tanggal_kegiatan'] ?? '-'}\nKategori: ${item['kategori'] ?? 'Karya Kejuruan'}",
                  badge: "Terverifikasi",
                  badgeColor: const Color(0xFF059669),
                  icon: Icons.folder_shared_rounded,
                );
              },
            );
          }
          return ListView(
            children: [
              _buildInfoTile(
                title: "Sertifikat Cisco Networking Basics",
                subtitle:
                    "Diterbitkan: 12 Agustus 2024\nNomor: CSCO-NET-2024-0891\nKategori: Sertifikasi Vendor",
                badge: "Terverifikasi",
                badgeColor: const Color(0xFF059669),
                icon: Icons.folder_shared_rounded,
              ),
            ],
          );
        }

        // 6. Tes Teori & TKK
        else if (cleanTitle.contains("TKK") || cleanTitle.contains("Teori")) {
          if (liveData is List && liveData.isNotEmpty) {
            return ListView.builder(
              itemCount: liveData.length,
              itemBuilder: (context, i) {
                var item = liveData[i];
                String namaTkk = item['jenis_tkk']?['nama_tkk'] ??
                    'Tanda Kecakapan Kejuruan';
                return _buildInfoTile(
                  title: namaTkk,
                  subtitle:
                      "SK: ${item['nomor_sertifikat'] ?? '-'}\nTanggal: ${item['tanggal_perolehan'] ?? '-'}",
                  badge: "Lulus",
                  badgeColor: const Color(0xFF0284C7),
                  icon: Icons.verified_user_rounded,
                );
              },
            );
          }
          return ListView(
            children: [
              _buildInfoTile(
                title: "TKK Tingkat Madya - Jaringan Komputer",
                subtitle:
                    "SK Pemberian: TKK/TKJ/2024/09\nTanggal Perolehan: 15 Sept 2024\nPemberi: Tim Asesor Sekolah",
                badge: "Lulus",
                badgeColor: const Color(0xFF0284C7),
                icon: Icons.verified_user_rounded,
              ),
              _buildInfoTile(
                title: "Tes Teori Kejuruan: Routing OSPF & BGP",
                subtitle:
                    "Skor: 92/100 · Predikat Sangat Baik\nTanggal: 20 Oktober 2026",
                badge: "Selesai",
                badgeColor: const Color(0xFF16A34A),
                icon: Icons.quiz_rounded,
              ),
            ],
          );
        }

        // 7. Peminjaman Alat
        else if (cleanTitle.contains("Peminjaman")) {
          return ListView(
            children: [
              _buildInfoTile(
                title: "1 MikroTik RouterBOARD RB951-2HnD",
                subtitle:
                    "Lab 2 · Dipinjam hari ini pukul 08.00 WIB\nBatas Pengembalian: 11.00 WIB\nPetugas: Pak Hendra, S.Kom",
                badge: "DIPINJAM",
                badgeColor: const Color(0xFF0284C7),
                icon: Icons.devices_other_rounded,
              ),
              _buildInfoTile(
                title: "Crimping Tool Cat6 & Stripper",
                subtitle:
                    "Lab 2 · Dikembalikan kemarin pukul 15.30 WIB\nKondisi: Baik & Lengkap",
                badge: "KEMBALI",
                badgeColor: const Color(0xFF16A34A),
                icon: Icons.home_repair_service_rounded,
              ),
              _buildInfoTile(
                title: "Digital LAN Cable Tester RJ45",
                subtitle:
                    "Lab Jaringan 1 · Dikembalikan 22 Okt 2026\nKondisi: Normal",
                badge: "SELESAI",
                badgeColor: const Color(0xFF64748B),
                icon: Icons.cable_rounded,
              ),
            ],
          );
        }

        // 8. Presensi Bengkel
        else {
          return ListView(
            children: [
              _buildInfoTile(
                title: "Praktik Konfigurasi Routing & Switching",
                subtitle:
                    "Lab Jaringan 2 · Hari Ini, 07.55 WIB\nStatus: Hadir Tepat Waktu (Presensi QR Bengkel)",
                badge: "HADIR",
                badgeColor: const Color(0xFF16A34A),
                icon: Icons.check_circle_rounded,
              ),
              _buildInfoTile(
                title: "Instalasi Patch Panel & Rack Server",
                subtitle:
                    "Bengkel Jaringan · 24 Okt 2026, 08.02 WIB\nStatus: Hadir Tepat Waktu",
                badge: "HADIR",
                badgeColor: const Color(0xFF16A34A),
                icon: Icons.check_circle_rounded,
              ),
              _buildInfoTile(
                title: "Crimping & Terminasi Kabel UTP Cat6",
                subtitle:
                    "Bengkel Jaringan · 21 Okt 2026, 08.10 WIB\nStatus: Hadir",
                badge: "HADIR",
                badgeColor: const Color(0xFF16A34A),
                icon: Icons.check_circle_rounded,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFECEFF5), width: 1),
            ),
            child: Icon(icon, color: const Color(0xFF4C3EC7), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: badgeColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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