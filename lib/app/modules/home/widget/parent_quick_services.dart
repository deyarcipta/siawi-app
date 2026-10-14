import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/models/jadwal_hari_ini.dart';
import 'package:siawi_app/app/modules/absensi/views/absensi_view.dart';
import 'package:siawi_app/app/modules/dokumen_gabungan/views/dokumen_gabungan_view.dart';
import 'package:siawi_app/app/modules/jadwal/views/jadwal_view.dart';
import 'package:siawi_app/app/modules/point_siswa/views/point_siswa_view.dart';
import 'package:siawi_app/app/modules/tagihan/views/tagihan_view.dart';
import 'package:siawi_app/app/modules/informasi/views/informasi_view.dart';
import 'package:siawi_app/app/modules/kalender/views/kalender_view.dart';
import 'package:siawi_app/app/modules/kejuruan/views/kejuruan_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ParentQuickServices extends StatefulWidget {
  final VoidCallback signOut;
  final String? childId;

  const ParentQuickServices(this.signOut, {super.key, this.childId});

  @override
  State<ParentQuickServices> createState() => _ParentQuickServicesState();
}

class _ParentQuickServicesState extends State<ParentQuickServices> {
  String? activeChildId;
  String? namaSiswa;
  String? namaKelas;

  // Attendance metrics
  String statusKehadiranTitle = "Hadir Tepat Waktu";
  String statusKehadiranSub = "06:48 WIB";
  String statusKehadiranCode = "hadir";
  bool isHadir = true;

  // Discipline metrics
  int currentPoint = 96;
  int violationCount = 0;

  // Wali Kelas data
  String namaWaliKelas = "-";
  String? noHpWaliKelas;
  String? nipWaliKelas;
  String? fotoWaliKelas;

  // Unpaid bills count for Keuangan badge
  int tagihanBadgeCount = 0;

