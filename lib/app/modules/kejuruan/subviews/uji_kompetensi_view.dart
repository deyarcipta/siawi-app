import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';

class UjiKompetensiView extends StatefulWidget {
  final String? idSiswa;
  const UjiKompetensiView({this.idSiswa, super.key});

  @override
  State<UjiKompetensiView> createState() => _UjiKompetensiViewState();
}

class _UjiKompetensiViewState extends State<UjiKompetensiView> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _effectiveIdSiswa;
  late TabController _tabController;

  Map<String, dynamic> _ukkData = {};

  List<Map<String, dynamic>> _unitKompetensi = [];
  List<Map<String, dynamic>> _tahapanUji = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _effectiveIdSiswa = widget.idSiswa;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          '/kejuruan/ukk/$_effectiveIdSiswa',
          forceRefresh: true,
          silent: true,
        );
        if (res != null && res['success'] == true && res['data'] is Map) {
          final data = Map<String, dynamic>.from(res['data']);
          final kegiatan = data['kegiatan'] is Map ? data['kegiatan'] : {};
          final rawKelulusan = (data['status_kelulusan_raw'] ?? '').toString();
          final bool sudahDinilai = rawKelulusan == 'kompeten' || rawKelulusan == 'belum_kompeten';

          _ukkData = {
            'skema': kegiatan['nama_kegiatan'] ?? 'Uji Kompetensi Keahlian',
            'lembaga': kegiatan['penyelenggara'] ?? 'LSP-P1 / SMK Wisata Indonesia',
            'nomor_skema': kegiatan['nomor_sk'] ?? kegiatan['nomor_skema'] ?? '-',
            'nomor_peserta': data['nomor_peserta'] ?? '-',
            'nilai_akhir': data['nilai_akhir'] ?? 0,
            'status_peserta': data['status_kelulusan'] ?? 'Terdaftar Peserta',
            'tempat_uji': kegiatan['tempat_uji'] ?? 'TUK Laboratorium',
            'asesor': kegiatan['asesor'] ?? 'Tim Penguji UKK',
            'jadwal_utama': kegiatan['tanggal_mulai'] ?? '-',
            'target_kelulusan': 'Predikat Kompeten',
          };

          if (data['unit_kompetensi'] is List) {
            _unitKompetensi = (data['unit_kompetensi'] as List).map((u) {
              final map = u is Map ? Map<String, dynamic>.from(u) : <String, dynamic>{};
              final nilaiStr = map['nilai'] != null ? ' • Nilai: ${map['nilai']} (KKM ${map['kkm'] ?? 75})' : ' • KKM ${map['kkm'] ?? 75}';
              return {
                'kode': (map['kode_unit'] ?? '-').toString(),
                'judul': (map['nama_unit'] ?? 'Unit Kompetensi').toString(),
                'jenis': '${map['penguji'] ?? 'Asesmen Praktik'}$nilaiStr',
                'status': (map['status'] ?? 'Menunggu Penilaian').toString(),
                'is_kompeten': map['is_kompeten'] == true,
                'sudah_dinilai': map['sudah_dinilai'] == true,
              };
            }).toList();
          } else if (data['nilais'] is List) {
            _unitKompetensi = (data['nilais'] as List).map((n) {
              final unit = n['unit'] is Map ? n['unit'] : (n['unit_kompetensi'] is Map ? n['unit_kompetensi'] : {});
              final komp = unit['kompetensi'] is Map ? unit['kompetensi'] : unit;
              final bool isKomp = n['status'] == 'kompeten' || n['is_kompeten'] == true;
              return {
                'kode': (komp['kode_kompetensi'] ?? komp['kode_unit'] ?? '-').toString(),
                'judul': (komp['nama_kompetensi'] ?? komp['nama_unit'] ?? 'Unit Kompetensi').toString(),
                'jenis': 'Nilai: ${n['nilai'] ?? 0}',
                'status': isKomp ? 'Kompeten' : 'Belum Kompeten',
                'is_kompeten': isKomp,
                'sudah_dinilai': true,
              };
            }).toList();
          }

          final tglMulai = kegiatan['tanggal_mulai'] ?? '-';
          final tglSelesai = kegiatan['tanggal_selesai'] ?? '-';
          final statusKeg = (kegiatan['status_kegiatan'] ?? 'berlangsung').toString();

          _tahapanUji = [
            {
              'fase': 'Tahap 1',
              'judul': 'Pendaftaran & Verifikasi Peserta (${_ukkData['nomor_peserta']})',
              'jadwal': 'No. SK: ${_ukkData['nomor_skema']}',
              'status': 'Terdaftar',
              'is_done': true,
            },
            {
              'fase': 'Tahap 2',
              'judul': 'Pelaksanaan Uji Praktik & Demonstrasi Kinerja',
              'jadwal': '$tglMulai s.d $tglSelesai',
              'status': sudahDinilai || statusKeg == 'selesai' ? 'Selesai' : 'Sedang Berlangsung',
              'is_done': sudahDinilai || statusKeg == 'selesai',
            },
            {
              'fase': 'Tahap 3',
              'judul': 'Pleno Penilaian & Hasil Akhir (${_ukkData['status_peserta']})',
              'jadwal': sudahDinilai ? 'Nilai Akhir: ${_ukkData['nilai_akhir']}' : tglSelesai,
              'status': sudahDinilai ? _ukkData['status_peserta'] : 'Menunggu Pleno',
              'is_done': sudahDinilai,
            },
          ];
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
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF4C3EC7))))
          else if (_ukkData.isEmpty)
            Expanded(child: _buildEmptyState())
          else ...[
            _buildHeroCard(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUnitKompetensiList(),
                  _buildTahapanList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium_outlined, size: 54, color: Color(0xFF94A3B8)),
            SizedBox(height: 16),
            Text(
              "Belum Terdaftar UKK",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
            SizedBox(height: 6),
            Text(
              "Data skema dan jadwal Uji Kompetensi Keahlian akan muncul ketika sekolah mendaftarkan akun Anda pada kegiatan UKK.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
            ),
          ],
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
                      "Uji Kompetensi Keahlian (UKK)",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      "Sertifikasi Profesi LSP-P1 & BNSP Nasional",
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

  Widget _buildHeroCard() {
    String skema = _ukkData['skema'] ?? 'Uji Kompetensi Kejuruan';
    String lembaga = _ukkData['lembaga'] ?? 'LSP-P1 SMK';
    String status = _ukkData['status_peserta'] ?? 'Terdaftar';
    String tuk = _ukkData['tempat_uji'] ?? 'Lab Praktik';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C3EC7).withValues(alpha: 0.05),
            blurRadius: 12,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.school_rounded, color: Color(0xFF6366F1), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      skema,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniInfo(Icons.verified_rounded, "Lembaga Penguji", lembaga),
              _buildMiniInfo(Icons.place_rounded, "Tempat Uji (TUK)", tuk),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                Text(
                  value,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155), fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF4C3EC7),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4C3EC7).withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: "Unit Kompetensi (${_unitKompetensi.length} Unit)"),
          const Tab(text: "Alur & Tahapan Uji"),
        ],
      ),
    );
  }

  Widget _buildUnitKompetensiList() {
    if (_unitKompetensi.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.assignment_outlined, size: 40, color: Color(0xFF94A3B8)),
              SizedBox(height: 12),
              Text(
                "Belum Ada Unit Penilaian",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              SizedBox(height: 4),
              Text(
                "Daftar unit kompetensi dan hasil asesmen UKK belum tersedia.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _unitKompetensi.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        var item = _unitKompetensi[index];
        bool isKomp = item['status'] == 'Kompeten';
        bool sudahDinilai = item['sudah_dinilai'] == true;

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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isKomp ? const Color(0xFFDCFCE7) : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isKomp ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                  size: 20,
                  color: isKomp ? const Color(0xFF16A34A) : const Color(0xFF4C3EC7),
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
                          item['kode'],
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isKomp
                                ? const Color(0xFFDCFCE7)
                                : (sudahDinilai ? const Color(0xFFFEE2E2) : const Color(0xFFFFFBEB)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['status'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isKomp
                                  ? const Color(0xFF16A34A)
                                  : (sudahDinilai ? const Color(0xFFDC2626) : const Color(0xFFD97706)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['judul'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Metode Asesmen: ${item['jenis']}",
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTahapanList() {
    if (_tahapanUji.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.timeline_rounded, size: 40, color: Color(0xFF94A3B8)),
              SizedBox(height: 12),
              Text(
                "Belum Ada Alur Tahapan",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              SizedBox(height: 4),
              Text(
                "Tahapan pelaksanaan UKK belum dijadwalkan.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _tahapanUji.length,
      itemBuilder: (context, index) {
        var item = _tahapanUji[index];
        bool isDone = item['is_done'] == true;
        bool isLast = index == _tahapanUji.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDone ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isDone ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: isDone ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 52,
                    color: isDone ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item['fase'],
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF4C3EC7)),
                        ),
                        const Spacer(),
                        Text(
                          item['status'],
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDone ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['judul'],
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Jadwal: ${item['jadwal']}",
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
