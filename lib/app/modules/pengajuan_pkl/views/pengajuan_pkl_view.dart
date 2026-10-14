import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/data/siswa_sekolah.dart';
import 'package:siawi_app/utils/colors.dart';

class PengajuanPklView extends StatefulWidget {
  final VoidCallback signOut;
  const PengajuanPklView(this.signOut, {super.key});

  @override
  State<PengajuanPklView> createState() => _PengajuanPklViewState();
}

class _PengajuanPklViewState extends State<PengajuanPklView> {
  String? idSiswa;
  String? namaSiswa;
  String? nisSiswa;
  String? kelasSiswa;
  String? jurusanSiswa;

  bool isLoading = true;
  List<dynamic> pengajuanList = [];
  List<dynamic> mitraList = [];
  List<dynamic> temanList = [];

  // 16 Mitra Perusahaan Resmi dari database sekolah (fallback offline / pre-deploy)
  static final List<Map<String, dynamic>> _daftarMitraDefault = [
    {
      'id_perusahaan': 1,
      'nama_perusahaan': 'Grand Mercure Jakarta Harmoni',
      'alamat_perusahaan': 'Jl. Hayam Wuruk No. 36-37, Jakarta Pusat',
      'penanggung_jawab': 'H.R & Learning Manager'
    },
    {
      'id_perusahaan': 2,
      'nama_perusahaan': 'Hotel Santika Premiere Hayam Wuruk',
      'alamat_perusahaan': 'Jl. Hayam Wuruk No. 125, Mangga Besar, Jakarta Barat',
      'penanggung_jawab': 'HRD Department'
    },
    {
      'id_perusahaan': 3,
      'nama_perusahaan': 'Mercure Jakarta Kota',
      'alamat_perusahaan': 'Jl. Hayam Wuruk No. 123, Mangga Besar, Jakarta Barat',
      'penanggung_jawab': 'Human Resources Department'
    },
    {
      'id_perusahaan': 4,
      'nama_perusahaan': 'Novotel Jakarta Gajah Mada',
      'alamat_perusahaan': 'Jl. Gajah Mada No. 188, Glodok, Taman Sari, Jakarta Barat',
      'penanggung_jawab': 'Talent & Culture Manager'
    },
    {
      'id_perusahaan': 5,
      'nama_perusahaan': 'Swiss-Belhotel Mangga Besar',
      'alamat_perusahaan': 'Jl. Kartini Raya No. 57, Pasar Baru, Sawah Besar, Jakarta Pusat',
      'penanggung_jawab': 'HR Manager'
    },
    {
      'id_perusahaan': 6,
      'nama_perusahaan': 'ASTON Kartika Grogol Hotel & Conference Center',
      'alamat_perusahaan': 'Jl. Kyai Tapa No. 101, Tomang, Grogol Petamburan, Jakarta Barat',
      'penanggung_jawab': 'Human Resources Manager'
    },
    {
      'id_perusahaan': 7,
      'nama_perusahaan': 'Luminor Hotel Kota',
      'alamat_perusahaan': 'Jl. Mangga Besar Raya No. 73, Tangki, Taman Sari, Jakarta Barat',
      'penanggung_jawab': 'Human Resources Department'
    },
    {
      'id_perusahaan': 8,
      'nama_perusahaan': 'Best Western Plus Kemayoran Hotel',
      'alamat_perusahaan': 'Jl. Benyamin Sueb Blok A5, Kemayoran, Jakarta Pusat',
      'penanggung_jawab': 'HR Department'
    },
    {
      'id_perusahaan': 9,
      'nama_perusahaan': 'Millennium Hotel Sirih Jakarta',
      'alamat_perusahaan': 'Jl. Fachrudin No. 3, Kampung Bali, Tanah Bang, Jakarta Pusat',
      'penanggung_jawab': 'Human Capital Department'
    },
    {
      'id_perusahaan': 10,
      'nama_perusahaan': 'Holiday Inn & Suites Jakarta Gajah Mada',
      'alamat_perusahaan': 'Jl. Gajah Mada No. 211, Glodok, Taman Sari, Jakarta Barat',
      'penanggung_jawab': 'People & Culture Manager'
    },
    {
      'id_perusahaan': 11,
      'nama_perusahaan': 'Aryaduta Menteng',
      'alamat_perusahaan': 'Jl. Prajurit KKO Usman dan Harun No. 44-48, Gambir, Jakarta Pusat',
      'penanggung_jawab': 'Human Resources Director'
    },
    {
      'id_perusahaan': 12,
      'nama_perusahaan': 'The Jayakarta SP Jakarta Hotel & Spa',
      'alamat_perusahaan': 'Jl. Hayam Wuruk No. 126, Mangga Besar, Taman Sari, Jakarta Barat',
      'penanggung_jawab': 'HRD Department'
    },
    {
      'id_perusahaan': 13,
      'nama_perusahaan': 'Royal Tulip Gunung Geulis Resort and Golf',
      'alamat_perusahaan': 'Jl. Pasir Angin, Gadog, Ciawi, Bogor',
      'penanggung_jawab': 'Talent Acquisition Manager'
    },
    {
      'id_perusahaan': 14,
      'nama_perusahaan': 'Pullman Jakarta Central Park',
      'alamat_perusahaan': 'Podomoro City, Jl. Letjen S. Parman No. Kav. 28, Jakarta Barat',
      'penanggung_jawab': 'Talent & Culture Director'
    },
    {
      'id_perusahaan': 15,
      'nama_perusahaan': 'Grand Dafam Ancol Jakarta',
      'alamat_perusahaan': 'Jl. Lodan Raya No. 2A, Ancol, Pademangan, Jakarta Utara',
      'penanggung_jawab': 'Human Resources Department'
    },
    {
      'id_perusahaan': 16,
      'nama_perusahaan': 'Harris Vertu Hotel Harmoni',
      'alamat_perusahaan': 'Jl. Hayam Wuruk No. 6, Kebon Kelapa, Gambir, Jakarta Pusat',
      'penanggung_jawab': 'Human Resources Department'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isPklLevel = prefs.getBool('is_pkl_level') ?? true;
    if (!isPklLevel) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Layanan Surat PKL hanya dapat diakses oleh siswa tingkat aktif PKL.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    String? currentId = prefs.getString('idSiswa');
    String? currentNama = prefs.getString('namaSiswa');
    String? currentNis = prefs.getString('nis');
    String? currentKelas = prefs.getString('namaKelas');
    String? currentJurusan = prefs.getString('namaJurusan');

    // 1. Coba baca dari cached header jika namaSiswa belum tersimpan
    if (currentNama == null || currentNama.isEmpty || currentNama == 'Siswa') {
      try {
        final cachedHeader =
            prefs.getString('cached_student_header_$currentId');
        if (cachedHeader != null && cachedHeader.isNotEmpty) {
          final cMap = jsonDecode(cachedHeader);
          if (cMap is Map) {
            currentNama = cMap['namaSiswa']?.toString() ?? currentNama;
            currentKelas = cMap['namaKelas']?.toString() ?? currentKelas;
            currentJurusan = cMap['namaJurusan']?.toString() ?? currentJurusan;
            currentNis = cMap['nis']?.toString() ?? currentNis;
          }
        }
      } catch (_) {}
    }

    // 2. Coba fallback dari masterDataSiswa jika masih kosong/Siswa
    if (currentNama == null || currentNama.isEmpty || currentNama == 'Siswa') {
      try {
        int myId = int.tryParse(currentId ?? '0') ?? 0;
        final match = masterDataSiswa.firstWhere(
          (s) =>
              s['id_siswa'] == myId ||
              (currentNis != null && s['nis'] == currentNis),
          orElse: () => {},
        );
        if (match.isNotEmpty) {
          currentNama = match['nama_siswa']?.toString() ?? currentNama;
          currentKelas = match['kelas']?.toString() ?? currentKelas;
          currentJurusan =
              match['program_keahlian']?.toString() ?? currentJurusan;
          currentNis = match['nis']?.toString() ?? currentNis;
        }
      } catch (_) {}
    }

    setState(() {
      idSiswa = currentId;
      namaSiswa = (currentNama != null && currentNama.isNotEmpty)
          ? currentNama
          : 'Siswa';
      nisSiswa = currentNis ?? '-';
      kelasSiswa = currentKelas ?? '-';
      jurusanSiswa = currentJurusan ?? '-';
    });

    // 3. Sinkronisasi live data langsung dari database
    Future<void> syncProfileFromDatabase() async {
      if (currentId == null || currentId.isEmpty) return;
      try {
        final homeRes = await ApiService.get('/home/$currentId', silent: true);
        if (homeRes != null && homeRes['siswa'] != null && mounted) {
          final sData = homeRes['siswa'];
          final kData = homeRes['kelas'];
          final jData = homeRes['jurusan'];
          final realNama =
              (sData['nama_siswa']?.toString() ?? namaSiswa)?.toUpperCase();
          final realNis = sData['nis']?.toString() ?? nisSiswa;
          final realKelas = kData != null
              ? kData['nama_kelas']?.toString() ?? kelasSiswa
              : kelasSiswa;
          final realJurusan = jData != null
              ? jData['nama_jurusan']?.toString() ?? jurusanSiswa
              : jurusanSiswa;

          setState(() {
            namaSiswa = realNama;
            nisSiswa = realNis;
            kelasSiswa = realKelas;
            jurusanSiswa = realJurusan;
          });

          if (realNama != null) prefs.setString('namaSiswa', realNama);
          if (realNis != null) prefs.setString('nis', realNis);
          if (realKelas != null) prefs.setString('namaKelas', realKelas);
          if (realJurusan != null) {
            prefs.setString('namaJurusan', realJurusan);
          }
        }
      } catch (_) {}
    }

    await Future.wait([
      _fetchRiwayatPengajuan(),
      _fetchMitraPerusahaan(),
      _fetchTemanSelevel(),
      syncProfileFromDatabase(),
    ]);

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchRiwayatPengajuan() async {
    if (idSiswa == null) return;
    try {
      final res = await ApiService.get('/pengajuan-pkl/$idSiswa', silent: true);
      if (res != null && res['data'] != null) {
        if (mounted) {
          setState(() {
            pengajuanList = res['data'];
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchMitraPerusahaan() async {
    try {
      final res = await ApiService.get('/perusahaan', silent: true);
      if (res != null &&
          res['data'] != null &&
          (res['data'] as List).isNotEmpty) {
        if (mounted) {
          setState(() {
            mitraList = res['data'];
          });
        }
        return;
      }
    } catch (_) {}

    // Gunakan fallback daftar mitra terdaftar jika server belum update route
    if (mounted) {
      setState(() {
        mitraList = _daftarMitraDefault;
      });
    }
  }

  Future<void> _fetchTemanSelevel() async {
    if (idSiswa == null) return;
    try {
      final res =
          await ApiService.get('/pengajuan-pkl/teman/$idSiswa', silent: true);
      if (res != null &&
          res['data'] != null &&
          (res['data'] as List).isNotEmpty) {
        if (mounted) {
          setState(() {
            temanList = res['data'];
          });
        }
        return;
      }
    } catch (_) {}

    // Fallback otomatis dari data master siswa berdasarkan level / angkatan yang sama
    if (mounted) {
      int myId = int.tryParse(idSiswa ?? '0') ?? 0;
      var me = masterDataSiswa.firstWhere(
        (s) =>
            s['id_siswa'] == myId ||
            (nisSiswa != null && s['nis'] == nisSiswa),
        orElse: () => {
          'id_level': (kelasSiswa != null && kelasSiswa!.startsWith('XII'))
              ? 1
              : (kelasSiswa != null && kelasSiswa!.startsWith('XI'))
                  ? 2
                  : 3
        },
      );
      int targetLevel = me['id_level'] ?? 1;

      final listLevel = masterDataSiswa
          .where((s) => s['id_level'] == targetLevel && s['id_siswa'] != myId)
          .toList();

      setState(() {
        temanList = listLevel.isNotEmpty
            ? listLevel
            : masterDataSiswa.where((s) => s['id_siswa'] != myId).toList();
      });
    }
  }

  Widget _buildHeroHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4C3EC7),
            Color(0xFF382BAA),
          ],
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
            // Ornamen lingkaran abstrak
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: 10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar Row
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
                              'Surat Pengajuan PKL',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              'BKK & Hubungan Industri SMK Wisata Indonesia',
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
                  const SizedBox(height: 14),

                  // Card Profil Pemohon (Siswa) di dalam Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.white,
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
                                (namaSiswa != null && namaSiswa!.isNotEmpty)
                                    ? namaSiswa!
                                    : 'Siswa',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${(kelasSiswa != null && kelasSiswa != '-') ? kelasSiswa : 'Kelas'} • NIS: ${(nisSiswa != null && nisSiswa != '-') ? nisSiswa : '-'}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
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
                  const SizedBox(height: 12),

                  // Chips Statistik Pengajuan
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.assignment_outlined,
                              size: 14,
                              color: Color(0xFF93C5FD),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${pengajuanList.length} Pengajuan Diajukan',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.business_rounded,
                              size: 14,
                              color: Color(0xFFFDE68A),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${mitraList.length} Mitra Perusahaan',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. HERO HEADER LENGKUNG SIAWI
          _buildHeroHeader(),

          // 2. KONTEN UTAMA
          Expanded(
            child: isLoading
                ? _buildLoadingSkeleton()
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.wait([
                        _fetchRiwayatPengajuan(),
                        _fetchMitraPerusahaan(),
                        _fetchTemanSelevel(),
                      ]);
                    },
                    color: const Color(0xFF4C3EC7),
                    backgroundColor: Colors.white,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      children: [
                        // Card Alur Pengajuan PKL
                        _buildHeaderCard(),
                        const SizedBox(height: 20),

                        // Judul Riwayat Pengajuan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Riwayat Pengajuan Anda',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFE0E7FF),
                                ),
                              ),
                              child: Text(
                                '${pengajuanList.length} Pengajuan',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4C3EC7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Daftar Pengajuan / Empty State
                        if (pengajuanList.isEmpty)
                          _buildEmptyState()
                        else
                          ...pengajuanList
                              .map((item) => _buildPengajuanCard(item)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openFormPengajuan,
        backgroundColor: const Color(0xFF4C3EC7),
        elevation: 4,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text(
          'Ajukan Surat PKL',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET CARD & HEADER
  // ==========================================

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E7FF)),
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: Color(0xFF4C3EC7),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alur Pengajuan Surat PKL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Layanan resmi BKK & Hubin Sekolah',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                _buildStepItem('1', 'Pilih Tempat', Icons.business_outlined),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: Color(0xFFCBD5E1),
                ),
                _buildStepItem('2', 'Verifikasi BKK', Icons.verified_user_outlined),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: Color(0xFFCBD5E1),
                ),
                _buildStepItem('3', 'Ambil Surat Fisik', Icons.inventory_2_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String num, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFF4C3EC7),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    num,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: const Color(0xFF4C3EC7)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 90,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  width: 80,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: 160,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E7FF), width: 2),
            ),
            child: const Icon(
              Icons.mark_email_unread_outlined,
              color: Color(0xFF4C3EC7),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Pengajuan Surat PKL',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Anda belum mengajukan permohonan surat PKL. Buat pengajuan baru untuk perusahaan tempat Praktik Kerja Lapangan Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openFormPengajuan,
            icon: const Icon(Icons.add_task_rounded, size: 18),
            label: const Text(
              'Ajukan Surat PKL Sekarang',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C3EC7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengajuanCard(dynamic item) {
    String status = (item['status'] ?? 'menunggu').toString().toLowerCase();
    Color statusColor;
    Color statusBg;
    String statusLabel;
    IconData statusIcon;

    if (status == 'disetujui' || status == 'acc') {
      statusColor = const Color(0xFF059669);
      statusBg = const Color(0xFFECFDF5);
      statusLabel = 'Disetujui BKK';
      statusIcon = Icons.check_circle_rounded;
    } else if (status == 'ditolak') {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEF2F2);
      statusLabel = 'Ditolak';
      statusIcon = Icons.cancel_rounded;
    } else {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFFFBEB);
      statusLabel = 'Menunggu Verifikasi';
      statusIcon = Icons.hourglass_top_rounded;
    }

    List<dynamic> anggotaList = item['siswa'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar: Status & Kode
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.tag_rounded, size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      item['kode_pengajuan'] ?? 'PKL-BARU',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 13, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Perusahaan
                Text(
                  item['nama_perusahaan'] ?? 'Nama Perusahaan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),

                // Alamat Perusahaan
                if (item['alamat_perusahaan'] != null &&
                    item['alamat_perusahaan'].toString().isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 15, color: Colors.grey.shade500),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item['alamat_perusahaan'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),

                // Detail Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ditujukan Kepada:',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${item['ditujukan_kepada'] ?? '-'} (${item['jabatan_tujuan'] ?? 'HRD'})",
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Periode PKL:',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            item['periode_teks'] ??
                                "${item['tanggal_mulai'] ?? '-'} s/d ${item['tanggal_selesai'] ?? '-'}",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mainColor,
                            ),
                          ),
                        ],
                      ),
                      if (item['nomor_surat'] != null &&
                          item['nomor_surat'].toString().isNotEmpty) ...[
                        const Divider(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Nomor Surat Resmi:',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              item['nomor_surat'],
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.mainColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Daftar Anggota Kelompok
                if (anggotaList.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.group_outlined,
                          size: 15, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        'Anggota Kelompok (${anggotaList.length} Siswa):',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: anggotaList.map<Widget>((ang) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${ang['nama_siswa']} (${ang['nis'] ?? '-'})",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Catatan BKK jika ada
                if (item['catatan_bkk'] != null &&
                    item['catatan_bkk'].toString().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.feedback_outlined,
                            size: 16, color: Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Catatan BKK: ${item['catatan_bkk']}",
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // PENJELASAN PENGAMBILAN SURAT DI BKK / HUBIN JIKA SUDAH DI-ACC
                if (status == 'disetujui' || status == 'acc') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 22,
                          color: Color(0xFF059669),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Surat Siap Diambil di BKK / Hubin!',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Pengajuan telah disetujui. Surat permohonan PKL resmi fisik (bertanda tangan & stempel sekolah) dapat diambil langsung di bagian BKK atau Hubin.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF047857),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FORM PENGAJUAN BOTTOM SHEET
  // ==========================================

  void _openFormPengajuan() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FormPengajuanSheet(
        idSiswa: idSiswa ?? '',
        namaSiswa: namaSiswa ?? '',
        nisSiswa: nisSiswa ?? '',
        kelasSiswa: kelasSiswa ?? '',
        jurusanSiswa: jurusanSiswa ?? '',
        mitraList: mitraList,
        temanList: temanList,
        onSuccess: () {
          Navigator.pop(ctx);
          _fetchRiwayatPengajuan();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pengajuan Surat PKL berhasil dikirim ke BKK/Hubin!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.mainColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// FORM PENGAJUAN STATEFUL WIDGET
// ==========================================

class _FormPengajuanSheet extends StatefulWidget {
  final String idSiswa;
  final String namaSiswa;
  final String nisSiswa;
  final String kelasSiswa;
  final String jurusanSiswa;
  final List<dynamic> mitraList;
  final List<dynamic> temanList;
  final VoidCallback onSuccess;

  const _FormPengajuanSheet({
    required this.idSiswa,
    required this.namaSiswa,
    required this.nisSiswa,
    required this.kelasSiswa,
    required this.jurusanSiswa,
    required this.mitraList,
    required this.temanList,
    required this.onSuccess,
  });

  @override
  State<_FormPengajuanSheet> createState() => _FormPengajuanSheetState();
}

class _FormPengajuanSheetState extends State<_FormPengajuanSheet> {
  final _formKey = GlobalKey<FormState>();

  int? selectedPerusahaanId;
  final TextEditingController _namaPerusahaanController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _ditujukanController =
      TextEditingController(text: 'Pimpinan / HRD');
  final TextEditingController _jabatanController =
      TextEditingController(text: 'H.R & Learning Manager');
  final TextEditingController _kontakController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  bool isSubmitting = false;

  // Anggota kelompok tambahan
  final List<Map<String, dynamic>> _anggotaTambahan = [];

  @override
  void initState() {
    super.initState();
    // Default 3 bulan ke depan
    final now = DateTime.now();
    _tanggalMulai = DateTime(now.year, now.month + 1, 1);
    _tanggalSelesai = DateTime(now.year, now.month + 4, 1);
  }

  void _onSelectMitra(dynamic mitra) {
    if (mitra == null) {
      setState(() {
        selectedPerusahaanId = null;
        _namaPerusahaanController.clear();
        _alamatController.clear();
      });
    } else {
      setState(() {
        selectedPerusahaanId = mitra['id_perusahaan'];
        _namaPerusahaanController.text = mitra['nama_perusahaan'] ?? '';
        _alamatController.text = mitra['alamat_perusahaan'] ?? '';
        if (mitra['penanggung_jawab'] != null &&
            mitra['penanggung_jawab'].toString().isNotEmpty) {
          _ditujukanController.text = mitra['penanggung_jawab'];
        }
      });
    }
  }

  Future<void> _pickDate({required bool isMulai}) async {
    final initialDate = isMulai
        ? (_tanggalMulai ?? DateTime.now())
        : (_tanggalSelesai ?? DateTime.now().add(const Duration(days: 90)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.mainColor,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isMulai) {
          _tanggalMulai = picked;
          if (_tanggalSelesai != null && _tanggalSelesai!.isBefore(picked)) {
            _tanggalSelesai = picked.add(const Duration(days: 90));
          }
        } else {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Pilih Tanggal';
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  // Dialog / Modal Pencarian Teman Sekelompok dari Database
  void _tambahAnggotaModal() {
    // Prioritaskan widget.temanList dari API, atau fallback ke masterDataSiswa database
    int myId = int.tryParse(widget.idSiswa) ?? 0;
    final listTersedia = widget.temanList.isNotEmpty
        ? widget.temanList
        : masterDataSiswa.where((s) => s['id_siswa'] != myId).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => _PilihTemanModal(
        temanList: listTersedia,
        anggotaTerpilih: _anggotaTambahan,
        onTemanDipilih: (teman) {
          setState(() {
            _anggotaTambahan.add({
              'id_siswa': teman['id_siswa'],
              'nama_siswa': teman['nama_siswa'],
              'nis': teman['nis'],
              'kelas': teman['kelas'],
              'program_keahlian': teman['program_keahlian'],
            });
          });
          Navigator.pop(modalCtx);
        },
        onKetikManual: () {
          Navigator.pop(modalCtx);
          _tambahAnggotaManualDialog();
        },
      ),
    );
  }

  // Dialog Fallback Input Manual jika teman tidak ada di database
  void _tambahAnggotaManualDialog() {
    final namaCtrl = TextEditingController();
    final nisCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Input Teman Kelompok',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaCtrl,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap Teman',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nisCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'NIS Teman',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (namaCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _anggotaTambahan.add({
                    'id_siswa': null,
                    'nama_siswa': namaCtrl.text.trim(),
                    'nis': nisCtrl.text.trim(),
                    'kelas': widget.kelasSiswa,
                    'program_keahlian': widget.jurusanSiswa,
                  });
                });
                Navigator.pop(dialogCtx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tanggalMulai == null || _tanggalSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan tentukan periode tanggal PKL')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    String strMulai =
        "${_tanggalMulai!.year}-${_tanggalMulai!.month.toString().padLeft(2, '0')}-${_tanggalMulai!.day.toString().padLeft(2, '0')}";
    String strSelesai =
        "${_tanggalSelesai!.year}-${_tanggalSelesai!.month.toString().padLeft(2, '0')}-${_tanggalSelesai!.day.toString().padLeft(2, '0')}";

    int diffDays = _tanggalSelesai!.difference(_tanggalMulai!).inDays;
    int bulan = (diffDays / 30).round().clamp(1, 12);
    String periodeTeks = "$bulan Bulan (${_formatDate(_tanggalMulai)} s/d ${_formatDate(_tanggalSelesai)})";

    Map<String, dynamic> body = {
      'id_siswa': widget.idSiswa,
      'id_perusahaan': selectedPerusahaanId,
      'nama_perusahaan': _namaPerusahaanController.text.trim(),
      'alamat_perusahaan': _alamatController.text.trim(),
      'ditujukan_kepada': _ditujukanController.text.trim(),
      'jabatan_tujuan': _jabatanController.text.trim(),
      'tanggal_mulai': strMulai,
      'tanggal_selesai': strSelesai,
      'periode_teks': periodeTeks,
      'kontak_pemohon': _kontakController.text.trim(),
      'catatan_siswa': _catatanController.text.trim(),
      'anggota_siswa': _anggotaTambahan,
    };

    try {
      final res = await ApiService.postJson('/pengajuan-pkl', body);
      if (res != null && res['success'] == true) {
        widget.onSuccess();
      } else {
        String msg = res != null ? (res['message'] ?? 'Terjadi kesalahan') : 'Gagal mengirim pengajuan';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kesalahan jaringan: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Pill indicator
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Sheet Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Form Pengajuan Surat PKL',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const Divider(),

            // Scrollable fields
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 8),

                  // 1. INFO PEMOHON (READONLY)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.mainColor,
                          child: const Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.namaSiswa,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                "${widget.kelasSiswa} • NIS: ${widget.nisSiswa}",
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // PILIH MITRA / KETIK SENDIRI
                  const Text(
                    'Pilih Mitra Sekolah (Opsional)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<dynamic>(
                    isExpanded: true,
                    initialValue: selectedPerusahaanId != null
                        ? widget.mitraList.firstWhere(
                            (m) => m['id_perusahaan'] == selectedPerusahaanId,
                            orElse: () => null)
                        : null,
                    decoration: InputDecoration(
                      hintText: '-- Pilih Mitra atau Ketik Mandiri --',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text(
                          'Ketik Nama Perusahaan Sendiri',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      ...widget.mitraList.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(
                            m['nama_perusahaan'] ?? '-',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }),
                    ],
                    onChanged: _onSelectMitra,
                  ),
                  const SizedBox(height: 14),

                  // Nama Perusahaan
                  const Text(
                    'Nama Perusahaan / Tempat PKL *',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _namaPerusahaanController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Grand Mercure Jakarta Harmoni',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Nama tempat PKL wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),

                  // Alamat Perusahaan
                  const Text(
                    'Alamat Lengkap Perusahaan *',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _alamatController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Jl. Hayam Wuruk No. 36-37, Jakarta Pusat',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Alamat perusahaan wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),

                  // Ditujukan Kepada & Jabatan (2 Kolom)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ditujukan Kepada',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _ditujukanController,
                              decoration: InputDecoration(
                                hintText: 'Pimpinan / HRD',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide:
                                      const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jabatan Tujuan',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _jabatanController,
                              decoration: InputDecoration(
                                hintText: 'Human Resources Manager',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide:
                                      const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Periode PKL (Date Pickers)
                  const Text(
                    'Periode Pelaksanaan PKL *',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(isMulai: true),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_rounded,
                                    size: 16, color: AppColors.mainColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formatDate(_tanggalMulai),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('s/d', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(isMulai: false),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.event_available_rounded,
                                    size: 16, color: AppColors.mainColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formatDate(_tanggalSelesai),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Nomor WhatsApp Pemohon
                  const Text(
                    'Nomor WhatsApp Perwakilan (Wajib) *',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _kontakController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 081234567890',
                      prefixIcon: Icon(Icons.phone_android_rounded,
                          size: 18, color: AppColors.mainColor),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Nomor WhatsApp wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),

                  // Anggota Kelompok Tambahan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Teman Sekelompok (Opsional)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _tambahAnggotaModal,
                        icon: const Icon(Icons.person_search_rounded, size: 16),
                        label: const Text('Pilih Teman', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.mainColor,
                        ),
                      ),
                    ],
                  ),
                  if (_anggotaTambahan.isNotEmpty) ...[
                    ..._anggotaTambahan.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var ang = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text('${idx + 2}. ',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${ang['nama_siswa']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  Text(
                                    "NIS: ${ang['nis'] ?? '-'} • ${ang['kelas'] ?? '-'}",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _anggotaTambahan.removeAt(idx);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 10),

                  // Catatan Siswa
                  const Text(
                    'Catatan Tambahan untuk BKK/Hubin (Opsional)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _catatanController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Mohon penempatan bagian Front Office / IT Support',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Submit Button
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Kirim Pengajuan Surat PKL',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// MODAL BOTTOM SHEET: CARI TEMAN DARI DATABASE
// ==========================================

class _PilihTemanModal extends StatefulWidget {
  final List<dynamic> temanList;
  final List<Map<String, dynamic>> anggotaTerpilih;
  final ValueChanged<Map<String, dynamic>> onTemanDipilih;
  final VoidCallback onKetikManual;

  const _PilihTemanModal({
    required this.temanList,
    required this.anggotaTerpilih,
    required this.onTemanDipilih,
    required this.onKetikManual,
  });

  @override
  State<_PilihTemanModal> createState() => _PilihTemanModalState();
}

class _PilihTemanModalState extends State<_PilihTemanModal> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _filteredList = widget.temanList;
  }

  void _onSearch(String query) {
    String q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredList = widget.temanList;
      } else {
        _filteredList = widget.temanList.where((t) {
          String nama = (t['nama_siswa'] ?? '').toString().toLowerCase();
          String nis = (t['nis'] ?? '').toString().toLowerCase();
          String kls = (t['kelas'] ?? '').toString().toLowerCase();
          return nama.contains(q) || nis.contains(q) || kls.contains(q);
        }).toList();
      }
    });
  }

  bool _isAlreadyAdded(dynamic t) {
    return widget.anggotaTerpilih.any(
      (a) =>
          (a['id_siswa'] != null && a['id_siswa'] == t['id_siswa']) ||
          (a['nis'] != null &&
              a['nis'].toString().isNotEmpty &&
              a['nis'] == t['nis']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Teman Sekelompok',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Teman satu angkatan / tingkat (${widget.temanList.length} siswa)',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Search Box
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Cari nama, kelas, atau NIS teman...',
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.mainColor),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // List of peers
          Expanded(
            child: _filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        const Text(
                          'Teman tidak ditemukan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredList.length,
                    itemBuilder: (ctx, idx) {
                      var t = _filteredList[idx];
                      bool added = _isAlreadyAdded(t);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: added
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: added
                                ? const Color(0xFFE2E8F0)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          leading: CircleAvatar(
                            backgroundColor: added
                                ? Colors.grey.shade400
                                : AppColors.thirdColor,
                            child: Text(
                              (t['nama_siswa'] != null &&
                                      t['nama_siswa'].toString().isNotEmpty)
                                  ? t['nama_siswa'][0].toUpperCase()
                                  : 'S',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: added
                                    ? Colors.white
                                    : AppColors.mainColor,
                              ),
                            ),
                          ),
                          title: Text(
                            t['nama_siswa'] ?? '-',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: added
                                  ? Colors.grey.shade600
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: Text(
                            "NIS: ${t['nis'] ?? '-'} • ${t['kelas'] ?? '-'}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          trailing: added
                              ? const Chip(
                                  label: Text(
                                    'Dipilih',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                )
                              : ElevatedButton(
                                  onPressed: () => widget.onTemanDipilih(
                                    Map<String, dynamic>.from(t),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.mainColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    visualDensity: VisualDensity.compact,
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    '+ Pilih',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom manual input option
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tidak menemukan nama teman?',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              TextButton(
                onPressed: widget.onKetikManual,
                child: Text(
                  'Ketik Manual',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
