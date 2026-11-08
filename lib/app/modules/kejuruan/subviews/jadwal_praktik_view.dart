import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';

class JadwalPraktikView extends StatefulWidget {
  final String? idSiswa;
  const JadwalPraktikView({this.idSiswa, super.key});

  @override
  State<JadwalPraktikView> createState() => _JadwalPraktikViewState();
}

class _JadwalPraktikViewState extends State<JadwalPraktikView> {
  bool _isLoading = true;
  String? _effectiveIdSiswa;
  String _selectedDay = 'Senin';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Tab hari (tanpa 'Semua')
  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

  List<Map<String, dynamic>> _allJadwal = [];
  String _namaJurusan = 'Kejuruan';
  String _kodeJurusan = 'KEJURUAN';

  String _getTodayName() {
    switch (DateTime.now().weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
      default:
        return 'Senin';
    }
  }

  @override
  void initState() {
    super.initState();
    // Default tab yang terbuka adalah sesuai hari ini
    _selectedDay = _getTodayName();
    _effectiveIdSiswa = widget.idSiswa;
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    if (_effectiveIdSiswa == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _effectiveIdSiswa = prefs.getString('idSiswa');
    }

    if (_effectiveIdSiswa != null) {
      try {
        final res = await ApiService.get(
          '/kejuruan/jadwal/$_effectiveIdSiswa',
          forceRefresh: true,
          silent: true,
        );
        if (res != null && res['success'] == true && res['data'] is List) {
          if (res['meta'] is Map) {
            _namaJurusan = (res['meta']['nama_jurusan'] ?? _namaJurusan).toString();
            _kodeJurusan = (res['meta']['kode_jurusan'] ?? _kodeJurusan).toString();
          }
          final List rawList = res['data'];
          _allJadwal = rawList.map((e) {
            final m = Map<String, dynamic>.from(e);
            final jamMulai = m['jam_mulai'] != null && m['jam_mulai'].toString().length >= 5 
                ? m['jam_mulai'].toString().substring(0, 5) 
                : (m['jam_mulai']?.toString() ?? '-');
            final jamSelesai = m['jam_selesai'] != null && m['jam_selesai'].toString().length >= 5 
                ? m['jam_selesai'].toString().substring(0, 5) 
                : (m['jam_selesai']?.toString() ?? '-');
            return {
              'mapel': m['mapel'] is Map ? (m['mapel']['nama_mapel'] ?? '-') : (m['mapel'] ?? '-'),
              'kode': m['kode_jadwal'] ?? m['kode'] ?? '-',
              'hari': m['hari'] ?? '-',
              'jam_mulai': jamMulai,
              'jam_selesai': jamSelesai,
              'lab': m['lab'] is Map ? (m['lab']['nama_lab'] ?? '-') : (m['lab'] ?? '-'),
              'guru': m['guru'] is Map ? (m['guru']['nama_guru'] ?? '-') : (m['guru'] ?? '-'),
              'alat_bahan': m['alat_bahan'] ?? '-',
              'status': m['frekuensi_label'] ?? m['status'] ?? 'Setiap Minggu',
              'is_active': m['is_active'] ?? false,
              'ruangan': m['lab'] is Map ? (m['lab']['nama_lab'] ?? '-') : (m['ruangan'] ?? 'Lab'),
            };
          }).toList();
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredJadwal {
    return _allJadwal.where((item) {
      final hari = (item['hari'] ?? '').toString();
      final mapel = (item['mapel'] is Map ? item['mapel']['nama_mapel'] : item['mapel'] ?? item['materi'] ?? '').toString().toLowerCase();
      final lab = (item['lab'] is Map ? item['lab']['nama_lab'] : item['lab'] ?? '').toString().toLowerCase();
      final guru = (item['guru'] is Map ? item['guru']['nama_guru'] : item['guru'] ?? '').toString().toLowerCase();

      final matchesDay = hari.toLowerCase() == _selectedDay.toLowerCase();
      final matchesQuery = _searchQuery.isEmpty ||
          mapel.contains(_searchQuery.toLowerCase()) ||
          lab.contains(_searchQuery.toLowerCase()) ||
          guru.contains(_searchQuery.toLowerCase());

      return matchesDay && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4C3EC7)),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: const Color(0xFF4C3EC7),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Jadwal Hari Terpilih
                          if (_filteredJadwal.isEmpty)
                            _buildEmptyJadwalDay()
                          else
                            ..._filteredJadwal.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildJadwalCard(item),
                              );
                            }),

                          const SizedBox(height: 12),

                          // 2. Peralatan Wajib & Tata Tertib Masuk Lab (Tampil di Seluruh Hari)
                          _buildPeralatanDanTataTertibSection(),
                        ],
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
          child: Column(
            children: [
              Row(
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
                          "Jadwal Praktik Kejuruan",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          "Agenda Praktik Laboratorium & Bengkel",
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
              const SizedBox(height: 12),
              // Search Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: "Cari mata praktik, lab, atau guru...",
                    hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _days.map((day) {
            final isSelected = _selectedDay.toLowerCase() == day.toLowerCase();
            final isToday = day.toLowerCase() == _getTodayName().toLowerCase();

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedDay = day),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4C3EC7) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4C3EC7) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF4C3EC7).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 5),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.amberAccent : const Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildJadwalCard(Map<String, dynamic> item) {
    String mapel = (item['mapel'] is Map ? item['mapel']['nama_mapel'] : item['mapel'] ?? item['materi'] ?? 'Praktik Kejuruan').toString();
    String lab = (item['lab'] is Map ? item['lab']['nama_lab'] : item['lab'] ?? 'Lab Praktik').toString();
    String hari = item['hari'] ?? 'Senin';
    String jamMulai = (item['jam_mulai'] ?? '08:00').toString().substring(0, 5);
    String jamSelesai = (item['jam_selesai'] ?? '10:15').toString().substring(0, 5);
    String guru = (item['guru'] is Map ? item['guru']['nama_guru'] : item['guru'] ?? '-').toString();
    String alat = item['alat_bahan'] ?? '-';
    String kode = item['kode'] ?? 'PRAKTIK';
    bool isActive = item['is_active'] == true || item['status'] == 'Hari Ini' || hari.toLowerCase() == _getTodayName().toLowerCase();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? const Color(0xFF818CF8) : const Color(0xFFE2E8F0),
          width: isActive ? 1.5 : 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive ? const Color(0xFF4C3EC7).withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card: Badge Hari, Jam, Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF4C3EC7) : const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hari.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.schedule_rounded, size: 14, color: isActive ? const Color(0xFF4C3EC7) : const Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  "$jamMulai – $jamSelesai WIB",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isActive ? const Color(0xFF4C3EC7) : const Color(0xFF475569),
                  ),
                ),
                const Spacer(),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: const Text(
                      "Hari Ini",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  )
                else
                  Text(
                    kode,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
              ],
            ),
          ),

          // Body Card
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mapel,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),

                // Lab & Ruangan
                Row(
                  children: [
                    const Icon(Icons.room_rounded, size: 15, color: Color(0xFF0284C7)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        lab,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Guru Pengampu
                Row(
                  children: [
                    const Icon(Icons.person_rounded, size: 15, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Instruktur: $guru",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Alat & Bahan yang Wajib Dibawa
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.handyman_rounded, size: 14, color: Color(0xFFB45309)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Alat/Bahan: $alat",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400E),
                            height: 1.3,
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
    );
  }

  Widget _buildEmptyJadwalDay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_available_rounded,
              size: 28,
              color: Color(0xFF4C3EC7),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Tidak Ada Praktik di Hari $_selectedDay",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Tidak ada sesi praktik laboratorium atau bengkel yang dijadwalkan pada hari ini.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // Bagian Peralatan Wajib & Tata Tertib Masuk Lab (Konsisten Tampil di Seluruh Hari)
  Widget _buildPeralatanDanTataTertibSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul Bagian
        Row(
          children: const [
            Icon(
              Icons.checklist_rtl_rounded,
              size: 20,
              color: Color(0xFF4C3EC7),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Peralatan Wajib & Tata Tertib Masuk Lab",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3 Kartu Peralatan Wajib
        Row(
          children: [
            Expanded(
              child: _buildEquipmentCard(
                icon: Icons.checkroom_rounded,
                iconColor: const Color(0xFF2563EB),
                bgColor: const Color(0xFFDBEAFE),
                title: "Seragam /\nWearpack",
                subtitle: "Wajib dipakai rapi",
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildEquipmentCard(
                icon: Icons.handyman_rounded,
                iconColor: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEDE9FE),
                title: "Alat & Modul\nPraktik",
                subtitle: "Sesuai job sheet",
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildEquipmentCard(
                icon: Icons.badge_rounded,
                iconColor: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEDE9FE),
                title: "Kartu ID\nSiswa",
                subtitle: "Presensi bengkel",
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Kartu Standar Operasional (SOP) Kejuruan
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FE),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E7FF), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header SOP
              Row(
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 19,
                    color: Color(0xFF4C3EC7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Standar Operasional (SOP) Lab $_namaJurusan",
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Poin 1
              _buildSopItem(
                number: "1",
                text: "Hadir 10 menit sebelum sesi praktik dimulai dan mengikuti pengarahan K3 dari instruktur.",
              ),
              const SizedBox(height: 12),

              // Poin 2
              _buildSopItem(
                number: "2",
                text: "Dilarang membawa makanan/minuman ke area meja kerja, perangkat laboratorium, atau bengkel praktik.",
              ),
              const SizedBox(height: 12),

              // Poin 3
              _buildSopItem(
                number: "3",
                text: "Wajib merapikan kembali peralatan kerja dan membersihkan area praktik sebelum meninggalkan ruangan.",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSopItem({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFFE0E7FE),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4338CA),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
              height: 1.38,
            ),
          ),
        ),
      ],
    );
  }
}
