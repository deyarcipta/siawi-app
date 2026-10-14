import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/modules/kalender/widget/event.dart';
import 'package:siawi_app/app/modules/kalender/widget/event_data_source.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class KalenderView extends StatefulWidget {
  final VoidCallback signOut;
  const KalenderView(this.signOut, {super.key});

  @override
  State<KalenderView> createState() => _KalenderViewState();
}

class _KalenderViewState extends State<KalenderView> {
  List<Kegiatan> _kegiatanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKegiatan();
  }

  Future<void> _fetchKegiatan() async {
    final preferences = await SharedPreferences.getInstance();
    final idSiswa = preferences.getString('idSiswa');

    if (idSiswa != null && idSiswa.isNotEmpty) {
      try {
        final responseData = await ApiService.get('/kalender/');
        if (responseData != null &&
            responseData['data'] != null &&
            mounted) {
          final List<dynamic> kegiatanData = responseData['data'];
          final List<Kegiatan> loaded = [];
          for (var i = 0; i < kegiatanData.length; i++) {
            loaded.add(Kegiatan.fromJson(kegiatanData[i], i));
          }

          setState(() {
            _kegiatanList = loaded;
            _isLoading = false;
          });
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } catch (_) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTodayIndonesian() {
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
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  bool _isSameDayOrBetween(DateTime targetDate, DateTime from, DateTime to) {
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    return !target.isBefore(start) && !target.isAfter(end);
  }

  int get _todayAgendaCount {
    final now = DateTime.now();
    return _kegiatanList
        .where((k) => _isSameDayOrBetween(now, k.from, k.to))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header Modern Lengkung Ungu SIAWI
          _buildHeader(),

          const SizedBox(height: 12),

          // Kalender Syncfusion Modern
          Expanded(
            child: _isLoading
                ? _buildLoadingSkeleton()
                : RefreshIndicator(
                    onRefresh: _fetchKegiatan,
                    color: const Color(0xFF4C3EC7),
                    backgroundColor: Colors.white,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF64748B)
                                .withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: SfCalendar(
                          view: CalendarView.month,
                          showNavigationArrow: true,
                          initialSelectedDate: DateTime.now(),
                          todayHighlightColor: const Color(0xFF4C3EC7),
                          cellBorderColor: const Color(0xFFF1F5F9),
                          dataSource: KegiatanDataSource(_kegiatanList),
                          headerStyle: const CalendarHeaderStyle(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                            textAlign: TextAlign.center,
                            backgroundColor: Colors.white,
                          ),
                          viewHeaderStyle: const ViewHeaderStyle(
                            dayTextStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                            dateTextStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          selectionDecoration: BoxDecoration(
                            color: const Color(0xFF4C3EC7)
                                .withValues(alpha: 0.12),
                            border: Border.all(
                              color: const Color(0xFF4C3EC7),
                              width: 1.8,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          monthViewSettings: const MonthViewSettings(
                            appointmentDisplayMode:
                                MonthAppointmentDisplayMode.indicator,
                            showAgenda: true,
                            agendaViewHeight: 220,
                            agendaStyle: AgendaStyle(
                              backgroundColor: Color(0xFFF8FAFC),
                              appointmentTextStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              dateTextStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4C3EC7),
                              ),
                              dayTextStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            monthCellStyle: MonthCellStyle(
                              textStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                              trailingDatesTextStyle: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFCBD5E1),
                              ),
                              leadingDatesTextStyle: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
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
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Ornamen Lingkaran Halus
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
                              'Kalender Akademik',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              'Jadwal & Agenda Kegiatan Sekolah',
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

                  // Floating Summary Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.event_note_rounded,
                            color: Color(0xFF4C3EC7),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatTodayIndonesian(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Kalender Pendidikan SMK Wisata Indonesia',
                                style: TextStyle(
                                  fontSize: 11,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _todayAgendaCount > 0
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _todayAgendaCount > 0
                                  ? const Color(0xFFA7F3D0)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            _todayAgendaCount > 0
                                ? '$_todayAgendaCount Agenda Hari Ini'
                                : '0 Agenda Hari Ini',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _todayAgendaCount > 0
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF64748B),
                            ),
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

  Widget _buildLoadingSkeleton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 140,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: 35,
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
