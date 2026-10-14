import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/models/jadwal.dart';

class JadwalList extends StatefulWidget {
  final VoidCallback signOut;
  final String scrollKey;
  final String hari;

  const JadwalList({
    super.key,
    required this.scrollKey,
    required this.hari,
    required this.signOut,
  });

  @override
  State<JadwalList> createState() => _JadwalListState();
}

class _JadwalListState extends State<JadwalList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Future<List<Jadwal>> _jadwalFuture;

  @override
  void initState() {
    super.initState();
    _jadwalFuture = _loadJadwal();
  }

  Future<List<Jadwal>> _loadJadwal() async {
    final idSiswa = await _getIdSiswa();
    if (idSiswa == null || idSiswa.isEmpty) {
      return [];
    }
    return _fetchDataFromAPI(idSiswa, widget.hari);
  }

  Future<void> _refresh() async {
    setState(() {
      _jadwalFuture = _loadJadwal();
    });
  }

  Future<String?> _getIdSiswa() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('idSiswa');
  }

  Future<List<Jadwal>> _fetchDataFromAPI(String idSiswa, String hari) async {
    final encodedIdSiswa = Uri.encodeComponent(idSiswa);
    final encodedHari = Uri.encodeComponent(hari.toLowerCase());

    try {
      final responseData =
          await ApiService.get('/jadwal/$encodedIdSiswa/$encodedHari');
      if (responseData != null &&
          responseData['data'] != null &&
          responseData['data'][hari.toLowerCase()] != null) {
        final List<dynamic> jadwalsByDay =
            responseData['data'][hari.toLowerCase()];
        return jadwalsByDay.map((data) => Jadwal.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Color _getAccentColor(int index) {
    const colors = [
      Color(0xFF4C3EC7), // Indigo SIAWI
      Color(0xFF0284C7), // Sky Blue
      Color(0xFF059669), // Emerald Green
      Color(0xFFD97706), // Amber
      Color(0xFF7C3AED), // Violet
      Color(0xFFE11D48), // Rose
    ];
    return colors[index % colors.length];
  }

  String _formatHari(String hari) {
    if (hari.isEmpty) return '';
    return hari[0].toUpperCase() + hari.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: _refresh,
      color: const Color(0xFF4C3EC7),
      backgroundColor: Colors.white,
      child: FutureBuilder<List<Jadwal>>(
        future: _jadwalFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildEmptyState(
              title: 'Gagal Memuat Jadwal',
              message:
                  'Terjadi kendala saat mengambil data jadwal pelajaran. Tarik ke bawah untuk memuat ulang.',
              isError: true,
            );
          }

          final List<Jadwal> jadwals = snapshot.data ?? [];
          if (jadwals.isEmpty) {
            return _buildEmptyState(
              title: 'Tidak Ada Jadwal',
              message:
                  'Tidak ada kegiatan belajar mengajar yang dijadwalkan pada hari ${_formatHari(widget.hari)}.',
            );
          }

          return ListView.separated(
            key: PageStorageKey(widget.scrollKey),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: jadwals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final jadwal = jadwals[index];
              final accentColor = _getAccentColor(index);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFF64748B).withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Aksen garis warna di sisi kiri
                        Container(
                          width: 5,
                          color: accentColor,
                        ),

                        // Konten Utama Card
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Baris Atas: Jam Ke & Waktu Mulai-Selesai
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accentColor.withValues(
                                            alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.access_time_filled_rounded,
                                            size: 13,
                                            color: accentColor,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "Jam ke ${jadwal.jamAwal} - ${jadwal.jamAkhir}",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: accentColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Rentang Waktu
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.schedule_rounded,
                                            size: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${jadwal.waktuAwal} - ${jadwal.waktuAkhir}",
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
                                const SizedBox(height: 10),

                                // Nama Mata Pelajaran
                                Text(
                                  jadwal.namaMapel.isNotEmpty
                                      ? jadwal.namaMapel
                                      : 'Mata Pelajaran',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),

                                // Guru Pengampu
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: accentColor
                                          .withValues(alpha: 0.12),
                                      child: Text(
                                        jadwal.namaGuru.isNotEmpty
                                            ? jadwal.namaGuru[0].toUpperCase()
                                            : 'G',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: accentColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        jadwal.namaGuru.isNotEmpty
                                            ? jadwal.namaGuru
                                            : 'Guru Pengampu',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF64748B),
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
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 108,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 90,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  width: 80,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: 140,
              height: 14,
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

  Widget _buildEmptyState({
    required String title,
    required String message,
    bool isError = false,
  }) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isError
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError
                      ? Icons.error_outline_rounded
                      : Icons.event_available_rounded,
                  size: 44,
                  color: isError
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF4C3EC7),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
