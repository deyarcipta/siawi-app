import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/models/menu_item.dart';
import 'package:siawi_app/app/models/menu_items.dart';
import 'package:siawi_app/app/modules/password/views/password_view.dart';

class StudentDashboardHeader extends StatefulWidget {
  final VoidCallback signOut;

  const StudentDashboardHeader(this.signOut, {super.key});

  @override
  State<StudentDashboardHeader> createState() => _StudentDashboardHeaderState();
}

class _StudentDashboardHeaderState extends State<StudentDashboardHeader> {
  bool loading = false;
  String? idSiswa;

  // Student Details
  String namaSiswa = "Siswa";
  String namaKelas = "XII – TKJ 1";
  String namaJurusan = "Teknik Jaringan Komputer & Telekomunikasi";
  String nis = "-";
  String nisn = "-";
  String? fileFoto;
  String namaSekolah = "SMK Wisata Indonesia";
  String semester = "Genap";
  String tahunAjaran = "2024/2025";

  // Attendance
  int presentaseKehadiran = 0;

  // Rapor
  bool hasRapor = false;
  String nilaiRapor = "-";
  String predikatRapor = "Belum Ada";

  // Discipline Points
  int poinKedisiplinan = 100;
  String statusPoin = "Tertib";

  // PKL Information
  bool hasPkl = false;
  bool isPklLevel = true;
  String statusPklText = "Siap Ditempatkan";
  String pklNamaPerusahaan = "-";
  String pklStatus = "Belum Ditempatkan";
  String pklAlamat = "-";
  String? pklPeriode;
  String? pklGuru;

  // Biometric / Daily Attendance Scenario
  String attendanceStatus = 'hadir'; // hadir, terlambat, sakit, izin, alfa, belum
  String attendanceType = 'mesin';   // mesin, piket
  String attendanceJam = '06:45';
  int attendanceStreak = 14;
  String? overrideScenario; // null = otomatis sistem

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? currentId = preferences.getString('idSiswa');
    idSiswa = currentId;