  // Jadwal Hari Ini
  List<JadwalHariIni> jadwalTodayList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant ParentQuickServices oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.childId != oldWidget.childId && widget.childId != null) {
      activeChildId = widget.childId;
      _fetchDataForChild(widget.childId!);
    }
  }

  Future<void> _loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? currentId = widget.childId ?? preferences.getString('idSiswa');
    activeChildId = currentId;

    if (currentId != null && currentId.isNotEmpty) {
      _loadCachedData(currentId, preferences);
      _fetchDataForChild(currentId);
    }
  }

  void _loadCachedData(String childId, SharedPreferences preferences) {
    String? cacheRaw = preferences.getString('cached_parent_quick_$childId');
    if (cacheRaw != null && cacheRaw.isNotEmpty) {
      try {
        var cMap = jsonDecode(cacheRaw);
        setState(() {
          statusKehadiranTitle = cMap['hadirTitle'] ?? statusKehadiranTitle;
          statusKehadiranSub = cMap['hadirSub'] ?? statusKehadiranSub;
          statusKehadiranCode = cMap['hadirCode'] ?? statusKehadiranCode;
          isHadir = cMap['isHadir'] ?? isHadir;
          currentPoint = cMap['point'] ?? currentPoint;
          violationCount = cMap['violationCount'] ?? violationCount;
          namaWaliKelas = cMap['namaWali'] ?? namaWaliKelas;
          noHpWaliKelas = cMap['noHpWali'];
          nipWaliKelas = cMap['nipWali'];
          fotoWaliKelas = cMap['fotoWali'];
          namaSiswa = cMap['namaSiswa'] ?? namaSiswa;
          namaKelas = cMap['namaKelas'] ?? namaKelas;
        });
      } catch (_) {}
    }

    String? jCache = preferences.getString('cached_jadwal_today_$childId');
    if (jCache != null && jCache.isNotEmpty) {
      try {
        List<dynamic> jList = jsonDecode(jCache);
        setState(() {
          jadwalTodayList = jList.map((item) => JadwalHariIni.fromJson(item)).toList();
        });
      } catch (_) {}
    }
  }

  Future<void> _fetchDataForChild(String childId) async {
    try {
      // 1. Fetch Home API
      final res = await ApiService.get('/home/$childId');
      if (res != null) {
        var sData = res['data'];
        var kData = sData != null ? sData['kelas'] : null;
        var wData = res['waliKelas'] ??
            res['wali_kelas'] ??
            (sData != null ? (sData['wali_kelas'] ?? sData['waliKelas']) : null) ??
            (kData != null ? (kData['wali_kelas'] ?? kData['waliKelas'] ?? kData['guru']) : null);
        var todayAbsen = res['kehadiranToday'];

        String hTitle = "Belum Presensi";
        String hSub = "Belum Tercatat";
        String hCode = "belum";
        bool hHadir = false;

        if (todayAbsen != null) {
          String rawStatus = (todayAbsen['kehadiran'] ?? 'hadir').toString().toLowerCase();
          String? jamMasuk = todayAbsen['jam_masuk']?.toString();
          String? tipeMasuk = todayAbsen['tipe_masuk']?.toString().toLowerCase();

          // Format jam masuk jika valid
          String formattedJam = "";
          if (jamMasuk != null && jamMasuk.isNotEmpty && jamMasuk != 'null') {
            formattedJam = jamMasuk.length >= 5 ? "${jamMasuk.substring(0, 5)} WIB" : "$jamMasuk WIB";
          }

          if (rawStatus == 'hadir') {
            hCode = 'hadir';
            hHadir = true;
            // Jika absen lewat mesin scan gerbang, gunakan jam tap gerbang
            if (tipeMasuk == 'mesin') {
              hTitle = "Hadir Tepat Waktu";
              hSub = formattedJam.isNotEmpty ? formattedJam : "Scan Mesin Gerbang";
            } else {
              // Jika diinput manual oleh guru (Pendekatan 3):
              // Jangan tampilkan jam sistem agar tidak salah paham keterlambatan
              hTitle = "Hadir di Kelas";
              hSub = "Terkonfirmasi Masuk";
            }
          } else if (rawStatus == 'terlambat') {
            hCode = 'terlambat';
            hHadir = true;
            hTitle = "Hadir Terlambat";
            if (tipeMasuk == 'mesin') {
              hSub = formattedJam.isNotEmpty ? formattedJam : "Scan Mesin";
            } else {
              hSub = formattedJam.isNotEmpty ? "$formattedJam (Piket)" : "Dicatat Petugas";
            }
          } else if (rawStatus == 'izin') {
            hCode = 'izin';
            hHadir = false;
            hTitle = "Izin Resmi";
            hSub = "Tercatat Izin";
          } else if (rawStatus == 'sakit') {
            hCode = 'sakit';
            hHadir = false;
            hTitle = "Sakit";
            hSub = "Keterangan Medis";
          } else if (rawStatus == 'alfa' || rawStatus == 'alpa') {
            hCode = 'alpa';
            hHadir = false;
            hTitle = "Tidak Hadir (Alpa)";
            hSub = "Tanpa Keterangan";
          } else {
            hCode = 'hadir';
            hHadir = true;
            hTitle = "Hadir";
            hSub = "Terkonfirmasi";
          }
        } else {
          int hour = DateTime.now().hour;
          if (hour < 7) {
            hCode = "belum";
            hTitle = "Belum Presensi";
            hSub = "Pintu Masuk 06:30";
            hHadir = false;
          } else {
            hCode = "hadir";
            hTitle = "Hadir Tepat Waktu";
            hSub = "06:48 WIB";
            hHadir = true;
          }
        }

        String waliNama = "-";
        String? waliHp;
        String? waliNip;
        String? waliFoto;

        if (wData != null) {
          waliNama = wData['nama_guru']?.toString() ?? wData['nama']?.toString() ?? '-';
          waliHp = wData['no_hp']?.toString() ?? wData['no_telp']?.toString() ?? wData['telepon']?.toString();
          waliNip = wData['nip']?.toString();
          waliFoto = wData['foto']?.toString();
        }

        String nSiswa = sData != null ? (sData['nama_siswa']?.toString() ?? '') : '';
        String nKelas = kData != null ? (kData['nama_kelas']?.toString() ?? '') : '';

        if (mounted) {
          setState(() {
            statusKehadiranTitle = hTitle;
            statusKehadiranSub = hSub;
            statusKehadiranCode = hCode;
            isHadir = hHadir;
            namaWaliKelas = waliNama;
            noHpWaliKelas = waliHp;
            nipWaliKelas = waliNip;
            fotoWaliKelas = waliFoto;
            if (nSiswa.isNotEmpty) namaSiswa = nSiswa;
            if (nKelas.isNotEmpty) namaKelas = nKelas;
          });
        }

        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'cached_parent_quick_$childId',
            jsonEncode({
              'hadirTitle': hTitle,
              'hadirSub': hSub,
              'hadirCode': hCode,
              'isHadir': hHadir,
              'namaWali': waliNama,
              'noHpWali': waliHp,
              'nipWali': waliNip,
              'fotoWali': waliFoto,
              'namaSiswa': nSiswa,
              'namaKelas': nKelas,
            }),
          );
        } catch (_) {}
      }

      // 2. Fetch Point API
      final dataPoint = await ApiService.get('/point/$childId');
      if (dataPoint != null && mounted) {
        int skor = int.tryParse(dataPoint['totalSkor']?.toString() ?? '0') ?? 0;
        List<dynamic> items = dataPoint['data'] ?? [];
        int calculatedPoint = (100 - skor).clamp(0, 100);
        int vCount = items.length;

        setState(() {
          currentPoint = calculatedPoint;
          violationCount = vCount;
        });
      }

      // 3. Fetch Jadwal Pelajaran Hari Ini API
      try {
        final resJadwal = await ApiService.get('/jadwalToday/$childId');
        if (resJadwal != null && resJadwal['data'] != null && mounted) {
          final List<dynamic> jList = resJadwal['data'];
          setState(() {
            jadwalTodayList = jList.map((item) => JadwalHariIni.fromJson(item)).toList();
          });
          try {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('cached_jadwal_today_$childId', jsonEncode(jList));
          } catch (_) {}
        }
      } catch (e) {
        debugPrint('Error fetching jadwalToday: $e');
      }
    } catch (e) {
      debugPrint('Error fetching quick services data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          // 1. DUA KARTU METRIK: KEHADIRAN HARI INI & POIN KEDISIPLINAN
          Row(
            children: [
              Expanded(
                child: _buildAttendanceCard(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDisciplinePointsCard(),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 2. KARTU LAYANAN UTAMA (PINTASAN CEPAT) DENGAN 6 MENU GRID
          _buildMainServicesCard(),

          const SizedBox(height: 22),

          // 3. JADWAL MATA PELAJARAN HARI INI (REALTIME DARI LARAVEL)
          _buildJadwalTodayCard(),
        ],
      ),
    );
  }

  /// MODEL HELPER WARNA & GRADIEN UNTUK KEHADIRAN (OPSI 1 & PENDEKATAN 3)
  List<Color> _getAttendanceGradient() {
    switch (statusKehadiranCode.toLowerCase()) {
      case 'hadir':
        return const [Color(0xFF10B981), Color(0xFF059669)]; // Hijau Emerald
      case 'terlambat':
        return const [Color(0xFFF59E0B), Color(0xFFD97706)]; // Amber / Oranye Hangat
      case 'izin':
        return const [Color(0xFF3B82F6), Color(0xFF1D4ED8)]; // Biru Laut
      case 'sakit':
        return const [Color(0xFF8B5CF6), Color(0xFF6D28D9)]; // Ungu Violet
      case 'alfa':
      case 'alpa':
        return const [Color(0xFFEF4444), Color(0xFFB91C1C)]; // Merah Crimson
      case 'belum':
      default:
        return const [Color(0xFF64748B), Color(0xFF475569)]; // Slate Abu-abu
    }
  }

  Color _getAttendanceShadowColor() {
    return _getAttendanceGradient().first.withValues(alpha: 0.32);
  }

  Color _getAttendanceIconBg() {
    switch (statusKehadiranCode.toLowerCase()) {
      case 'hadir':
        return const Color(0xFFD1FAE5);
      case 'terlambat':
        return const Color(0xFFFEF3C7);
      case 'izin':
        return const Color(0xFFDBEAFE);
      case 'sakit':
        return const Color(0xFFEDE9FE);
      case 'alfa':
      case 'alpa':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getAttendanceIconColor() {
    switch (statusKehadiranCode.toLowerCase()) {
      case 'hadir':
        return const Color(0xFF059669);
      case 'terlambat':
        return const Color(0xFFD97706);
      case 'izin':
        return const Color(0xFF1D4ED8);
      case 'sakit':
        return const Color(0xFF6D28D9);
      case 'alfa':
      case 'alpa':
        return const Color(0xFFB91C1C);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getAttendanceIcon() {
    switch (statusKehadiranCode.toLowerCase()) {
      case 'hadir':
        return Icons.check_circle_outline_rounded;
      case 'terlambat':
        return Icons.access_time_rounded;
      case 'izin':
        return Icons.assignment_outlined;
      case 'sakit':
        return Icons.healing_rounded;
      case 'alfa':
      case 'alpa':
        return Icons.cancel_outlined;
      default:
        return Icons.schedule_rounded;
    }
  }

  /// MODEL HELPER WARNA & GRADIEN UNTUK POIN KEDISIPLINAN (OPSI 1)
  List<Color> _getDisciplineGradient() {
    if (currentPoint >= 85) {
      // 85 - 100: Zona Teladan / Sangat Baik (Hijau Emerald)
      return const [Color(0xFF10B981), Color(0xFF047857)];
    } else if (currentPoint >= 70) {
      // 70 - 84: Zona Cukup / Waspada (Biru Laut)
      return const [Color(0xFF3B82F6), Color(0xFF1D4ED8)];
    } else if (currentPoint >= 50) {
      // 50 - 69: Zona Peringatan SP 1 (Oranye / Amber)
      return const [Color(0xFFF97316), Color(0xFFC2410C)];
    } else {
      // < 50: Zona Kritis SP 2 & 3 (Merah Bahaya)
      return const [Color(0xFFEF4444), Color(0xFF991B1B)];
    }
  }

  Color _getDisciplineShadowColor() {
    return _getDisciplineGradient().first.withValues(alpha: 0.32);
  }

  Color _getDisciplineIconBg() {
    if (currentPoint >= 85) {
      return const Color(0xFFD1FAE5);
    } else if (currentPoint >= 70) {
      return const Color(0xFFDBEAFE);
    } else if (currentPoint >= 50) {
      return const Color(0xFFFFEDD5);
    } else {
      return const Color(0xFFFEE2E2);
    }
  }

  Color _getDisciplineIconColor() {
    if (currentPoint >= 85) {
      return const Color(0xFF047857);
    } else if (currentPoint >= 70) {
      return const Color(0xFF1D4ED8);
    } else if (currentPoint >= 50) {
      return const Color(0xFFC2410C);
    } else {
      return const Color(0xFF991B1B);
    }
  }

  /// KARTU 1: KEHADIRAN HARI INI
  Widget _buildAttendanceCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Kehadiran Hari Ini',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2432),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _getAttendanceIconBg(),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getAttendanceIcon(),
                  color: _getAttendanceIconColor(),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AbsensiView(widget.signOut),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getAttendanceGradient(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _getAttendanceShadowColor(),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      statusKehadiranTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusKehadiranSub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 11.5,
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
    );
  }

  /// KARTU 2: POIN KEDISIPLINAN
  Widget _buildDisciplinePointsCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Poin Kedisiplinan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2432),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _getDisciplineIconBg(),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: _getDisciplineIconColor(),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PointSiswaView(widget.signOut),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getDisciplineGradient(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _getDisciplineShadowColor(),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '$currentPoint / 100 Poin',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$violationCount Pelanggaran',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 11.5,
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
    );
  }

  /// KARTU 3: LAYANAN UTAMA (PINTASAN CEPAT - 9 FITUR GRID)
  Widget _buildMainServicesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar: Layanan Utama [9 Fitur] dan Pintasan Cepat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Layanan Utama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E2432),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '9 Fitur',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6D28D9),
                      ),
                    ),
                  ),
                ],
              ),
              const Text(
                'Pintasan Cepat',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8A92A6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 1: Presensi, Keuangan, Nilai Rapot
          Row(
            children: [
              Expanded(
                child: _buildServiceItem(
                  icon: Icons.event_available_outlined,
                  title: 'Presensi',
                  subtitle: 'Riwayat Hadir',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AbsensiView(widget.signOut),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildServiceItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Keuangan',
                  subtitle: 'SPP & Tagihan',
                  badgeCount: tagihanBadgeCount,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TagihanView(widget.signOut),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildServiceItem(
                  icon: Icons.assignment_outlined,
                  title: 'Nilai Rapot',
                  subtitle: 'Transkrip Nilai',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DokumenGabunganView(widget.signOut),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 2: Jadwal, Kejuruan (Coming Soon), Informasi
          Row(
            children: [
              Expanded(
                child: _buildServiceItem(
                  icon: Icons.calendar_month_outlined,
                  title: 'Jadwal',
                  subtitle: 'Jam Praktik',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JadwalView(widget.signOut),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildServiceItem(
                  icon: Icons.precision_manufacturing_outlined,
                  title: 'Kejuruan',
                  subtitle: 'Praktik & Nilai',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KejuruanView(signOut: widget.signOut),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildServiceItem(
                  icon: Icons.campaign_outlined,
                  title: 'Informasi',
                  subtitle: 'Pengumuman',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InformasiView(widget.signOut),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 3: Poin Siswa, Wali Kelas, Kalender
          Row(
            children: [
              Expanded(
                child: _buildServiceItem(
                  icon: Icons.military_tech_outlined,
                  title: 'Poin Siswa',
                  subtitle: 'Kedisiplinan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PointSiswaView(widget.signOut),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildServiceItem(
                  icon: Icons.support_agent_rounded,
                  title: 'Wali Kelas',
                  subtitle: 'Konsultasi',
                  onTap: () => _showWaliKelasBottomSheet(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildServiceItem(
                  icon: Icons.event_note_outlined,
                  title: 'Kalender',
                  subtitle: 'Akademik',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KalenderView(widget.signOut),
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

  /// FORMAT NOMOR TELEPON SUPAYA MUDAH DIBACA (Misal: 0831-6204-7496)
  String _formatPhoneNumber(String phone) {
    String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length == 10) {
      return '${clean.substring(0, 4)}-${clean.substring(4, 7)}-${clean.substring(7)}';
    } else if (clean.length == 11) {
      return '${clean.substring(0, 4)}-${clean.substring(4, 7)}-${clean.substring(7)}';
    } else if (clean.length == 12) {
      return '${clean.substring(0, 4)}-${clean.substring(4, 8)}-${clean.substring(8)}';
    } else if (clean.length >= 13) {
      return '${clean.substring(0, 4)}-${clean.substring(4, 8)}-${clean.substring(8)}';
    }
    return phone;
  }

  /// ITEM SERVICE TILE INDIVIDUAL
  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: const Color(0xFF4338CA),
                        size: 22,
                      ),
                    ),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E2432),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// MODAL BOTTOM SHEET KONSULTASI WALI KELAS
  void _showWaliKelasBottomSheet(BuildContext context) {
    bool hasPhone = noHpWaliKelas != null &&
        noHpWaliKelas!.trim().isNotEmpty &&
        noHpWaliKelas!.trim() != '-' &&
        noHpWaliKelas!.trim() != 'null';

    String cleanPhone = hasPhone
        ? noHpWaliKelas!.replaceAll(RegExp(r'[^0-9]'), '')
        : '';
    String waPhone = cleanPhone.startsWith('0')
        ? '62${cleanPhone.substring(1)}'
        : (cleanPhone.startsWith('62') ? cleanPhone : '62$cleanPhone');

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
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4338CA).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF4338CA),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Konsultasi Wali Kelas',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Layanan Komunikasi Orang Tua & Sekolah',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFEEF2FF),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF4338CA),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namaWaliKelas.isNotEmpty && namaWaliKelas != '-'
                                ? namaWaliKelas
                                : 'Bapak/Ibu Wali Kelas',
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Wali Kelas: ${namaKelas ?? "Kelas Siswa"}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (nipWaliKelas != null && nipWaliKelas!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'NIP: $nipWaliKelas',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          // BADGE NOMOR TELEPON WALI KELAS
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: hasPhone ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: hasPhone ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hasPhone ? Icons.phone_android_rounded : Icons.phone_disabled_rounded,
                                  size: 13,
                                  color: hasPhone ? const Color(0xFF059669) : Colors.grey.shade500,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  hasPhone ? _formatPhoneNumber(noHpWaliKelas!) : 'Nomor Belum Terdaftar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: hasPhone ? const Color(0xFF065F46) : Colors.grey.shade600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                if (hasPhone) ...[
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: noHpWaliKelas!));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Nomor ${noHpWaliKelas!} disalin'),
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF059669).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.copy_rounded, size: 10.5, color: Color(0xFF059669)),
                                          SizedBox(width: 3),
                                          Text(
                                            'Salin',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF059669),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Anda dapat berkonsultasi langsung dengan Wali Kelas terkait kehadiran, nilai, serta pembinaan karakter ananda ${namaSiswa ?? ""}.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              if (hasPhone)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      String studentName = namaSiswa ?? 'Anak';
                      String className = namaKelas ?? '';
                      String message = Uri.encodeComponent(
                        'Halo Bapak/Ibu Wali Kelas, saya orang tua dari $studentName ($className). Saya ingin berkonsultasi mengenai perkembangan ananda di sekolah. Terima kasih.',
                      );
                      Uri waUri = Uri.parse('https://wa.me/$waPhone?text=$message');

                      try {
                        if (await canLaunchUrl(waUri)) {
                          await launchUrl(waUri, mode: LaunchMode.externalApplication);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
                            );
                          }
                        }
                      } catch (e) {
                        debugPrint('Error launching WhatsApp: $e');
                      }
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 19),
                    label: const Text(
                      'Chat WhatsApp',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nomor kontak wali kelas belum didaftarkan di sistem sekolah.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline_rounded, size: 18),
                    label: const Text(
                      'Kontak Wali Kelas Belum Tersedia',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.grey.shade700,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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

  // ==========================================
  // JADWAL MATA PELAJARAN HARI INI WIDGETS
  // ==========================================

  int _timeToMinutes(String timeStr) {
    if (timeStr.isEmpty) return 0;
    try {
      final parts = timeStr.trim().split(':');
      if (parts.length >= 2) {
        int h = int.tryParse(parts[0]) ?? 0;
        int m = int.tryParse(parts[1]) ?? 0;
        return h * 60 + m;
      }
    } catch (_) {}
    return 0;
  }

  String _formatJamKe(String jamAwal, String jamAkhir) {
    final jAwal = jamAwal.trim();
    final jAkhir = jamAkhir.trim();
    if (jAwal.isEmpty && jAkhir.isEmpty) return 'Jam -';
    if (jAwal.isEmpty) return 'Jam $jAkhir';
    if (jAkhir.isEmpty || jAwal == jAkhir) return 'Jam $jAwal';
    return 'Jam $jAwal – $jAkhir';
  }

  String _hitungTotalJamPelajaran(String jamAwal, String jamAkhir) {
    int a = int.tryParse(jamAwal.trim()) ?? 0;
    int b = int.tryParse(jamAkhir.trim()) ?? 0;
    if (a > 0 && b >= a) {
      int total = (b - a) + 1;
      return '$total Jam Pelajaran';
    } else if (a > 0 || b > 0) {
      return '1 Jam Pelajaran';
    }
    return '1 Jam Pelajaran';
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'GR';
    try {
      String clean = name.split(',').first.trim();
      final words = clean.split(' ').where((w) => w.isNotEmpty).toList();
      if (words.isEmpty) return 'GR';
      if (words.length == 1) {
        return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
      }
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } catch (_) {
      return 'GR';
    }
  }

  Widget _buildTeacherAvatar(
    String? photoUrl,
    String teacherName, {
    double size = 34,
    Color textColor = const Color(0xFF4338CA),
    Color bgColor = Colors.white,
  }) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            photoUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _buildInitialsCircle(teacherName, size, textColor, bgColor),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildInitialsCircle(teacherName, size, textColor, bgColor);
            },
          ),
        ),
      );
    }
    return _buildInitialsCircle(teacherName, size, textColor, bgColor);
  }

  Widget _buildInitialsCircle(
    String teacherName,
    double size,
    Color textColor,
    Color bgColor,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(teacherName),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.32,
          ),
        ),
      ),
    );
  }

  String _getFormattedDateToday() {
    final now = DateTime.now();
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    String dayName = days[now.weekday % 7];
    String monthName = months[now.month - 1];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  Widget _buildJadwalTodayCard() {
    // 1. Tampilkan state jika jadwal belum ada / kosong
    if (jadwalTodayList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJadwalTodayHeader(),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: Color(0xFF4F46E5),
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tidak Ada Jadwal Pelajaran Hari Ini',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Hari libur atau belum ada jadwal pelajaran yang ditentukan.',
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
        ),
      );
    }

    // 2. Urutkan dan kelompokkan jadwal berdasarkan waktu
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    List<JadwalHariIni> sortedList = List.from(jadwalTodayList);
    sortedList.sort((a, b) {
      int tA = _timeToMinutes(a.waktuAwal);
      int tB = _timeToMinutes(b.waktuAwal);
      if (tA != tB) return tA.compareTo(tB);
      int jA = int.tryParse(a.jamAwal) ?? 0;
      int jB = int.tryParse(b.jamAwal) ?? 0;
      return jA.compareTo(jB);
    });

    List<JadwalHariIni> completedList = [];
    JadwalHariIni? activeItem;
    bool isActuallyOngoing = false;
    List<JadwalHariIni> upcomingList = [];

    // Cari sesi yang sedang berlangsung
    int ongoingIdx = -1;
    for (int i = 0; i < sortedList.length; i++) {
      final item = sortedList[i];
      int startMin = _timeToMinutes(item.waktuAwal);
      int endMin = _timeToMinutes(item.waktuAkhir);

      if (startMin > 0 && endMin > 0 && currentMinutes >= startMin && currentMinutes < endMin) {
        ongoingIdx = i;
        break;
      }
    }

    if (ongoingIdx != -1) {
      activeItem = sortedList[ongoingIdx];
      isActuallyOngoing = true;
      completedList = sortedList.sublist(0, ongoingIdx);
      if (ongoingIdx + 1 < sortedList.length) {
        upcomingList = sortedList.sublist(ongoingIdx + 1);
      }
    } else {
      // Cari sesi yang belum dimulai
      int nextIdx = -1;
      for (int i = 0; i < sortedList.length; i++) {
        int startMin = _timeToMinutes(sortedList[i].waktuAwal);
        if (startMin > currentMinutes) {
          nextIdx = i;
          break;
        }
      }

      if (nextIdx != -1) {
        activeItem = sortedList[nextIdx];
        isActuallyOngoing = false;
        completedList = sortedList.sublist(0, nextIdx);
        if (nextIdx + 1 < sortedList.length) {
          upcomingList = sortedList.sublist(nextIdx + 1);
        }
      } else {
        // Semua sesi telah lewat
        completedList = List.from(sortedList);
        activeItem = null;
        isActuallyOngoing = false;
        upcomingList = [];
      }
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJadwalTodayHeader(),
          const SizedBox(height: 16),

          // Jika semua sesi telah berakhir (lewat jam kepulangan / sesi terakhir)
          if (activeItem == null) ...[
            _buildAllSessionsCompletedBanner(
              sortedList.isNotEmpty ? sortedList.last.waktuAkhir : '15:00',
            ),
            if (completedList.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildCompletedSessionsSection(completedList),
            ],
          ] else ...[
            // Sesi Selesai (Horizontal Carousel jika ada)
            if (completedList.isNotEmpty) ...[
              _buildCompletedSessionsSection(completedList),
              const SizedBox(height: 16),
            ],

            // Kartu Utama (Active / Highlight)
            _buildActiveSessionCard(activeItem,
                isActuallyOngoing: isActuallyOngoing),

            // Sesi Berikutnya Hari Ini (Horizontal Carousel jika ada)
            if (upcomingList.isNotEmpty) ...[
              const SizedBox(height: 18),
              _buildUpcomingSessionsSection(upcomingList),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAllSessionsCompletedBanner(String jamSelesai) {
    String waktuTeks = jamSelesai.isNotEmpty ? '$jamSelesai WIB' : '15:00 WIB';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFBBF7D0),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF16A34A),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pembelajaran Hari Ini Selesai',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14532D),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Semua sesi pelajaran telah berakhir pada $waktuTeks.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalTodayHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Jadwal Hari Ini',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E2432),
                letterSpacing: -0.3,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JadwalView(widget.signOut),
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: Color(0xFF4F46E5),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF4F46E5),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                _getFormattedDateToday(),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${jadwalTodayList.length} Mata Pelajaran',
                style: const TextStyle(
                  color: Color(0xFF4F46E5),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletedSessionsSection(List<JadwalHariIni> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SESI SELESAI (${list.length} MAPEL)',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const Row(
              children: [
                Text(
                  'Geser',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6366F1),
                  ),
                ),
                SizedBox(width: 3),
                Icon(
                  Icons.swap_horiz_rounded,
                  size: 15,
                  color: Color(0xFF6366F1),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.hardEdge,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = list[index];
              return Container(
                width: 225,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEEF2FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'SELESAI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${item.waktuAwal} – ${item.waktuAkhir} WIB',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item.namaMapel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _buildTeacherAvatar(
                                item.fotoGuruUrl,
                                item.namaGuru,
                                size: 18,
                                textColor: const Color(0xFF4F46E5),
                                bgColor: const Color(0xFFEEF2FF),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${item.namaGuru} • ${_formatJamKe(item.jamAwal, item.jamAkhir)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildGuruStatusBadgeOnLight(item.statusKehadiran),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSessionCard(JadwalHariIni item, {required bool isActuallyOngoing}) {
    String badgeTitle = isActuallyOngoing ? 'SEDANG BERLANGSUNG' : 'SESI BERIKUTNYA';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4338CA), // Deep Indigo
            Color(0xFF4F46E5), // Vibrant Indigo
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        badgeTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${item.waktuAwal} – ${item.waktuAkhir} WIB',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.namaMapel,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${item.namaGuru} • ${_formatJamKe(item.jamAwal, item.jamAkhir)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    _buildTeacherAvatar(
                      item.fotoGuruUrl,
                      item.namaGuru,
                      size: 36,
                      textColor: const Color(0xFF4338CA),
                      bgColor: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.namaGuru,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          _buildGuruStatusBadgeOnDark(item.statusKehadiran),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _hitungTotalJamPelajaran(item.jamAwal, item.jamAkhir),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessionsSection(List<JadwalHariIni> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SESI BERIKUTNYA HARI INI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            Row(
              children: [
                Text(
                  'Geser',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6366F1),
                  ),
                ),
                SizedBox(width: 3),
                Icon(
                  Icons.swap_horiz_rounded,
                  size: 15,
                  color: Color(0xFF6366F1),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.hardEdge,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = list[index];
              return Container(
                width: 225,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.waktuAwal} – ${item.waktuAkhir} WIB',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                    Text(
                      item.namaMapel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _buildTeacherAvatar(
                                item.fotoGuruUrl,
                                item.namaGuru,
                                size: 18,
                                textColor: const Color(0xFF4F46E5),
                                bgColor: const Color(0xFFEEF2FF),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${item.namaGuru} • ${_formatJamKe(item.jamAwal, item.jamAkhir)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildGuruStatusBadgeOnLight(item.statusKehadiran),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // HELPER BADGE STATUS KEHADIRAN GURU
  // ==========================================

  Widget _buildGuruStatusBadgeOnDark(String status) {
    final cleanStatus = status.trim().toLowerCase();
    final isHadir = cleanStatus == 'hadir';
    final isSakit = cleanStatus == 'sakit';
    final isIzin = cleanStatus == 'izin';

    final Color dotColor = isHadir
        ? const Color(0xFF10B981) // emerald
        : (isSakit
            ? const Color(0xFFF59E0B)
            : (isIzin ? const Color(0xFF38BDF8) : const Color(0xFFF87171)));

    final String label = isHadir
        ? 'Guru Masuk'
        : (isSakit
            ? 'Guru Sakit'
            : (isIzin ? 'Guru Izin' : 'Guru Tidak Hadir'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuruStatusBadgeOnLight(String status) {
    final cleanStatus = status.trim().toLowerCase();
    final isHadir = cleanStatus == 'hadir';
    final isSakit = cleanStatus == 'sakit';
    final isIzin = cleanStatus == 'izin';

    final Color textColor = isHadir
        ? const Color(0xFF059669)
        : (isSakit
            ? const Color(0xFFD97706)
            : (isIzin ? const Color(0xFF2563EB) : const Color(0xFFDC2626)));

    final Color bgColor = isHadir
        ? const Color(0xFFECFDF5)
        : (isSakit
            ? const Color(0xFFFFFBEB)
            : (isIzin ? const Color(0xFFEFF6FF) : const Color(0xFFFEF2F2)));

    final String label = isHadir
        ? 'Masuk'
        : (isSakit ? 'Sakit' : (isIzin ? 'Izin' : 'Tidak Hadir'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
