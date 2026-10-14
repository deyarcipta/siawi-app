import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/about/widget/about.dart';
import 'package:siawi_app/app/modules/home/widget/version_checker.dart';
import 'package:siawi_app/utils/colors.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  int _activeTab = 0; // 0: Aplikasi & Sekolah, 1: Visi & Misi, 2: Jurusan

  @override
  Widget build(BuildContext context) {
    final String version = VersionChecker.appVersion;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Tentang SIAWI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  'v$version',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. HERO BRANDING CARD
            _buildHeroSection(version),

            // 2. SEGMENTED TAB SWITCHER
            _buildSegmentedTabs(),

            // 3. TAB CONTENT
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildCurrentTabContent(),
              ),
            ),

            // 4. FOOTER INFORMASI SEKOLAH & HAK CIPTA
            _buildFooterSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(String version) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainColor.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        children: [
          // Logo Sekolah dalam Container Melayang
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: ClipOval(
              child: Image.asset(
                'assets/logo/logo-splash.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Nama Sekolah & Nama Aplikasi
          const Text(
            'SMK WISATA INDONESIA',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sistem Informasi Akademik (SIAWI)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Badges Akreditasi & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPillTag(Icons.verified_rounded, "Terakreditasi A"),
              const SizedBox(width: 8),
              _buildPillTag(Icons.school_rounded, "SMK Pusat Keunggulan"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    final List<String> tabLabels = ["Aplikasi", "Visi & Misi", "Jurusan"];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            for (int i = 0; i < tabLabels.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTab = i;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color:
                          _activeTab == i ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _activeTab == i
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tabLabels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            _activeTab == i ? FontWeight.w800 : FontWeight.w600,
                        color: _activeTab == i
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_activeTab) {
      case 0:
        return _buildTabAplikasi();
      case 1:
        return _buildTabVisiMisi();
      case 2:
        return _buildTabJurusan();
      default:
        return _buildTabAplikasi();
    }
  }

  // TAB 1: APLIKASI & EKOSISTEM SIAWI
  Widget _buildTabAplikasi() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          icon: Icons.hub_rounded,
          iconColor: const Color(0xFF4F46E5),
          iconBg: const Color(0xFFEEF2FF),
          title: "Tentang SIAWI Mobile",
          content:
              "Aplikasi Sistem Informasi Akademik SMK Wisata Indonesia (SIAWI) adalah platform digital terpadu yang dirancang untuk mempermudah siswa dan orang tua dalam mengakses informasi akademik, kedisiplinan, serta administrasi sekolah secara transparan dan realtime.",
        ),
        const SizedBox(height: 14),
        _buildFeaturesListCard(),
        const SizedBox(height: 14),
        _buildSekolahOverviewCard(),
      ],
    );
  }

  Widget _buildFeaturesListCard() {
    final features = [
      {
        "icon": Icons.fingerprint_rounded,
        "title": "Presensi Biometrik & Streak",
        "desc":
            "Pencatatan kehadiran gerbang otomatis berbasis RFID & Face ID dengan gamifikasi streak disiplin.",
        "color": const Color(0xFF0D9488),
      },
      {
        "icon": Icons.work_outline_rounded,
        "title": "Layanan PKL & Hubin",
        "desc":
            "Pengajuan surat pengantar PKL mandiri, monitoring tempat magang, dan mitra DUDI resmi.",
        "color": const Color(0xFF2563EB),
      },
      {
        "icon": Icons.auto_stories_rounded,
        "title": "Jadwal & Modul Pembelajaran",
        "desc":
            "Akses jadwal pelajaran harian, materi modul mata pelajaran, serta agenda kalender pendidikan.",
        "color": const Color(0xFFD97706),
      },
      {
        "icon": Icons.analytics_rounded,
        "title": "Nilai Rapor & Poin Siswa",
        "desc":
            "Pantau pencapaian akademik berkala dan riwayat rekapitulasi poin kedisiplinan siswa.",
        "color": const Color(0xFF7C3AED),
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFECEFF5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Fitur Unggulan Sistem",
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < features.length; i++) ...[
            if (i > 0) const Divider(height: 20, color: Color(0xFFF1F5F9)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        (features[i]["color"] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    features[i]["icon"] as IconData,
                    size: 20,
                    color: features[i]["color"] as Color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        features[i]["title"] as String,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        features[i]["desc"] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSekolahOverviewCard() {
    return _buildInfoCard(
      icon: Icons.account_balance_rounded,
      iconColor: const Color(0xFF0284C7),
      iconBg: const Color(0xFFE0F2FE),
      title: "Profil SMK Wisata Indonesia",
      content:
          "SMK Wisata Indonesia berlokasi strategis di Jakarta Selatan, berdiri kokoh dengan komitmen melahirkan sumber daya manusia unggul yang profesional, beretika luhur, dan kompetitif dalam industri pariwisata dan teknologi modern.",
    );
  }

  // TAB 2: VISI & MISI
  Widget _buildTabVisiMisi() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kartu Visi
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lightbulb_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "VISI SEKOLAH",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF312E81),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "\"${About.visi}\"",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Kartu Misi Berurutan
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFECEFF5), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.rocket_launch_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "MISI SEKOLAH",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF065F46),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (int i = 0; i < About.misiList.length; i++) ...[
                if (i > 0) const Divider(height: 22, color: Color(0xFFF1F5F9)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${i + 1}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        About.misiList[i],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF334155),
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // TAB 3: JURUSAN KEJURUAN
  Widget _buildTabJurusan() {
    final List<Map<String, dynamic>> jurusanMeta = [
      {
        "kode": "PH",
        "nama": "Perhotelan",
        "tagline": "Hospitality & Tourism Excellence",
        "icon": Icons.hotel_rounded,
        "color": const Color(0xFF0284C7),
        "bg": const Color(0xFFF0F9FF),
        "desc":
            "Mempersiapkan tenaga ahli bidang perhotelan berstandar internasional, meliputi Front Office, Housekeeping, Laundry, Food & Beverage Service, serta Hospitality Etiquette.",
      },
      {
        "kode": "KUL",
        "nama": "Kuliner (Tata Boga)",
        "tagline": "Culinary Arts & Gastronomy",
        "icon": Icons.restaurant_rounded,
        "color": const Color(0xFFEA580C),
        "bg": const Color(0xFFFFF7ED),
        "desc":
            "Membekali keterampilan seni memasak masakan Nusantara, Oriental, Kontinental, Pastry & Bakery, higienitas sanitasi makanan, hingga manajemen operasional kitchen & wirausaha boga.",
      },
      {
        "kode": "TJKT",
        "nama": "Teknik Jaringan Komputer & Telekomunikasi",
        "tagline": "Network Engineering & Cyber Technology",
        "icon": Icons.lan_rounded,
        "color": const Color(0xFF4F46E5),
        "bg": const Color(0xFFEEF2FF),
        "desc":
            "Menguasai perancangan dan administrasi infrastruktur jaringan komputer, instalasi Fiber Optic, server cloud computing, sistem keamanan siber, dan telekomunikasi digital.",
      },
    ];

    return Column(
      key: const ValueKey(2),
      children: [
        for (var jur in jurusanMeta) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFECEFF5), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: jur["bg"] as Color,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Icon(jur["icon"] as IconData,
                          color: jur["color"] as Color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  jur["nama"] as String,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E293B),
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (jur["color"] as Color)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  jur["kode"] as String,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: jur["color"] as Color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            jur["tagline"] as String,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: jur["color"] as Color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  jur["desc"] as String,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFECEFF5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEEF2FF), Color(0xFFF8FAFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC7D2FE),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo/logo-wistek.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.terminal_rounded,
                        size: 16,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Row(
                      children: [
                        Text(
                          "Wistin Teknologi",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          "• TJKT",
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Inovasi Digital & Teaching Factory TJKT",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "© 2024 SMK Wisata Indonesia. All Rights Reserved.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
