import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';

class PresensiBengkelView extends StatefulWidget {
  final String? idSiswa;
  const PresensiBengkelView({this.idSiswa, super.key});

  @override
  State<PresensiBengkelView> createState() => _PresensiBengkelViewState();
}

class _PresensiBengkelViewState extends State<PresensiBengkelView> {
  bool _isLoading = true;
  String? _effectiveIdSiswa;

  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Hadir', 'Izin', 'Sakit', 'Alpa'];
  String _namaKelas = 'Kelas Siswa';

  // Stats
  String _persenKehadiran = "0%";
  String _totalSesi = "0/0 Sesi";
  int _hadir = 0;
  int _izin = 0;
  int _sakit = 0;
  int _alfa = 0;

  bool _sudahPresensiHariIni = false;
  String _jamPresensiHariIni = "-";

  List<Map<String, dynamic>> _riwayatPresensi = [];

  List<Map<String, dynamic>> get _filteredRiwayat {
    if (_selectedFilter == 'Semua') return _riwayatPresensi;
    return _riwayatPresensi.where((item) {
      final status = (item['status'] ?? '').toString().toLowerCase();
      return status.contains(_selectedFilter.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _effectiveIdSiswa = widget.idSiswa;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _effectiveIdSiswa ??= prefs.getString('idSiswa');
    final savedKelas = prefs.getString('namaKelas') ?? prefs.getString('kelas');
    if (savedKelas != null && savedKelas.isNotEmpty) {
      _namaKelas = savedKelas;
    }

    if (_effectiveIdSiswa != null) {
      try {
        final res = await ApiService.get(
          '/kejuruan/presensi/$_effectiveIdSiswa',
          forceRefresh: true,
          silent: true,
        );
        if (res != null && res['success'] == true && res['data'] is Map) {
          final data = res['data'];
          if (data['summary'] is Map) {
            final summary = data['summary'];
            _persenKehadiran = summary['persentase']?.toString() ?? '0%';
            _totalSesi = "${summary['hadir'] ?? 0}/${summary['total_pertemuan'] ?? 0} Sesi";
            _hadir = int.tryParse(summary['hadir'].toString()) ?? 0;
            _izin = int.tryParse(summary['izin'].toString()) ?? 0;
            _sakit = int.tryParse(summary['sakit'].toString()) ?? 0;
            _alfa = int.tryParse(summary['alpa'].toString()) ?? 0;
          }
          if (data['riwayat'] is List) {
            _riwayatPresensi = List<Map<String, dynamic>>.from(data['riwayat']);
            // Cek apakah ada catatan kehadiran hari ini
            final nowStr = DateTime.now().toIso8601String().substring(0, 10);
            final todayItem = _riwayatPresensi.firstWhere(
              (it) => (it['tanggal']?.toString() ?? '').startsWith(nowStr),
              orElse: () => {},
            );
            if (todayItem.isNotEmpty) {
              _sudahPresensiHariIni = true;
              _jamPresensiHariIni = todayItem['jam'] ?? '-';
            } else {
              _sudahPresensiHariIni = false;
            }
          }
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4C3EC7)))
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: const Color(0xFF4C3EC7),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      slivers: [
                        // 1. Hero Card & Status Hari Ini - ikut terscroll ke atas
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSummaryStats(),
                                const SizedBox(height: 12),
                                _buildTodayStatusCard(),
                              ],
                            ),
                          ),
                        ),

                        // 2. Tab Bar Filter Riwayat - menempel (pinned/sticky) di atas
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverFilterBarDelegate(
                            child: _buildFilterBar(),
                            height: 52.0,
                          ),
                        ),

