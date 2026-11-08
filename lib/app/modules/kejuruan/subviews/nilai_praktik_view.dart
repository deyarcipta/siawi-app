import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';

class NilaiPraktikView extends StatefulWidget {
  final String? idSiswa;
  const NilaiPraktikView({this.idSiswa, super.key});

  @override
  State<NilaiPraktikView> createState() => _NilaiPraktikViewState();
}

class _NilaiPraktikViewState extends State<NilaiPraktikView> {
  bool _isLoading = true;
  String? _effectiveIdSiswa;
  String _selectedFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Kompeten', 'Perlu Remedial'];

  String _namaKelas = 'Kelas Siswa';

  List<Map<String, dynamic>> _allNilai = [];
  double _rataRata = 0.0;
  int _totalKompeten = 0;
  int _totalRemedial = 0;

  @override
  void initState() {
    super.initState();
    _effectiveIdSiswa = widget.idSiswa;
    _loadData();
  }

  String _getGradeString(double score) {
    if (score >= 93) return "Grade A";
    if (score >= 88) return "Grade A-";
    if (score >= 83) return "Grade B+";
    if (score >= 78) return "Grade B";
    if (score >= 75) return "Grade B-";
    return "Grade C";
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _effectiveIdSiswa ??= prefs.getString('idSiswa');
    final savedKelas = prefs.getString('namaKelas') ?? prefs.getString('kelas');
    if (savedKelas != null && savedKelas.isNotEmpty) {
      _namaKelas = savedKelas;
    }

    if (_effectiveIdSiswa != null) {
      try {
        final res = await ApiService.get(
          '/kejuruan/nilai/$_effectiveIdSiswa',
          forceRefresh: true,
          silent: true,
        );
        if (res != null && res['success'] == true && res['data'] is List) {
          final List rawList = res['data'];
          _allNilai = rawList.map((e) {
            final m = Map<String, dynamic>.from(e);
            final penilaian = m['penilaian'] is Map ? m['penilaian'] : {};
            final modul = penilaian['modul'] is Map ? penilaian['modul'] : {};
            final komp = penilaian['kompetensi'] is Map ? penilaian['kompetensi'] : {};
            final guru = penilaian['guru'] is Map ? penilaian['guru'] : {};
            final double kkm = double.tryParse(
                    (m['kkm'] ?? penilaian['kkm_saat_penilaian'] ?? penilaian['kkm'] ?? '75').toString()) ??
                75.0;
            final double nilaiAkhir = double.tryParse(m['nilai_akhir']?.toString() ?? m['nilai']?.toString() ?? '0') ?? 0.0;
            final double nilaiAwal = double.tryParse(m['nilai_awal']?.toString() ?? '$nilaiAkhir') ?? nilaiAkhir;
            final double? nilaiRemedial = m['nilai_remedial'] != null
                ? double.tryParse(m['nilai_remedial'].toString())
                : null;
            final bool perluRemedial = m['perlu_remedial'] == true ||
                m['status_kompetensi'] == 'belum_kompeten' ||
                nilaiAkhir < kkm;
            return {
              'judul': modul['judul'] ?? m['judul'] ?? komp['nama_kompetensi'] ?? 'Praktik Kejuruan',
              'modul': modul['kode_modul'] ?? m['kode_modul'] ?? 'Modul Praktik',
              'nilai': nilaiAkhir,
              'nilai_awal': nilaiAwal,
              'nilai_remedial': nilaiRemedial,
              'kkm': kkm.round(),
              'tanggal': m['tanggal_formatted'] ??
                  m['tanggal'] ??
                  (penilaian['tanggal_penilaian'] != null && penilaian['tanggal_penilaian'].toString().length >= 10
                      ? penilaian['tanggal_penilaian'].toString().substring(0, 10)
                      : '-'),
              'guru': guru['nama_guru'] ?? '-',
              'catatan': m['catatan_guru'] ?? m['catatan'] ?? 'Tidak ada catatan khusus dari instruktur.',
              'aspek': m['detail_aspek'] is Map ? m['detail_aspek'] : {},
              'is_remedial': perluRemedial,
              'sudah_remedial': m['is_remedial'] == true,
            };
          }).toList();
        }
      } catch (_) {}
    }

    // Hitung rata-rata dan total
    double totalNilai = 0;
    int komCount = 0;
    int remCount = 0;
    for (var n in _allNilai) {
      double val = double.tryParse(n['nilai'].toString()) ?? 0;
      totalNilai += val;
      if (n['is_remedial'] != true) {
        komCount++;
      } else {
        remCount++;
      }
    }
    _rataRata = _allNilai.isNotEmpty ? (totalNilai / _allNilai.length) : 0;
    _totalKompeten = komCount;
    _totalRemedial = remCount;

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredNilai {
    return _allNilai.where((item) {
      bool isRem = item['is_remedial'] == true;

      if (_selectedFilter.startsWith('Kompeten')) return !isRem;
      if (_selectedFilter.startsWith('Perlu Remedial')) return isRem;
      return true;
    }).toList();
  }

  void _showDetailNilai(Map<String, dynamic> item) {
    String judul = (item['judul'] ?? 'Penilaian Praktik').toString();
    double nilai = double.tryParse(item['nilai'].toString()) ?? 0;
    int kkm = int.tryParse(item['kkm']?.toString() ?? '75') ?? 75;
    bool isRem = item['is_remedial'] == true || nilai < kkm;
    String guru = (item['guru'] ?? '-').toString();
    String catatan = (item['catatan'] ?? '-').toString();
    String tanggal = (item['tanggal'] ?? '-').toString();
    Map<String, dynamic> aspek = item['aspek'] is Map ? Map<String, dynamic>.from(item['aspek']) : {};

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isRem ? const Color(0xFFFFF7ED) : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isRem ? const Color(0xFFFED7AA) : const Color(0xFF86EFAC)),
                    ),
                    child: Text(
                      isRem ? "PERLU REMEDIAL" : "KOMPETEN",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isRem ? const Color(0xFFC2410C) : const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                judul,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Tanggal Uji: $tanggal • Guru: $guru",
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              // Nilai Besar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isRem ? const Color(0xFFFFF1F2) : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isRem ? const Color(0xFFE11D48) : const Color(0xFF4C3EC7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        nilai.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRem ? "Nilai di Bawah KKM ($kkm)" : "Memenuhi Standar KKM ($kkm)",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isRem ? const Color(0xFFBE123C) : const Color(0xFF3730A3),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isRem ? "Silakan hubungi guru untuk jadwal pengayaan / remedial." : "Predikat Sangat Memuaskan (A). Pertahankan prestasi!",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isRem ? const Color(0xFF9F1239) : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (aspek.isNotEmpty) ...[
                const Text(
                  "Rincian Komponen Penilaian",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                for (var entry in aspek.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${entry.value} / 100",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Catatan Evaluasi Instruktur:",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      catatan,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B), height: 1.3),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          _buildSummaryStats(),
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4C3EC7)))
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: const Color(0xFF4C3EC7),
                    child: _filteredNilai.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            itemCount: _filteredNilai.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildNilaiCard(_filteredNilai[index]);
                            },
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
                      "Nilai & Rapor Praktik",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      "Rekap Capaian Kompetensi & Remedial Siswa",
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

  Widget _buildSummaryStats() {
    final int totalTugas = _allNilai.length;
    final int percentTuntas = totalTugas > 0 ? ((_totalKompeten / totalTugas) * 100).floor() : 0;
    final String grade = totalTugas > 0 ? _getGradeString(_rataRata) : "Belum Ada";
    final String statusHeroBadge = totalTugas == 0
        ? "Belum Dinilai"
        : (_totalRemedial == 0 ? "Kompeten" : "$_totalRemedial Remedial");
    final bool isAllKompeten = totalTugas > 0 && _totalRemedial == 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
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
          // Row 1: Badges (Portofolio Kejuruan, Kelas, Kompeten)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Portofolio Kejuruan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _namaKelas,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAllKompeten ? Icons.verified_rounded : Icons.info_outline_rounded,
                      color: isAllKompeten ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
                      size: 15,
                    ),
                    const SizedBox(width: 4.5),
                    Text(
                      statusHeroBadge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Row 2: Rata-Rata Nilai Praktik, Grade & Circular Progress
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rata-Rata Nilai Praktik",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _rataRata.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            grade,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Akumulasi Asesmen Internal Sekolah",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Circular progress indicator (e.g. 92% Tuntas)
              SizedBox(
                width: 74,
                height: 74,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 74,
                      height: 74,
                      child: CircularProgressIndicator(
                        value: percentTuntas / 100,
                        strokeWidth: 6.5,
                        strokeCap: StrokeCap.round,
                        backgroundColor: const Color(0xFF38BDF8).withValues(alpha: 0.28),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$percentTuntas%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const Text(
                          "Tuntas",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Row 3: Bottom Stat Box (TOTAL TUGAS, TERVALIDASI, REMEDIAL)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomStatItem("TOTAL TUGAS", "$totalTugas Modul", Colors.white),
                Container(
                  width: 1,
                  height: 26,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                _buildBottomStatItem("TERVALIDASI", "$_totalKompeten Selesai", const Color(0xFF4ADE80)),
                Container(
                  width: 1,
                  height: 26,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                _buildBottomStatItem("REMEDIAL", "$_totalRemedial Aktif", const Color(0xFFFBBF24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStatItem(String title, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Colors.white60,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _filters.map((fil) {
            final isSelected = _selectedFilter == fil;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedFilter = fil),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4C3EC7) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4C3EC7) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    fil,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNilaiCard(Map<String, dynamic> item) {
    String judul = (item['judul'] ?? (item['penilaian'] is Map ? item['penilaian']['judul_penilaian'] : null) ?? 'Penilaian Praktik').toString();
    String modul = (item['modul'] ?? (item['penilaian'] is Map && item['penilaian']['modul'] is Map ? item['penilaian']['modul']['judul_modul'] : null) ?? 'Modul Praktik').toString();
    double nilai = double.tryParse(item['nilai'].toString()) ?? 0;
    double kkm = double.tryParse((item['kkm'] ?? '75').toString()) ?? 75;
    bool isRem = item['is_remedial'] == true || nilai < kkm;
    String tanggal = item['tanggal'] ?? '-';
    String catatan = item['catatan'] ?? '-';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRem ? const Color(0xFFFED7AA) : const Color(0xFFE2E8F0),
          width: isRem ? 1.3 : 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailNilai(item),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lingkaran Skor Nilai
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isRem ? const Color(0xFFFFF7ED) : const Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isRem ? const Color(0xFFFDBA74) : const Color(0xFF86EFAC),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          nilai.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isRem ? const Color(0xFFC2410C) : const Color(0xFF16A34A),
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
                                  color: isRem ? const Color(0xFFFFF1F2) : const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isRem ? "REMEDIAL" : "KOMPETEN",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isRem ? const Color(0xFFE11D48) : const Color(0xFF4C3EC7),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                tanggal,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            judul,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            modul,
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.comment_outlined, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          catatan,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_turned_in_rounded, size: 48, color: Color(0xFF16A34A)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Tidak Ada Data Nilai",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Belum ada catatan nilai penilaian praktik untuk kategori ini.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
