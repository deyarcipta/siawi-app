import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/modules/jadwal/widget/jadwal_list.dart';

class JadwalView extends StatefulWidget {
  final VoidCallback signOut;

  const JadwalView(this.signOut, {super.key});

  @override
  State<JadwalView> createState() => _JadwalViewState();
}

class _JadwalViewState extends State<JadwalView>
    with SingleTickerProviderStateMixin {
  final List<String> _tabs = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
  late TabController _tabController;

  String? _namaKelas;
  String? _namaJurusan;
  String? _namaSiswa;

  @override
  void initState() {
    super.initState();
    final todayIndex = _getTodayIndex();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: todayIndex,
    );
    _loadDataSiswa();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _getTodayIndex() {
    final weekday = DateTime.now().weekday; // 1 = Senin, ..., 7 = Minggu
    if (weekday >= 1 && weekday <= 5) {
      return weekday - 1;
    }
    return 0; // Default ke Senin jika weekend
  }

  bool _isToday(int index) {
    final weekday = DateTime.now().weekday;
    return weekday >= 1 && weekday <= 5 && (weekday - 1) == index;
  }

  Future<void> _loadDataSiswa() async {
    final preferences = await SharedPreferences.getInstance();
    final idSiswa = preferences.getString('idSiswa');
    if (idSiswa == null || idSiswa.isEmpty) return;

    try {
      final datasiswa = await ApiService.get('/home/$idSiswa');
      if (datasiswa != null && datasiswa['data'] != null) {
        final siswaData = datasiswa['data'];
        final kelasData = siswaData['kelas'];
        final jurusanData = siswaData['jurusan'];

        if (mounted) {
          setState(() {
            _namaKelas = kelasData?['nama_kelas']?.toString();
            _namaJurusan = jurusanData?['nama_jurusan']?.toString();
            _namaSiswa = siswaData['nama_siswa']?.toString() ??
                siswaData['nama']?.toString();
          });
        }
      }
    } catch (_) {
      // Mengabaikan error koneksi agar UI tetap dapat menampilkan jadwal
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDayIndex = _getTodayIndex();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header Modern SIAWI dengan Curve & Gradient
          Container(
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
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // Ornamen Lingkaran Halus di Background
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
                        // Baris Atas: Back button, Title & Logo
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
                                    'Jadwal Pelajaran',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  Text(
                                    'Agenda Kegiatan Belajar Mengajar',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Image.asset(
                                'assets/logo/logo-splash.png',
                                width: 28,
                                height: 28,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Card Ringkasan Info Siswa & Kelas
                        Container(
                          padding: const EdgeInsets.all(16),
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
                              // Ikon Kotak
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.auto_stories_rounded,
                                  color: Color(0xFF4C3EC7),
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Info Nama, Kelas & Jurusan
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _namaSiswa ?? _namaKelas ?? 'Jadwal Kelas',
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
                                      _namaKelas != null
                                          ? '$_namaKelas • ${_namaJurusan ?? 'SMK Wisata Indonesia'}'
                                          : (_namaJurusan ?? 'SMK Wisata Indonesia'),
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
                              const SizedBox(width: 14),

                              // Badge Hari Ini
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFA7F3D0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF059669),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _tabs[currentDayIndex],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF059669),
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
          ),

          const SizedBox(height: 12),

          // Segmented Pill TabBar Hari
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              padding: EdgeInsets.zero,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: const Color(0xFF4C3EC7),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4C3EC7).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              tabs: List.generate(_tabs.length, (index) {
                final isCurrentDay = _isToday(index);
                return Tab(
                  height: 38,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_tabs[index]),
                          if (isCurrentDay) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Konten List Jadwal Berdasarkan Hari
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                JadwalList(
                  hari: 'senin',
                  signOut: widget.signOut,
                  scrollKey: 'jadwal_senin',
                ),
                JadwalList(
                  hari: 'selasa',
                  signOut: widget.signOut,
                  scrollKey: 'jadwal_selasa',
                ),
                JadwalList(
                  hari: 'rabu',
                  signOut: widget.signOut,
                  scrollKey: 'jadwal_rabu',
                ),
                JadwalList(
                  hari: 'kamis',
                  signOut: widget.signOut,
                  scrollKey: 'jadwal_kamis',
                ),
                JadwalList(
                  hari: 'jumat',
                  signOut: widget.signOut,
                  scrollKey: 'jadwal_jumat',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