                        // 3. Daftar Riwayat Presensi - terscroll di bawah tab yang terkunci
                        if (_filteredRiwayat.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _buildEmptyState(),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                            sliver: SliverList.separated(
                              itemCount: _filteredRiwayat.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                return _buildRiwayatItem(_filteredRiwayat[index]);
                              },
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

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _filters.map((fil) {
            final isSelected = _selectedFilter == fil;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedFilter = fil),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4C3EC7) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4C3EC7) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    fil,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 16, 18),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Presensi Bengkel & Lab",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      "Kedisiplinan & Log Kehadiran Praktik Vokasi",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                tooltip: 'Segarkan',
                onPressed: _loadData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStats() {
    double percentVal = double.tryParse(_persenKehadiran.replaceAll('%', '').trim()) ?? 0.0;
    final bool hasSesi = _riwayatPresensi.isNotEmpty;
    final String badgeDisiplin = !hasSesi
        ? "Belum Ada Sesi"
        : (percentVal >= 90 ? "Sangat Disiplin" : (percentVal >= 75 ? "Disiplin" : "Perlu Ditingkatkan"));
    final bool isGoodDisiplin = hasSesi && percentVal >= 75;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -6,
            child: Icon(
              Icons.verified_rounded,
              size: 104,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Badges
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.precision_manufacturing_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 5),
                          Text(
                            "Presensi Bengkel & Lab",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _namaKelas,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isGoodDisiplin ? Icons.verified_rounded : Icons.info_outline_rounded,
                            color: isGoodDisiplin ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            badgeDisiplin,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row 2: Persentase Kehadiran & Circular Ring
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tingkat Kedisiplinan Praktik",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                _persenKehadiran,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _totalSesi,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Akumulasi Log Jurnal Praktik Guru",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: CircularProgressIndicator(
                              value: percentVal / 100,
                              strokeWidth: 6.5,
                              strokeCap: StrokeCap.round,
                              backgroundColor: const Color(0xFF38BDF8).withValues(alpha: 0.28),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${percentVal.round()}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                              const Text(
                                "Masuk",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row 3: Bottom Stat Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomStatItem("HADIR", "$_hadir Sesi", const Color(0xFF4ADE80)),
                      Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.15)),
                      _buildBottomStatItem("IZIN", "$_izin Sesi", const Color(0xFF38BDF8)),
                      Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.15)),
                      _buildBottomStatItem("SAKIT", "$_sakit Sesi", const Color(0xFFFBBF24)),
                      Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.15)),
                      _buildBottomStatItem("ALPA", "$_alfa Sesi", Colors.white70),
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

  Widget _buildBottomStatItem(String title, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Colors.white60,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sudahPresensiHariIni ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _sudahPresensiHariIni ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: _sudahPresensiHariIni ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _sudahPresensiHariIni ? "SUDAH TERABSEN" : "SISTEM ABSENSI",
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const Spacer(),
              const Row(
                children: [
                  Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 4),
                  Text(
                    "Jurnal Praktik Guru",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _sudahPresensiHariIni ? "Presensi Hari Ini Tercatat" : "Presensi Bengkel & Lab Siswa",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Text(
            _sudahPresensiHariIni
                ? "Tercatat hadir pada sesi praktik hari ini ($_jamPresensiHariIni) melalui pengisian jurnal praktik oleh guru pengampu."
                : "Presensi dicatat langsung oleh guru pengampu mata pelajaran saat mengisi Jurnal Praktik di laboratorium.",
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(Map<String, dynamic> item) {
    Color badgeColor = const Color(0xFF16A34A);
    final statusStr = (item['status'] ?? '').toString().toLowerCase();
    if (statusStr.contains('sakit')) {
      badgeColor = const Color(0xFFD97706);
    } else if (statusStr.contains('izin')) {
      badgeColor = const Color(0xFF0284C7);
    } else if (statusStr.contains('alpa') || statusStr.contains('alfa')) {
      badgeColor = const Color(0xFFDC2626);
    } else if (item['badge_color'] is Color) {
      badgeColor = item['badge_color'];
    }

    final tgl = item['tanggal_formatted'] ?? item['tanggal'] ?? '-';
    final mapel = item['mapel'] ?? item['materi'] ?? '-';
    final lab = item['lab'] ?? 'Lab Kejuruan';
    final jam = item['jam'] ?? item['jam_masuk'] ?? '-';
    final status = item['status'] ?? 'Hadir';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.access_time_rounded, color: badgeColor, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tgl,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  mapel,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  "$lab • Jam: $jam",
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_busy_rounded, size: 44, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 14),
            const Text(
              "Tidak Ada Riwayat",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 4),
            const Text(
              "Tidak ditemukan catatan presensi untuk filter ini.",
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverFilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverFilterBarDelegate({
    required this.child,
    this.height = 52.0,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isPinned = shrinkOffset > 4;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        boxShadow: isPinned
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverFilterBarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
