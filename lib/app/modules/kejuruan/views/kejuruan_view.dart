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
    'judul': 'Instalasi jaringan LAN',
    'lab': 'Lab 2',
    'jam': '08.00 sampai 10.15',
    'guru': 'Pak Andi',
    'subtitle': 'Lab 2 · 08.00 sampai 10.15 · Pak Andi',
    'alat_bahan': 'kabel UTP, crimping tool, LAN tester',
    'catatan_modul': 'Baca modul sebelum praktik',
    'badge': 'Hari ini',
  };

  // 3 Stats
  String kehadiranPraktik = "94%";
  String rataRataNilai = "82";
  String perluRemedial = "1";

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
            rataRataNilai = stats['rata_rata_nilai'] ?? rataRataNilai;
            perluRemedial = stats['perlu_remedial'] ?? perluRemedial;
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
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card 1: Praktik Berikutnya
                          _buildPraktikBerikutnyaCard(),
                          const SizedBox(height: 14),

                          // 3 Kartu Statistik (Kehadiran, Rata-rata Nilai, Remedial)
                          _buildStatCardsRow(),
                          const SizedBox(height: 18),

                          // 6 Tombol Sub-Menu Kejuruan (2 x 3)
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
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
                  const SizedBox(height: 14),

                  // Hero Floating Card Profil Siswa & Program Kejuruan (Konsisten Jadwal/Poin)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Ikon Kotak Kejuruan
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.architecture_rounded,
                            color: Color(0xFF16A34A),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),

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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEEF2FF),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C3EC7).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Label & Pill Badge "Hari ini"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Praktik berikutnya",
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  praktikBerikutnya['badge'] ?? 'Hari ini',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4C3EC7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Judul Praktik
          Text(
            praktikBerikutnya['judul'] ?? 'Instalasi jaringan LAN',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle (Lab, Jam, Guru)
          Text(
            praktikBerikutnya['subtitle'] ??
                'Lab 2 · 08.00 sampai 10.15 · Pak Andi',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          // Item 1: Bawa perlengkapan
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.work_outline_rounded,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Bawa: ${praktikBerikutnya['alat_bahan'] ?? 'kabel UTP, crimping tool, LAN tester'}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Item 2: Baca modul sebelum praktik (Link style)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openSubMenu("Modul praktik"),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: Color(0xFF4C3EC7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      praktikBerikutnya['catatan_modul'] ??
                          'Baca modul sebelum praktik',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4C3EC7),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardsRow() {
    return Row(
      children: [
        // 1. Kehadiran praktik (94%)
        Expanded(
          child: _buildSingleStatCard(
            value: kehadiranPraktik,
            valueColor: const Color(0xFF16A34A),
            label: "Kehadiran\npraktik",
          ),
        ),
        const SizedBox(width: 10),

        // 2. Rata-rata nilai praktik (82)
        Expanded(
          child: _buildSingleStatCard(
            value: rataRataNilai,
            valueColor: const Color(0xFF1E293B),
            label: "Rata-rata nilai\npraktik",
          ),
        ),
        const SizedBox(width: 10),

        // 3. Perlu remedial (1)
        Expanded(
          child: _buildSingleStatCard(
            value: perluRemedial,
            valueColor: const Color(0xFFD97706),
            label: "Perlu\nremedial",
          ),
        ),
      ],
    );
  }

  Widget _buildSingleStatCard({
    required String value,
    required Color valueColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECEFF5), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: valueColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      // 1. Jadwal praktik
      _KejuruanMenuItem(
        title: "Jadwal\npraktik",
        icon: Icons.calendar_month_rounded,
        bgColor: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFF0284C7),
        onTap: () => _openSubMenu("Jadwal praktik"),
      ),
      // 2. Modul praktik
      _KejuruanMenuItem(
        title: "Modul\npraktik",
        icon: Icons.menu_book_rounded,
        bgColor: const Color(0xFFFFEDD5),
        iconColor: const Color(0xFFEA580C),
        onTap: () => _openSubMenu("Modul praktik"),
      ),
      // 3. Nilai praktik
      _KejuruanMenuItem(
        title: "Nilai praktik",
        icon: Icons.fact_check_rounded,
        bgColor: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF059669),
        onTap: () => _openSubMenu("Nilai praktik"),
      ),
      // 4. Uji kompetensi
      _KejuruanMenuItem(
        title: "Uji\nkompetensi",
        icon: Icons.workspace_premium_rounded,
        bgColor: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF9333EA),
        onTap: () => _openSubMenu("Uji kompetensi"),
      ),
      // 5. Sertifikat dan portofolio
      _KejuruanMenuItem(
        title: "Sertifikat\ndan\nportofolio",
        icon: Icons.folder_rounded,
        bgColor: const Color(0xFFFFE4E6),
        iconColor: const Color(0xFFE11D48),
        onTap: () => _openSubMenu("Sertifikat dan portofolio"),
      ),
      // 6. TKK
      _KejuruanMenuItem(
        title: "TKK",
        icon: Icons.lock_rounded,
        bgColor: const Color(0xFFF1F5F9),
        iconColor: const Color(0xFF475569),
        onTap: () => _openSubMenu("TKK"),
      ),
    ];

    return Column(
      children: [
        // Baris 1: Jadwal, Modul, Nilai
        Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: _buildGridButton(menuItems[i]),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // Baris 2: Uji kompetensi, Sertifikat dan portofolio, TKK
        Row(
          children: [
            for (int i = 3; i < 6; i++) ...[
              if (i > 3) const SizedBox(width: 10),
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
        borderRadius: BorderRadius.circular(20),
        splashColor: item.iconColor.withValues(alpha: 0.12),
        highlightColor: item.iconColor.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFECEFF5), width: 1.1),
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
              // Squircle Container Icon Warna Pastel Sesuai SIAWI App
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  item.icon,
                  color: item.iconColor,
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),

              // Title label
              SizedBox(
                height: 36,
                child: Center(
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      height: 1.2,
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
    } else if (clean.contains("Uji kompetensi")) {
      endpoint = '/kejuruan/ukk/$idSiswa';
    } else if (clean.contains("Sertifikat")) {
      endpoint = '/kejuruan/portofolio/$idSiswa';
    } else {
      endpoint = '/kejuruan/tkk/$idSiswa';
    }

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

        // 6. TKK
        else {
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