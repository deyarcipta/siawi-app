import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:siawi_app/app/modules/absensi/widget/absen_list.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AbsensiView extends StatefulWidget {
  final VoidCallback signOut;
  const AbsensiView(this.signOut, {super.key});

  @override
  State<AbsensiView> createState() => _AbsensiViewState();
}

class _AbsensiViewState extends State<AbsensiView> {
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  String? _errorMessage;

  List<AbsenList> _absenList = [];
  String? _namaSiswa;
  String? _nisSiswa;
  String? _kelasSiswa;

  String _jumlahHadir = '0';
  String _jumlahSakit = '0';
  String _jumlahIzin = '0';
  String _jumlahAlfa = '0';
  String _jumlahTidakHadir = '0';
  int _presentaseKehadiran = 0;

  // Filter aktif: 'semua', 'hadir', 'sakit', 'izin', 'alfa'
  String _selectedFilter = 'semua';

  // Pagination / Lazy Loading Config
  final int _pageSize = 15;
  int _displayedCount = 15;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadAbsensiData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Listener scroll untuk memuat data tambahan ketika mendekati dasar layar
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    if (_isLoadingMore) return;
    if (_displayedCount >= _filteredList.length) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulasi delay halus 400ms agar efek reload bawah terlihat natural
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _displayedCount =
              (_displayedCount + _pageSize).clamp(0, _filteredList.length);
          _isLoadingMore = false;
        });
      }
    });
  }

  Future<String?> _getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('idSiswa');
  }

  Future<void> _loadAbsensiData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _displayedCount = _pageSize;
    });

    try {
      final idSiswa = await _getIdSiswa();
      if (idSiswa == null || idSiswa.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = "ID Siswa tidak ditemukan. Silakan login kembali.";
        });
        return;
      }

      dynamic dataAbsen;
      try {
        // Coba via ApiService yang memiliki cache dan connection handling
        dataAbsen = await ApiService.get('/absensi/$idSiswa', forceRefresh: forceRefresh);
      } catch (_) {
        // Fallback langsung ke HTTP jika ApiService mengalami kendala
        final response = await http.get(
          Uri.parse('https://siawi.smkwisataindonesia.sch.id/api/absensi/$idSiswa'),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          dataAbsen = json.decode(response.body);
        } else {
          throw Exception("Gagal memuat data presensi (HTTP ${response.statusCode})");
        }
      }

      if (dataAbsen != null && mounted) {
        final siswaData = dataAbsen['dataSiswa'] ?? {};
        final kelasData = siswaData['kelas'] ?? {};
        final List<dynamic> listData = dataAbsen['data'] ?? [];

        List<AbsenList> parsedList = [];
        for (var item in listData) {
          parsedList.add(AbsenList.fromJson(item));
        }

        setState(() {
          _namaSiswa = siswaData['nama_siswa']?.toString() ?? 'Siswa';
          _nisSiswa = siswaData['nis']?.toString() ?? '-';
          _kelasSiswa = kelasData['nama_kelas']?.toString() ?? siswaData['nama_kelas']?.toString() ?? '-';

          _jumlahHadir = (dataAbsen['jumlahHadir'] ?? '0').toString();
          _jumlahSakit = (dataAbsen['jumlahSakit'] ?? '0').toString();
          _jumlahIzin = (dataAbsen['jumlahIzin'] ?? '0').toString();
          _jumlahAlfa = (dataAbsen['jumlahAlfa'] ?? '0').toString();
          _jumlahTidakHadir = (dataAbsen['jumlahTidakHadir'] ?? '0').toString();

          _presentaseKehadiran = int.tryParse(
                dataAbsen['presentaseKehadiran']?.toString() ?? '0',
              ) ??
              0;

          _absenList = parsedList;
          _displayedCount = _pageSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memuat data presensi. Periksa koneksi internet Anda.";
        });
      }
    }
  }

  List<AbsenList> get _filteredList {
    if (_selectedFilter == 'semua') return _absenList;
    return _absenList.where((item) {
      return item.keterangan.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  Color _getPercentageColor(int percent) {
    if (percent >= 85) return const Color(0xFF10B981); // Emerald Green
    if (percent >= 75) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }

  String _getAttendanceQuality(int percent) {
    if (percent >= 90) return "Sangat Baik";
    if (percent >= 80) return "Baik";
    if (percent >= 75) return "Cukup";
    return "Perlu Ditingkatkan";
  }

  @override
  Widget build(BuildContext context) {
    final percentValue = (_presentaseKehadiran.clamp(0, 100)) / 100.0;
    final themeColor = _getPercentageColor(_presentaseKehadiran);
    final displayedItems = _filteredList.take(_displayedCount).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF4C3EC7),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Presensi Kehadiran',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              'Tahun Ajaran Aktif • Semester Ganjil',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
            tooltip: 'Segarkan Data',
            onPressed: () => _loadAbsensiData(forceRefresh: true),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Image.asset(
                'assets/logo/logo-splash.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4C3EC7),
                strokeWidth: 2.8,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEE2E2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.wifi_off_rounded,
                            size: 40,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _loadAbsensiData(forceRefresh: true),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text("Coba Lagi"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C3EC7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    // 1. BACKGROUND LAYER: BASE SOFT GRADIENT
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFF8FAFC),
                            Color(0xFFF1F5F9),
                            Color(0xFFEEF2FF),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    // 2. BACKGROUND LAYER: TOP CURVED SIAWI GRADIENT BANNER
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF4C3EC7),
                            Color(0xFF5B4BD1),
                            Color(0xFF6B5DE8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(36),
                          bottomRight: Radius.circular(36),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Ornamen lingkaran 1 di kanan atas
                          Positioned(
                            top: -45,
                            right: -30,
                            child: Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          // Ornamen lingkaran 2 di kiri bawah
                          Positioned(
                            bottom: -35,
                            left: -25,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                          ),
                          // Ornamen lingkaran 3 kecil di tengah
                          Positioned(
                            top: 25,
                            right: 120,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. BACKGROUND LAYER: AMBIENT GLOW BLOBS
                    Positioned(
                      top: 320,
                      right: -70,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEDE9FE).withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 80,
                      left: -60,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE0F2FE).withValues(alpha: 0.40),
                        ),
                      ),
                    ),

                    // 4. WATERMARK SILUET IKON DI POJOK BAWAH
                    Positioned(
                      bottom: 20,
                      right: -20,
                      child: IgnorePointer(
                        child: Icon(
                          Icons.fact_check_rounded,
                          size: 160,
                          color: const Color(0xFF6366F1).withValues(alpha: 0.03),
                        ),
                      ),
                    ),

                    // 5. KONTEN UTAMA DENGAN REFRESH INDICATOR & SCROLL CONTROLLER
                    RefreshIndicator(
                      color: const Color(0xFF4C3EC7),
                      onRefresh: () => _loadAbsensiData(forceRefresh: true),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HEADER SAPAAN & BADGE RESMI DI ATAS BANNER UNGU
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.verified_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Sistem Presensi SIAWI",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Tap Biometrik & Piket",
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "Rekap Kehadiran Siswa",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Monitoring keaktifan harian, jam masuk & riwayat presensi",
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 1. KARTU HERO OVERVIEW PRESENSI MODERN (OVERLAPPING CURVE)
                            _buildHeroOverviewCard(percentValue, themeColor),

                            const SizedBox(height: 20),

                            // 2. 4 KARTU STATISTIK DETIL (GRID 4 PILLS)
                            _buildStatsSummaryGrid(),

                            const SizedBox(height: 24),

                            // 3. BARIS JUDUL RIWAYAT & FILTER (ADAPTIF TERHADAP SCROLL & BACKGROUND UNGU)
                            AnimatedBuilder(
                              animation: _scrollController,
                              builder: (context, _) {
                                final offset = _scrollController.hasClients
                                    ? _scrollController.offset
                                    : 0.0;
                                // Transisi halus saat judul bergerak memasuki area curved banner ungu (offset 160-220)
                                final t = ((offset - 160) / 60.0).clamp(0.0, 1.0);
                                final titleColor = Color.lerp(
                                      const Color(0xFF0F172A),
                                      Colors.white,
                                      t,
                                    ) ??
                                    const Color(0xFF0F172A);

                                final badgeBgColor = Color.lerp(
                                      const Color(0xFFEDE9FE),
                                      Colors.white.withValues(alpha: 0.22),
                                      t,
                                    ) ??
                                    const Color(0xFFEDE9FE);

                                final badgeTextColor = Color.lerp(
                                      const Color(0xFF6366F1),
                                      Colors.white,
                                      t,
                                    ) ??
                                    const Color(0xFF6366F1);

                                final badgeBorderColor = Color.lerp(
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.4),
                                      t,
                                    ) ??
                                    Colors.transparent;

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.history_rounded,
                                          size: 18,
                                          color: titleColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Riwayat Kehadiran",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: titleColor,
                                            letterSpacing: -0.3,
                                            shadows: t > 0
                                                ? [
                                                    Shadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.25 * t,
                                                          ),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 1),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: badgeBgColor,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: badgeBorderColor,
                                          width: 1.1,
                                        ),
                                      ),
                                      child: Text(
                                        "Tampil ${displayedItems.length} dari ${_filteredList.length} Hari",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: badgeTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // 4. CHIP FILTER KATEGORI (HORIZONTAL SCROLL)
                            _buildFilterChips(),

                            const SizedBox(height: 16),

                            // 5. DAFTAR RIWAYAT PRESENSI (PAGINATED 15 PER VIEW)
                            if (_filteredList.isEmpty)
                              _buildEmptyState()
                            else ...[
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: displayedItems.length,
                                itemBuilder: (context, index) {
                                  final item = displayedItems[index];
                                  return _buildAttendanceItemCard(item);
                                },
                              ),

                              // INDIKATOR LOADING SCROLL / RELOAD BAWAH
                              if (_isLoadingMore)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.03),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              color: Color(0xFF4C3EC7),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Memuat data kehadiran lainnya...",
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else if (_displayedCount < _filteredList.length)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Center(
                                    child: TextButton.icon(
                                      onPressed: _loadMoreData,
                                      icon: const Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 16,
                                        color: Color(0xFF4C3EC7),
                                      ),
                                      label: Text(
                                        "Muat ${_filteredList.length - _displayedCount > _pageSize ? _pageSize : _filteredList.length - _displayedCount} data lagi (Total ${_filteredList.length})",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF4C3EC7),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              else if (_filteredList.length > _pageSize)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Text(
                                      "Semua riwayat kehadiran telah ditampilkan (${_filteredList.length} hari)",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  // ==========================================
  // WIDGET 1: HERO OVERVIEW CARD
  // ==========================================
  Widget _buildHeroOverviewCard(double percentValue, Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C3EC7).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Indicator Modern
          CircularPercentIndicator(
            animation: true,
            animationDuration: 1200,
            radius: 50.0,
            lineWidth: 9.0,
            percent: percentValue,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$_presentaseKehadiran%",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22.0,
                    color: themeColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  "Presensi",
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFF1F5F9),
            progressColor: themeColor,
            circularStrokeCap: CircularStrokeCap.round,
          ),

          const SizedBox(width: 18),

          // Detail Kualitas & Identitas
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getAttendanceQuality(_presentaseKehadiran),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: themeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _namaSiswa ?? 'Siswa SIAWI',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "NIS: ${_nisSiswa ?? '-'} • Kelas: ${_kelasSiswa ?? '-'}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),
                // Total Hari Info Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.date_range_rounded,
                        size: 13,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "$_jumlahHadir Hari Hadir • $_jumlahTidakHadir Hari Absen",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
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
    );
  }

  // ==========================================
  // WIDGET 2: 4 KARTU STATISTIK GRID
  // ==========================================
  Widget _buildStatsSummaryGrid() {
    return Row(
      children: [
        // 1. HADIR
        Expanded(
          child: _buildStatItem(
            title: "Hadir",
            count: _jumlahHadir,
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF10B981),
            bgColor: const Color(0xFFECFDF5),
            borderColor: const Color(0xFFA7F3D0),
          ),
        ),
        const SizedBox(width: 8),

        // 2. SAKIT
        Expanded(
          child: _buildStatItem(
            title: "Sakit",
            count: _jumlahSakit,
            icon: Icons.medical_services_rounded,
            color: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFFFBEB),
            borderColor: const Color(0xFFFDE68A),
          ),
        ),
        const SizedBox(width: 8),

        // 3. IZIN
        Expanded(
          child: _buildStatItem(
            title: "Izin",
            count: _jumlahIzin,
            icon: Icons.assignment_turned_in_rounded,
            color: const Color(0xFF0EA5E9),
            bgColor: const Color(0xFFF0F9FF),
            borderColor: const Color(0xFFBAE6FD),
          ),
        ),
        const SizedBox(width: 8),

        // 4. ALFA
        Expanded(
          child: _buildStatItem(
            title: "Alfa",
            count: _jumlahAlfa,
            icon: Icons.cancel_rounded,
            color: const Color(0xFFEF4444),
            bgColor: const Color(0xFFFEF2F2),
            borderColor: const Color(0xFFFECACA),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET 3: CHIP FILTER KATEGORI
  // ==========================================
  Widget _buildFilterChips() {
    final filters = [
      {'key': 'semua', 'label': 'Semua', 'count': _absenList.length},
      {'key': 'hadir', 'label': 'Hadir', 'count': int.tryParse(_jumlahHadir) ?? 0},
      {'key': 'sakit', 'label': 'Sakit', 'count': int.tryParse(_jumlahSakit) ?? 0},
      {'key': 'izin', 'label': 'Izin', 'count': int.tryParse(_jumlahIzin) ?? 0},
      {'key': 'alfa', 'label': 'Alfa', 'count': int.tryParse(_jumlahAlfa) ?? 0},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  _selectedFilter = f['key'] as String;
                  _displayedCount = _pageSize; // Reset pagination per filter
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4C3EC7) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.85)
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.3 : 1.1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF4C3EC7).withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      f['label'] as String,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${f['count']}",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // WIDGET 4: KARTU RIWAYAT PRESENSI PER ITEM
  // ==========================================
  Widget _buildAttendanceItemCard(AbsenList item) {
    final statusColor = item.warna;
    final isAutomatic = item.tipeAbsen.toLowerCase().contains('otomatis') ||
        item.tipeAbsen.toLowerCase().contains('face');
    final isPiket = item.tipeAbsen.toLowerCase().contains('piket') ||
        item.tipeAbsen.toLowerCase().contains('terlambat');
    final isManual = item.isManualHadir;
    final isManualAndPulangMesin = item.isManualHadir && item.isPulangMesin;

    IconData statusIcon;
    if (item.isSakit) {
      statusIcon = Icons.medical_services_rounded;
    } else if (item.isIzin) {
      statusIcon = Icons.assignment_turned_in_rounded;
    } else if (item.isAlfa) {
      statusIcon = Icons.cancel_rounded;
    } else {
      statusIcon = Icons.check_circle_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Atas: Tanggal, Hari & Badge Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Avatar Status
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(statusIcon, color: statusColor, size: 22),
                  ),
                ),
                const SizedBox(width: 12),

                // Hari & Tanggal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${item.hari.toUpperCase()}, ${item.tanggal}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.status,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge Tipe Pencatatan (Biometrik / Piket / Manual / Manual & Pulang Scan)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isManualAndPulangMesin
                        ? const Color(0xFFEEF2FF)
                        : (isAutomatic
                            ? const Color(0xFFECFDF5)
                            : isPiket
                                ? const Color(0xFFFFFBEB)
                                : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isManualAndPulangMesin
                          ? const Color(0xFFC7D2FE)
                          : (isAutomatic
                              ? const Color(0xFFA7F3D0)
                              : isPiket
                                  ? const Color(0xFFFDE68A)
                                  : const Color(0xFFE2E8F0)),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isManualAndPulangMesin
                            ? Icons.sync_alt_rounded
                            : (isAutomatic
                                ? Icons.face_retouching_natural
                                : isPiket
                                    ? Icons.access_time_filled_rounded
                                    : Icons.person_rounded),
                        size: 12,
                        color: isManualAndPulangMesin
                            ? const Color(0xFF4F46E5)
                            : (isAutomatic
                                ? const Color(0xFF059669)
                                : isPiket
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isManualAndPulangMesin
                            ? "Manual & Scan"
                            : (isAutomatic
                                ? "Biometrik"
                                : isPiket
                                    ? "Piket"
                                    : "Manual"),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isManualAndPulangMesin
                              ? const Color(0xFF4F46E5)
                              : (isAutomatic
                                  ? const Color(0xFF059669)
                                  : isPiket
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Baris Bawah: Waktu Masuk & Pulang
            Row(
              children: [
                // Jam Masuk / Indikator Manual
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isManual
                              ? Icons.edit_note_rounded
                              : Icons.login_rounded,
                          size: 16,
                          color: isManual
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Masuk",
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                isManual
                                    ? "Manual Guru"
                                    : (item.jamMasuk.isNotEmpty && item.jamMasuk != '-'
                                        ? item.jamMasuk
                                        : '--:--'),
                                style: TextStyle(
                                  fontSize: isManual ? 11 : 12,
                                  fontWeight: FontWeight.w700,
                                  color: isManual
                                      ? const Color(0xFF4F46E5)
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Jam Pulang (Otomatis menampilkan jam scan jika tap pulang di mesin)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.hasPulang
                              ? (item.isPulangMesin
                                  ? Icons.face_retouching_natural
                                  : Icons.logout_rounded)
                              : Icons.logout_rounded,
                          size: 15,
                          color: item.hasPulang
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.isPulangMesin ? "Pulang (Scan)" : "Pulang",
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                item.hasPulang ? item.jamPulang : '--:--',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: item.hasPulang
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFF94A3B8),
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
            ),

            // Catatan Alasan / Informasi Keterangan (Tanpa tanda strip '-')
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isManual
                    ? const Color(0xFFEEF2FF)
                    : (item.isSakit || item.isIzin
                        ? const Color(0xFFFFFBEB)
                        : (item.isAlfa
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFF8FAFC))),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isManual
                      ? const Color(0xFFC7D2FE)
                      : (item.isSakit || item.isIzin
                          ? const Color(0xFFFDE68A)
                          : (item.isAlfa
                              ? const Color(0xFFFECACA)
                              : const Color(0xFFE2E8F0))),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isManual
                        ? Icons.info_outline_rounded
                        : (item.isSakit || item.isIzin
                            ? Icons.chat_bubble_outline_rounded
                            : (item.isAlfa
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline_rounded)),
                    size: 13.5,
                    color: isManual
                        ? const Color(0xFF4F46E5)
                        : (item.isSakit || item.isIzin
                            ? const Color(0xFFD97706)
                            : (item.isAlfa
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF059669))),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.keteranganDeskripsi,
                      style: TextStyle(
                        fontSize: 11,
                        color: isManual
                            ? const Color(0xFF3730A3)
                            : (item.isSakit || item.isIzin
                                ? const Color(0xFF92400E)
                                : (item.isAlfa
                                    ? const Color(0xFF991B1B)
                                    : const Color(0xFF475569))),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
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

  // ==========================================
  // WIDGET 5: EMPTY STATE
  // ==========================================
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFEDE9FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 36,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _selectedFilter == 'semua'
                ? "Belum ada riwayat kehadiran"
                : "Tidak ada data kategori '${_selectedFilter.toUpperCase()}'",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Data absensi akan muncul secara otomatis setelah siswa tercatat di gerbang atau oleh guru piket.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
