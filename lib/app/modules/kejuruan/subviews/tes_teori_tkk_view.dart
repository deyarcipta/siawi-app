import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';

class TesTeoriTkkView extends StatefulWidget {
  final String? idSiswa;
  const TesTeoriTkkView({this.idSiswa, super.key});

  @override
  State<TesTeoriTkkView> createState() => _TesTeoriTkkViewState();
}

class _TesTeoriTkkViewState extends State<TesTeoriTkkView> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _effectiveIdSiswa;
  late TabController _tabController;

  List<Map<String, dynamic>> _tkkList = [];
  List<Map<String, dynamic>> _tesTeoriList = [];

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
          '/kejuruan/tkk/$_effectiveIdSiswa',
          forceRefresh: true,
          silent: true,
        );
        if (res != null && res['success'] == true) {
          if (res['data'] is List) {
            final List rawList = res['data'];
            _tkkList = rawList.map((e) {
              final m = Map<String, dynamic>.from(e);
              final jenis = m['jenis_tkk'] is Map ? m['jenis_tkk'] : {};
              final pemberi = m['pemberi'] is Map ? m['pemberi'] : {};
              return {
                'nama': m['nama_tkk'] ?? jenis['nama_tkk'] ?? 'Tanda Kecakapan Kejuruan',
                'tingkat': m['tingkat'] ?? jenis['tingkat'] ?? 'Tingkat Dasar',
                'sk': m['nomor_piagam'] ?? m['nomor_sk'] ?? m['nomor_sertifikat'] ?? '-',
                'tanggal': m['tanggal_perolehan'] != null && m['tanggal_perolehan'].toString().isNotEmpty
                    ? m['tanggal_perolehan'].toString()
                    : '-',
                'status_raw': m['status_raw'] ?? m['status'] ?? 'proses',
                'status': m['status'] ?? 'Dalam Proses',
                'asesor': m['asesor'] ?? pemberi['nama_guru'] ?? 'Tim Penguji Kejuruan',
                'syarat_lulus': m['syarat_lulus'] ?? 0,
                'syarat_total': m['syarat_total'] ?? 0,
              };
            }).toList();
          }

          if (res['capaian'] is List) {
            final List rawCapaian = res['capaian'];
            _tesTeoriList = rawCapaian.map((e) {
              final c = Map<String, dynamic>.from(e);
              return {
                'judul': c['judul'] ?? 'Capaian Kompetensi',
                'skor': int.tryParse((c['skor'] ?? '0').toString()) ?? 0,
                'kkm': int.tryParse((c['kkm'] ?? '75').toString()) ?? 75,
                'predikat': c['status'] ?? 'Kompeten',
                'soal': '${c['kode_kompetensi'] ?? '-'} (${c['jenis'] ?? 'Praktik'})',
                'tanggal': c['tanggal'] ?? '-',
              };
            }).toList();
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
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4C3EC7)))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTkkList(),
                      _buildTesTeoriList(),
                    ],
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
                      "Tes Teori & TKK",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      "Tanda Kecakapan Kejuruan & Ujian Teori",
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
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
        tabs: const [
          Tab(text: "Tanda Kecakapan (TKK)"),
          Tab(text: "Capaian Kompetensi"),
        ],
      ),
    );
  }

  Widget _buildTkkList() {
    if (_tkkList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.workspace_premium_outlined, size: 48, color: Color(0xFF94A3B8)),
              SizedBox(height: 12),
              Text(
                "Belum Ada Data TKK",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              SizedBox(height: 4),
              Text(
                "Tanda Kecakapan Kejuruan akan tercatat setelah siswa menyelesaikan uji klaster keahlian.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _tkkList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        var item = _tkkList[index];
        final String statusRaw = (item['status_raw'] ?? '').toString();
        final bool isSah = statusRaw == 'diberikan';
        final bool isLayak = statusRaw == 'memenuhi_syarat';
        final int syaratTotal = int.tryParse((item['syarat_total'] ?? '0').toString()) ?? 0;
        final int syaratLulus = int.tryParse((item['syarat_lulus'] ?? '0').toString()) ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: Color(0xFF9333EA), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSah
                                ? const Color(0xFFDCFCE7)
                                : (isLayak ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['status'] ?? 'Dalam Proses',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isSah
                                  ? const Color(0xFF16A34A)
                                  : (isLayak ? const Color(0xFF0284C7) : const Color(0xFFD97706)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['tingkat'] ?? 'TKK',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF6B21A8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item['nama'] ?? '-',
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.25),
              ),
              const SizedBox(height: 8),
              Text(
                "Nomor Piagam: ${item['sk'] ?? '-'}",
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              Text(
                "Tanggal Pengesahan: ${item['tanggal'] ?? '-'}",
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
              if (syaratTotal > 0) ...[
                const SizedBox(height: 4),
                Text(
                  "Syarat Kompetensi: $syaratLulus / $syaratTotal Unit Lulus",
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF4C3EC7)),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF4C3EC7)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Asesor: ${item['asesor'] ?? '-'}",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
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

  Widget _buildTesTeoriList() {
    if (_tesTeoriList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz_outlined, size: 48, color: Color(0xFF94A3B8)),
              SizedBox(height: 12),
              Text(
                "Belum Ada Ujian Teori",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              SizedBox(height: 4),
              Text(
                "Rekap hasil ujian teori kejuruan akan ditampilkan setelah Anda mengikuti sesi ujian.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _tesTeoriList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        var item = _tesTeoriList[index];
        int skor = item['skor'] ?? 0;
        bool isPass = skor >= (item['kkm'] ?? 75);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPass ? const Color(0xFFDCFCE7) : const Color(0xFFFFF7ED),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "$skor",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isPass ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['predikat'] ?? 'Lulus',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF4C3EC7)),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item['tanggal'] ?? '-',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['judul'] ?? 'Tes Teori',
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.25),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Format: ${item['soal']} • KKM: ${item['kkm']}",
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
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
}