    if (currentId != null && currentId.isNotEmpty) {
      String? cacheRaw =
          preferences.getString('cached_student_header_$currentId');
      if (cacheRaw != null && cacheRaw.isNotEmpty) {
        try {
          var cMap = jsonDecode(cacheRaw);
          setState(() {
            namaSiswa = cMap['namaSiswa'] ?? namaSiswa;
            namaKelas = cMap['namaKelas'] ?? namaKelas;
            namaJurusan = cMap['namaJurusan'] ?? namaJurusan;
            nis = cMap['nis'] ?? nis;
            nisn = cMap['nisn'] ?? nisn;
            fileFoto = cMap['fileFoto'];
            namaSekolah = cMap['namaSekolah'] ?? namaSekolah;
            semester = cMap['semester'] ?? semester;
            tahunAjaran = cMap['tahunAjaran'] ?? tahunAjaran;
            presentaseKehadiran =
                cMap['presentaseKehadiran'] ?? presentaseKehadiran;
            hasRapor = cMap['hasRapor'] ?? hasRapor;
            nilaiRapor = cMap['nilaiRapor'] ?? nilaiRapor;
            predikatRapor = cMap['predikatRapor'] ?? predikatRapor;
            poinKedisiplinan = cMap['poinKedisiplinan'] ?? poinKedisiplinan;
            statusPoin = cMap['statusPoin'] ?? statusPoin;
            hasPkl = cMap['hasPkl'] ?? hasPkl;
            isPklLevel = cMap['isPklLevel'] ?? isPklLevel;
            statusPklText = cMap['statusPklText'] ?? statusPklText;
            pklNamaPerusahaan = cMap['pklNamaPerusahaan'] ?? pklNamaPerusahaan;
            pklStatus = cMap['pklStatus'] ?? pklStatus;
            pklAlamat = cMap['pklAlamat'] ?? pklAlamat;
            pklPeriode = cMap['pklPeriode'];
            pklGuru = cMap['pklGuru'];
          });
        } catch (_) {}
      }

      _fetchStudentData(currentId);
    }
  }

  Future<void> _fetchStudentData(String studentId) async {
    try {
      // 1. Fetch Point Siswa
      int currentPoint = 100;
      String currentStatusPoin = "Tertib";
      try {
        final dataPoint = await ApiService.get('/point/$studentId');
        if (dataPoint != null && mounted) {
          int skor =
              int.tryParse(dataPoint['totalSkor']?.toString() ?? '0') ?? 0;
          currentPoint = (100 - skor).clamp(0, 100);
          if (currentPoint >= 100) {
            currentStatusPoin = "Tertib";
          } else if (currentPoint >= 85) {
            currentStatusPoin = "Baik";
          } else if (currentPoint >= 70) {
            currentStatusPoin = "Cukup";
          } else {
            currentStatusPoin = "Perhatian";
          }
        }
      } catch (_) {}

      // 3. Fetch Data Siswa Home
      final res = await ApiService.get('/home/$studentId');
      if (res != null && res['data'] != null && mounted) {
        var sData = res['data'];
        var kData = sData['kelas'];
        var jData = sData['jurusan'];
        var rData = res['rapotTerakhir'];
        var pData = res['siswaPkl'];

        // Kehadiran
        int pres =
            int.tryParse(res['presentaseKehadiran']?.toString() ?? '0') ?? 0;

        // Rapor
        bool rExists = false;
        String rNilai = "-";
        String rPredikat = "Belum Ada";

        if (rData != null &&
            rData['rata_rata'] != null &&
            rData['rata_rata'].toString().isNotEmpty &&
            rData['rata_rata'].toString() != 'null') {
          double? val = double.tryParse(rData['rata_rata'].toString());
          if (val != null && val > 0) {
            rExists = true;
            rNilai = val.toStringAsFixed(1);
            if (val >= 88) {
              rPredikat = "Amat Baik";
            } else if (val >= 78) {
              rPredikat = "Baik";
            } else if (val >= 70) {
              rPredikat = "Cukup";
            } else {
              rPredikat = "Perlu Bimbingan";
            }
          }

          if (rData['semester'] != null) {
            var semVal = rData['semester'].toString();
            if (semVal.toLowerCase().contains('genap')) {
              semester = 'Genap';
            } else if (semVal.toLowerCase().contains('ganjil')) {
              semester = 'Ganjil';
            }
          }

          if (rData['tahun_ajaran'] != null &&
              rData['tahun_ajaran'].toString().isNotEmpty) {
            tahunAjaran = rData['tahun_ajaran'].toString();
          }
        }

        // PKL Data
        bool pExists = false;
        String pNama = "-";
        String pStatus = "Siap Ditempatkan";
        String pAlamat = "-";
        String? pPeriode;
        String? pGuru;

        if (pData != null && pData['perusahaan'] != null) {
          var per = pData['perusahaan'];
          pExists = true;
          pNama = per['nama_perusahaan'] ?? '-';
          pStatus = pData['status_label'] ?? pData['status'] ?? 'Ditempatkan';
          pAlamat = per['alamat_perusahaan'] ?? '-';
          if (pData['tanggal_mulai'] != null &&
              pData['tanggal_selesai'] != null) {
            pPeriode =
                "${pData['tanggal_mulai']} s/d ${pData['tanggal_selesai']}";
          }
          if (per['guru'] != null && per['guru']['nama_guru'] != null) {
            pGuru = per['guru']['nama_guru'].toString();
          } else if (pData['guru'] != null &&
              pData['guru']['nama_guru'] != null) {
            pGuru = pData['guru']['nama_guru'].toString();
          }
        }

        String pklText = pExists ? "$pStatus ($pNama)" : "Siap Ditempatkan";

        bool pklLevelAllowed = true;
        if (res['is_pkl_level'] != null) {
          pklLevelAllowed = res['is_pkl_level'] == true ||
              res['is_pkl_level'] == 1 ||
              res['is_pkl_level'].toString() == 'true';
        }

        // Kehadiran Hari Ini
        var todayAbsen = res['kehadiranToday'];
        String rawStatus = 'hadir';
        String rawJam = '06:45';
        String rawType = 'mesin';
        if (todayAbsen != null) {
          rawStatus = (todayAbsen['kehadiran'] ?? 'hadir').toString().toLowerCase();
          String? jm = todayAbsen['jam_masuk']?.toString();
          if (jm != null && jm.isNotEmpty && jm != 'null' && jm != '-') {
            rawJam = jm.length >= 5 ? jm.substring(0, 5) : jm;
          }
          String? tm = todayAbsen['tipe_masuk']?.toString().toLowerCase();
          String? ket = todayAbsen['keterangan']?.toString().toLowerCase();
          if (tm == 'piket' || tm == 'manual' || (ket != null && ket.contains('piket'))) {
            rawType = 'piket';
          } else {
            rawType = 'mesin';
          }
        }

        // Ambil Setting Sekolah, Tahun Ajaran & Semester dari Database
        String schoolName = res['nama_sekolah'] ??
            (res['setting'] != null ? res['setting']['nama_sekolah'] : null) ??
            namaSekolah;
        String schoolTahun = res['tahun_ajaran'] ??
            (res['setting'] != null ? res['setting']['tahun_ajaran'] : null) ??
            tahunAjaran;
        String schoolSem = res['semester_aktif'] ??
            (res['setting'] != null ? res['setting']['semester_aktif'] : null) ??
            semester;

        setState(() {
          namaSiswa =
              (sData['nama_siswa']?.toString() ?? 'Siswa').toUpperCase();
          namaKelas = kData != null
              ? kData['nama_kelas']?.toString() ?? 'XII - TKJ 1'
              : 'XII - TKJ 1';
          namaJurusan = jData != null
              ? jData['nama_jurusan']?.toString() ??
                  'Teknik Jaringan Komputer & Telekomunikasi'
              : 'Teknik Jaringan Komputer & Telekomunikasi';
          nis = sData['nis']?.toString() ?? '-';
          nisn = sData['nisn']?.toString() ?? '-';
          fileFoto = sData['foto']?.toString();
          presentaseKehadiran = pres;
          hasRapor = rExists;
          nilaiRapor = rNilai;
          predikatRapor = rPredikat;
          poinKedisiplinan = currentPoint;
          statusPoin = currentStatusPoin;

          namaSekolah = schoolName;
          tahunAjaran = schoolTahun;
          semester = schoolSem;

          hasPkl = pExists;
          isPklLevel = pklLevelAllowed;
          statusPklText = pklText;
          pklNamaPerusahaan = pNama;
          pklStatus = pStatus;
          pklAlamat = pAlamat;
          pklPeriode = pPeriode;
          pklGuru = pGuru;

          attendanceStatus = rawStatus;
          attendanceJam = rawJam;
          attendanceType = rawType;
        });

        // Save Cache
        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'cached_student_header_$studentId',
            jsonEncode({
              'namaSiswa': namaSiswa,
              'namaKelas': namaKelas,
              'namaJurusan': namaJurusan,
              'nis': nis,
              'nisn': nisn,
              'fileFoto': fileFoto,
              'namaSekolah': namaSekolah,
              'semester': semester,
              'tahunAjaran': tahunAjaran,
              'presentaseKehadiran': presentaseKehadiran,
              'hasRapor': hasRapor,
              'nilaiRapor': nilaiRapor,
              'predikatRapor': predikatRapor,
              'poinKedisiplinan': poinKedisiplinan,
              'statusPoin': statusPoin,
              'hasPkl': hasPkl,
              'isPklLevel': isPklLevel,
              'statusPklText': statusPklText,
              'pklNamaPerusahaan': pklNamaPerusahaan,
              'pklStatus': pklStatus,
              'pklAlamat': pklAlamat,
              'pklPeriode': pklPeriode,
              'pklGuru': pGuru,
            }),
          );
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error fetching student header data: $e');
    }
  }

  String _getStudentPhotoUrl(String? filename) {
    if (filename == null ||
        filename.isEmpty ||
        filename == 'null' ||
        filename == 'default.png' ||
        filename == 'avatar.jpg') {
      return '';
    }
    return 'https://siawi.smkwisataindonesia.sch.id/storage/foto-siswa/$filename';
  }

  Widget _buildStudentPhoto() {
    String photoUrl = _getStudentPhotoUrl(fileFoto);
    if (photoUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photoUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFFEEF2FF),
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF4F46E5),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/images/avatar.png',
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      'assets/images/avatar.png',
      fit: BoxFit.cover,
    );
  }

  PopupMenuItem<MenuKu> _buildMenuItem(MenuKu item) => PopupMenuItem<MenuKu>(
        value: item,
        child: Row(
          children: [
            Icon(
              item.icon,
              color: const Color(0xFF1E2432),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              item.text,
              style: const TextStyle(
                color: Color(0xFF1E2432),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );

  void _onMenuSelected(BuildContext context, MenuKu item) {
    switch (item) {
      case MenuItems.itemLogout:
        widget.signOut();
        break;
      case MenuItems.itemPassword:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordView(widget.signOut),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. TOP BAR (LANGSUNG DI ATAS BACKGROUND UNGU UTAMA) - GAMBAR 1
        _buildTopBar(context),
        const SizedBox(height: 16),

        // 2. KARTU PUTIH GREETING - GAMBAR 2
        _buildGreetingCard(context),
        const SizedBox(height: 14),

        // 3. KARTU UNGU HERO (KOMPETENSI KEAHLIAN / PRESTASI / PKL) - GAMBAR 3
        _buildHeroPurpleCard(context),
        const SizedBox(height: 14),

        // 4. KARTU PRESENSI BIOMETRIK (PERSIS SEPERTI GAMBAR DENGAN SKENARIO)
        _buildBiometricAttendanceCard(context),
      ],
    );
  }

  // ========================================================
  // 1. TOP BAR (SESUAI GAMBAR 1)
  // ========================================================
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Kiri: School Icon Box & Title
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/logo/logo-splash.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.school_rounded,
                      color: Color(0xFF4F46E5),
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Beranda',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    namaSekolah,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Kanan: Lonceng Notifikasi & Tombol Profil
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tidak ada pemberitahuan baru'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              PopupMenuButton<MenuKu>(
                tooltip: 'Menu Akun',
                padding: EdgeInsets.zero,
                icon: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                onSelected: (item) => _onMenuSelected(context, item),
                itemBuilder: (context) => [
                  _buildMenuItem(MenuItems.itemPassword),
                  _buildMenuItem(MenuItems.itemLogout),
                ],
                offset: const Offset(0.0, 48.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 2. KARTU PUTIH GREETING (SESUAI GAMBAR 2)
  // ========================================================
  Widget _buildGreetingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SELAMAT DATANG,',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFF4338CA),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  namaSiswa.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Kelas $namaKelas',
                        style: const TextStyle(
                          color: Color(0xFF4F46E5),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '•',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'NISN: $nisn',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Avatar dengan Titik Status Hijau Aktif
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.8,
                  ),
                ),
                child: ClipOval(
                  child: _buildStudentPhoto(),
                ),
              ),
              Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981), // Emerald Active
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 3. KARTU UNGU HERO (SESUAI GAMBAR 3)
  // ========================================================
  Widget _buildHeroPurpleCard(BuildContext context) {
    String raporDisplay =
        hasRapor ? '$nilaiRapor ($predikatRapor)' : 'Belum Ada';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5), // Indigo matching mockup
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOP ROW: KOMPETENSI KEAHLIAN + ATTENDANCE CIRCLE
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KOMPETENSI KEAHLIAN',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      namaJurusan,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Semester $semester • T.A. $tahunAjaran',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Attendance Circular Box
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: CircularPercentIndicator(
                    radius: 28,
                    lineWidth: 5.5,
                    animation: true,
                    percent: (presentaseKehadiran / 100).clamp(0.0, 1.0),
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    progressColor: Colors.white,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$presentaseKehadiran%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Presensi',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
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

          // 2. MIDDLE STATS ROW: Rata-Rata Rapor & Poin Kedisiplinan
          Row(
            children: [
              // Pill 1: Rapor
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.star_outline_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rata-Rata Rapor',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              raporDisplay,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
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
              ),
              const SizedBox(width: 10),
              // Pill 2: Poin Kedisiplinan
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Poin Kedisiplinan',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '$poinKedisiplinan / 100 ($statusPoin)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
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
              ),
            ],
          ),

          // 3. BOTTOM STATUS PKL BANNER (Hanya jika isPklLevel == true)
          if (isPklLevel) ...[
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _showPklDetailBottomSheet(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF34D399), // Mint Green
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Status PKL: $statusPklText ${pklNamaPerusahaan != '-' && pklNamaPerusahaan.isNotEmpty ? '($pklNamaPerusahaan)' : ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ========================================================
  // 4. KARTU PRESENSI BIOMETRIK (PERSIS SEPERTI GAMBAR)
  //    DENGAN SKENARIO: HADIR, PIKET, TERLAMBAT, SAKIT, IZIN, ALFA
  // ========================================================
  String _getFormattedTodayDate() {
    final now = DateTime.now();
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    const months = [
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
      'Desember'
    ];
    String dayName = days[now.weekday - 1];
    String monthName = months[now.month - 1];
    return "$dayName, ${now.day} $monthName ${now.year}";
  }

  Widget _buildBiometricAttendanceCard(BuildContext context) {
    // Tentukan skenario aktif (default: otomatis, atau override simulasi)
    String activeScenario = overrideScenario ??
        (attendanceStatus == 'hadir' && attendanceType == 'piket'
            ? 'piket'
            : attendanceStatus);

    // Variabel tampilan skenario
    String headerTitle = 'Presensi Biometrik';
    String headerSubtitle = 'RFID & Face ID Terverifikasi';
    Color dotColor = const Color(0xFF10B981);
    IconData iconData = Icons.fingerprint_rounded;
    List<Color> iconGradient = [
      const Color(0xFF10B981),
      const Color(0xFF059669)
    ];
    Color iconShadow = const Color(0xFF10B981);

    String badgeText = 'Hadir Tepat Waktu';
    IconData badgeIcon = Icons.verified_outlined;
    Color badgeBg = const Color(0xFFECFDF5);
    Color badgeBorder = const Color(0xFFA7F3D0);
    Color badgeTextColor = const Color(0xFF047857);

    String tagText = 'Hari Efektif';
    String jamLabel = 'JAM MASUK TERCATAT';
    String jamValue = attendanceJam.isNotEmpty ? attendanceJam : '06:45';
    String jamUnit = 'WIB';
    Color jamColor = const Color(0xFF0F172A);

    String streakIcon = '🔥';
    String streakNum = '$attendanceStreak';
    String streakLabel = 'HARI BERUNTUN';
    String streakSub = 'Streak Presensi';
    List<Color> streakGradient = [
      const Color(0xFFFF8A00),
      const Color(0xFFFF3D00)
    ];
    Color streakShadow = const Color(0xFFFF5722);

    IconData bannerIcon = Icons.auto_awesome;
    Color bannerIconColor = const Color(0xFF6366F1);
    String bannerBold = 'Semangat Belajar! ';
    Color bannerBoldColor = const Color(0xFF4338CA);
    String bannerNormal =
        'Raih kompetensi terbaik dan buktikan prestasimu hari ini.';

    switch (activeScenario) {
      case 'piket':
        headerTitle = 'Presensi Piket';
        headerSubtitle = 'Diinput Manual oleh Guru Piket';
        dotColor = const Color(0xFF6366F1);
        iconData = Icons.assignment_ind_rounded;
        iconGradient = [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
        iconShadow = const Color(0xFF6366F1);

        badgeText = 'Hadir (Input Piket)';
        badgeIcon = Icons.how_to_reg_rounded;
        badgeBg = const Color(0xFFEEF2FF);
        badgeBorder = const Color(0xFFC7D2FE);
        badgeTextColor = const Color(0xFF4338CA);

        tagText = 'Hari Efektif';
        jamLabel = 'JAM MASUK DICATAT PIKET';
        jamValue = attendanceJam.isNotEmpty ? attendanceJam : '06:52';
        jamUnit = 'WIB';
        jamColor = const Color(0xFF1E1B4B);

        streakIcon = '🔥';
        streakNum = '$attendanceStreak';
        streakLabel = 'HARI BERUNTUN';
        streakSub = 'Streak Presensi';
        streakGradient = [const Color(0xFFFF8A00), const Color(0xFFFF3D00)];
        streakShadow = const Color(0xFFFF5722);

        bannerIcon = Icons.fact_check_rounded;
        bannerIconColor = const Color(0xFF4F46E5);
        bannerBold = 'Tercatat oleh Guru Piket. ';
        bannerBoldColor = const Color(0xFF4338CA);
        bannerNormal =
            'Kehadiran fisik telah divalidasi manual di pos piket gerbang.';
        break;

      case 'terlambat':
        headerTitle = 'Presensi Terlambat';
        headerSubtitle = 'Melebihi Batas 07.00 WIB';
        dotColor = const Color(0xFFF59E0B);
        iconData = Icons.access_time_filled_rounded;
        iconGradient = [const Color(0xFFF59E0B), const Color(0xFFD97706)];
        iconShadow = const Color(0xFFF59E0B);

        badgeText = 'Hadir Terlambat';
        badgeIcon = Icons.schedule_rounded;
        badgeBg = const Color(0xFFFFFBEB);
        badgeBorder = const Color(0xFFFDE68A);
        badgeTextColor = const Color(0xFFB45309);

        tagText = 'Hari Efektif';
        jamLabel = 'JAM MASUK TERCATAT';
        jamValue = attendanceJam.isNotEmpty && attendanceJam != '06:45'
            ? attendanceJam
            : '07:18';
        jamUnit = 'WIB';
        jamColor = const Color(0xFFC2410C);

        streakIcon = '⚠️';
        streakNum = '0';
        streakLabel = 'TERLAMBAT';
        streakSub = 'Evaluasi Disiplin';
        streakGradient = [const Color(0xFFF97316), const Color(0xFFEA580C)];
        streakShadow = const Color(0xFFEA580C);

        bannerIcon = Icons.warning_amber_rounded;
        bannerIconColor = const Color(0xFFD97706);
        bannerBold = 'Tingkatkan Kedisiplinan! ';
        bannerBoldColor = const Color(0xFFB45309);
        bannerNormal =
            'Usahakan tiba sebelum pukul 07.00 WIB agar tidak tertinggal materi.';
        break;

      case 'sakit':
        headerTitle = 'Status Kehadiran';
        headerSubtitle = 'Surat Keterangan Medis';
        dotColor = const Color(0xFF0EA5E9);
        iconData = Icons.medical_services_rounded;
        iconGradient = [const Color(0xFF0EA5E9), const Color(0xFF0284C7)];
        iconShadow = const Color(0xFF0EA5E9);

        badgeText = 'Sedang Sakit';
        badgeIcon = Icons.healing_rounded;
        badgeBg = const Color(0xFFF0F9FF);
        badgeBorder = const Color(0xFFBAE6FD);
        badgeTextColor = const Color(0xFF0369A1);

        tagText = 'Izin Medis';
        jamLabel = 'STATUS HARI INI';
        jamValue = 'ISTIRAHAT';
        jamUnit = '';
        jamColor = const Color(0xFF0284C7);

        streakIcon = '🏥';
        streakNum = '+';
        streakLabel = 'PEMULIHAN MEDIS';
        streakSub = 'Keterangan Dokter';
        streakGradient = [const Color(0xFF0284C7), const Color(0xFF0369A1)];
        streakShadow = const Color(0xFF0369A1);

        bannerIcon = Icons.favorite_rounded;
        bannerIconColor = const Color(0xFFE11D48);
        bannerBold = 'Lekas Sembuh! ';
        bannerBoldColor = const Color(0xFF0284C7);
        bannerNormal =
            'Istirahatlah dengan cukup agar segera pulih dan dapat kembali belajar.';
        break;

      case 'izin':
        headerTitle = 'Status Kehadiran';
        headerSubtitle = 'Dispensasi Resmi Sekolah';
        dotColor = const Color(0xFFA855F7);
        iconData = Icons.event_available_rounded;
        iconGradient = [const Color(0xFFA855F7), const Color(0xFF7E22CE)];
        iconShadow = const Color(0xFFA855F7);

        badgeText = 'Izin Resmi';
        badgeIcon = Icons.assignment_turned_in_rounded;
        badgeBg = const Color(0xFFFAF5FF);
        badgeBorder = const Color(0xFFE9D5FF);
        badgeTextColor = const Color(0xFF7E22CE);

        tagText = 'Dispensasi';
        jamLabel = 'STATUS HARI INI';
        jamValue = 'DISPENSASI';
        jamUnit = '';
        jamColor = const Color(0xFF7E22CE);

        streakIcon = '📋';
        streakNum = 'OK';
        streakLabel = 'SURAT RESMI';
        streakSub = 'Disetujui Sekolah';
        streakGradient = [const Color(0xFF9333EA), const Color(0xFF6B21A8)];
        streakShadow = const Color(0xFF6B21A8);

        bannerIcon = Icons.menu_book_rounded;
        bannerIconColor = const Color(0xFF9333EA);
        bannerBold = 'Semoga Urusan Lancar! ';
        bannerBoldColor = const Color(0xFF7E22CE);
        bannerNormal =
            'Jangan lupa mengecek materi dan tugas hari ini dari teman sekelas.';
        break;

      case 'alfa':
      case 'alpa':
        headerTitle = 'Status Kehadiran';
        headerSubtitle = 'Belum Ada Konfirmasi';
        dotColor = const Color(0xFFF43F5E);
        iconData = Icons.person_off_rounded;
        iconGradient = [const Color(0xFFF43F5E), const Color(0xFFE11D48)];
        iconShadow = const Color(0xFFF43F5E);

        badgeText = 'Tanpa Keterangan';
        badgeIcon = Icons.error_outline_rounded;
        badgeBg = const Color(0xFFFFF1F2);
        badgeBorder = const Color(0xFFFECDD3);
        badgeTextColor = const Color(0xFFBE123C);

        tagText = 'Perlu Konfirmasi';
        jamLabel = 'STATUS PRESENSI';
        jamValue = 'TIDAK HADIR';
        jamUnit = '';
        jamColor = const Color(0xFFBE123C);

        streakIcon = '⚠️';
        streakNum = '0';
        streakLabel = 'STREAK TERHENTI';
        streakSub = 'Poin Berkurang';
        streakGradient = [const Color(0xFFE11D48), const Color(0xFF9F1239)];
        streakShadow = const Color(0xFF9F1239);

        bannerIcon = Icons.report_problem_rounded;
        bannerIconColor = const Color(0xFFE11D48);
        bannerBold = 'Peringatan Presensi! ';
        bannerBoldColor = const Color(0xFFBE123C);
        bannerNormal =
            'Segera hubungi wali kelas atau guru piket untuk konfirmasi kehadiran.';
        break;

      case 'belum':
        headerTitle = 'Presensi Biometrik';
        headerSubtitle = 'Silakan Tap RFID / Wajah di Gerbang';
        dotColor = const Color(0xFF94A3B8);
        iconData = Icons.fingerprint_rounded;
        iconGradient = [const Color(0xFF94A3B8), const Color(0xFF64748B)];
        iconShadow = const Color(0xFF94A3B8);

        badgeText = 'Belum Presensi';
        badgeIcon = Icons.hourglass_top_rounded;
        badgeBg = const Color(0xFFF8FAFC);
        badgeBorder = const Color(0xFFCBD5E1);
        badgeTextColor = const Color(0xFF475569);

        tagText = 'Hari Efektif';
        jamLabel = 'MENUNGGU SCAN GERBANG';
        jamValue = '-- : --';
        jamUnit = 'WIB';
        jamColor = const Color(0xFF64748B);

        streakIcon = '🔥';
        streakNum = '$attendanceStreak';
        streakLabel = 'HARI BERUNTUN';
        streakSub = 'Streak Aktif';
        streakGradient = [const Color(0xFFFF8A00), const Color(0xFFFF3D00)];
        streakShadow = const Color(0xFFFF5722);

        bannerIcon = Icons.alarm_rounded;
        bannerIconColor = const Color(0xFF6366F1);
        bannerBold = 'Selamat Pagi! ';
        bannerBoldColor = const Color(0xFF4338CA);
        bannerNormal =
            'Pintu gerbang dibuka pukul 06.30 WIB. Jangan lupa scan kehadiran ya.';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOP HEADER: ICON + TITLE + BADGE STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Kiri: Fingerprint Icon Box & Title
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: iconGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: iconShadow.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        iconData,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            headerTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6.5,
                            height: 6.5,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        headerSubtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Kanan: Status Badge (Dapat di-tap untuk simulasi skenario)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showScenarioSelectorModal(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: badgeBorder,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          badgeIcon,
                          color: badgeTextColor,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: badgeTextColor,
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

          // 2. ROW TANGGAL: KALENDER & HARI EFEKTIF
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 17,
                      color: Color(0xFF4F46E5),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _getFormattedTodayDate(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tagText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3. ROW JAM MASUK TERCATAT vs STREAK PRESENSI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Kiri: Jam Masuk
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jamLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4F46E5),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          jamValue,
                          style: TextStyle(
                            fontSize: jamValue.length > 5 ? 20 : 32,
                            fontWeight: FontWeight.w900,
                            color: jamColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (jamUnit.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            jamUnit,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4338CA),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Kanan: Card Gradient Streak Oranye-Merah
              Container(
                width: 142,
                height: 76,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: streakGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: streakShadow.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          streakIcon,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          streakNum,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      streakLabel,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      streakSub,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 4. MOTIVATIONAL BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  bannerIcon,
                  color: bannerIconColor,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: bannerBold,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: bannerBoldColor,
                            fontSize: 11.5,
                          ),
                        ),
                        TextSpan(
                          text: bannerNormal,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF334155),
                            fontSize: 11.5,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // MODAL SIMULASI SKENARIO PRESENSI
  // ========================================================
  void _showScenarioSelectorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Simulasi Skenario Presensi',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (overrideScenario != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          overrideScenario = null;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Skenario dikembalikan ke data otomatis sistem'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text('Reset'),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih salah satu kondisi presensi siswa untuk melihat perubahan tampilan secara langsung:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              _buildScenarioTile(
                icon: Icons.verified_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'Hadir Tepat Waktu',
                subtitle: 'Biometrik RFID & Face ID Terverifikasi (06:45 WIB)',
                isSelected: overrideScenario == 'hadir',
                onTap: () =>
                    _applyScenario('hadir', 'Hadir Tepat Waktu (Biometrik)'),
              ),
              _buildScenarioTile(
                icon: Icons.assignment_ind_rounded,
                iconColor: const Color(0xFF6366F1),
                title: 'Masuk tapi Diinput Manual Piket',
                subtitle:
                    'Divalidasi manual oleh Guru Piket di pos gerbang (06:52 WIB)',
                isSelected: overrideScenario == 'piket',
                onTap: () => _applyScenario(
                    'piket', 'Hadir Diinput Manual oleh Guru Piket'),
              ),
              _buildScenarioTile(
                icon: Icons.schedule_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: 'Hadir Terlambat',
                subtitle: 'Melebihi batas jam 07:00 WIB (07:18 WIB)',
                isSelected: overrideScenario == 'terlambat',
                onTap: () =>
                    _applyScenario('terlambat', 'Hadir Terlambat'),
              ),
              _buildScenarioTile(
                icon: Icons.medical_services_rounded,
                iconColor: const Color(0xFF0EA5E9),
                title: 'Sedang Sakit',
                subtitle: 'Surat keterangan dokter diterima pihak sekolah',
                isSelected: overrideScenario == 'sakit',
                onTap: () =>
                    _applyScenario('sakit', 'Sedang Sakit (Keterangan Medis)'),
              ),
              _buildScenarioTile(
                icon: Icons.assignment_turned_in_rounded,
                iconColor: const Color(0xFFA855F7),
                title: 'Izin Resmi',
                subtitle: 'Surat izin keperluan keluarga / dispensasi disetujui',
                isSelected: overrideScenario == 'izin',
                onTap: () =>
                    _applyScenario('izin', 'Izin Resmi (Dispensasi)'),
              ),
              _buildScenarioTile(
                icon: Icons.person_off_rounded,
                iconColor: const Color(0xFFF43F5E),
                title: 'Tanpa Keterangan (Alfa)',
                subtitle: 'Tidak hadir dan belum ada konfirmasi dari orang tua',
                isSelected: overrideScenario == 'alfa',
                onTap: () =>
                    _applyScenario('alfa', 'Tanpa Keterangan (Alfa)'),
              ),
              _buildScenarioTile(
                icon: Icons.hourglass_top_rounded,
                iconColor: const Color(0xFF64748B),
                title: 'Belum Presensi',
                subtitle: 'Kondisi pagi hari sebelum siswa scan di gerbang sekolah',
                isSelected: overrideScenario == 'belum',
                onTap: () =>
                    _applyScenario('belum', 'Belum Presensi (Pagi Hari)'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyScenario(String scenario, String label) {
    setState(() {
      overrideScenario = scenario;
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Skenario aktif: $label'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildScenarioTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? iconColor.withValues(alpha: 0.08)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? iconColor : const Color(0xFFE2E8F0),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? iconColor : const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: iconColor, size: 20)
            : const Icon(Icons.chevron_right_rounded,
                color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _showPklDetailBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (hasPkl
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFFF59E0B))
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasPkl
                          ? Icons.business_center_rounded
                          : Icons.info_outline_rounded,
                      color: hasPkl
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFFD97706),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasPkl ? pklNamaPerusahaan : 'Status Program PKL',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E2432),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasPkl
                              ? 'Praktik Kerja Lapangan'
                              : 'Informasi Penempatan',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8A92A6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              if (hasPkl) ...[
                _buildModalDetailRow('Status Penempatan', pklStatus,
                    isBadge: true),
                const SizedBox(height: 12),
                if (pklPeriode != null) ...[
                  _buildModalDetailRow('Periode Pelaksanaan', pklPeriode!),
                  const SizedBox(height: 12),
                ],
                if (pklGuru != null) ...[
                  _buildModalDetailRow('Guru Pembimbing', pklGuru!),
                  const SizedBox(height: 12),
                ],
                _buildModalDetailRow('Alamat Industri', pklAlamat),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.hourglass_empty_rounded,
                        color: Color(0xFFD97706),
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Siap Ditempatkan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Siswa telah memenuhi syarat dan sedang dalam proses penempatan industri DU/DI.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // Tutup Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

  Widget _buildModalDetailRow(String label, String value,
      {bool isBadge = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isBadge
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
