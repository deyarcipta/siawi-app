import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/models/jadwal_hari_ini.dart';
import 'package:siawi_app/app/modules/jadwal/views/jadwal_view.dart';

class JadwalToday extends StatefulWidget {
  final VoidCallback signOut;
  const JadwalToday(this.signOut, {super.key});

  @override
  State<JadwalToday> createState() => _JadwalTodayState();
}

class _JadwalTodayState extends State<JadwalToday> {
  List<JadwalHariIni> jadwalTodayList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? idSiswa = preferences.getString('idSiswa');

    if (idSiswa != null && idSiswa.isNotEmpty) {
      // 1. Load cached data first for instant display
      String? cached = preferences.getString('cached_jadwal_today_$idSiswa');
      if (cached != null && cached.isNotEmpty) {
        try {
          List<dynamic> jList = jsonDecode(cached);
          if (mounted) {
            setState(() {
              jadwalTodayList =
                  jList.map((item) => JadwalHariIni.fromJson(item)).toList();
              isLoading = false;
            });
          }
        } catch (_) {}
      }

      // 2. Fetch fresh data from API
      _fetchJadwalToday(idSiswa);
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchJadwalToday(String idSiswa) async {
    try {
      final responseData = await ApiService.get('/jadwalToday/$idSiswa');
      if (responseData != null && responseData['data'] != null) {
        final List<dynamic> list = responseData['data'];
        if (mounted) {
          setState(() {
            jadwalTodayList =
                list.map((item) => JadwalHariIni.fromJson(item)).toList();
            isLoading = false;
          });
        }

        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'cached_jadwal_today_$idSiswa', jsonEncode(list));
        } catch (_) {}
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ==========================================
  // HELPER METHODS
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
        return words[0]
            .substring(0, words[0].length >= 2 ? 2 : 1)
            .toUpperCase();
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
    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
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
    String dayName = days[now.weekday % 7];
    String monthName = months[now.month - 1];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  // ==========================================
  // BUILD METHOD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: _buildJadwalTodayCard(),
    );
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

      if (startMin > 0 &&
          endMin > 0 &&
          currentMinutes >= startMin &&
          currentMinutes < endMin) {
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
        // Semua sesi telah lewat (contohnya lewat dari jam 15.00 WIB)
        // Kartu ungu tidak ditampilkan lagi, semua sesi masuk ke sesi selesai
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
            // Sesi Selesai Sebelumnya (jika ada)
            if (completedList.isNotEmpty) ...[
              _buildCompletedSessionsSection(completedList),
              const SizedBox(height: 16),
            ],

            // Kartu Utama Ungu (HANYA MUNCUL jika sedang berlangsung atau ada sesi berikutnya)
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

  Widget _buildActiveSessionCard(JadwalHariIni item,
      {required bool isActuallyOngoing}) {
    String badgeTitle =
        isActuallyOngoing ? 'SEDANG BERLANGSUNG' : 'SESI BERIKUTNYA';

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
