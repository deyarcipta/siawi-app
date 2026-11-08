import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/utils/file_downloader.dart';

class PeminjamanAlatView extends StatefulWidget {
  final String? idSiswa;
  const PeminjamanAlatView({this.idSiswa, super.key});

  @override
  State<PeminjamanAlatView> createState() => _PeminjamanAlatViewState();
}

class _PeminjamanAlatViewState extends State<PeminjamanAlatView> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _effectiveIdSiswa;
  late TabController _tabController;

  List<Map<String, dynamic>> _sedangDipinjam = [];
  List<Map<String, dynamic>> _riwayatPinjam = [];
  List<Map<String, dynamic>> _asetTersedia = [];
  String _namaJurusan = 'Kejuruan';
  String _kodeJurusan = 'KEJURUAN';

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
          '/kejuruan/peminjaman/$_effectiveIdSiswa',
          forceRefresh: true,
          silent: true,
        );
        if (res != null && res['success'] == true && res['data'] is Map) {
          final data = res['data'];
          if (data['sedang_dipinjam'] is List) {
            _sedangDipinjam = List<Map<String, dynamic>>.from(data['sedang_dipinjam']);
          } else if (data['aktif'] is List) {
            _sedangDipinjam = List<Map<String, dynamic>>.from(data['aktif']);
          }
          if (data['riwayat'] is List) {
            _riwayatPinjam = List<Map<String, dynamic>>.from(data['riwayat']);
          }
          if (data['aset_tersedia'] is List) {
            _asetTersedia = List<Map<String, dynamic>>.from(data['aset_tersedia']);
          }
          if (data['nama_jurusan'] != null) {
            _namaJurusan = data['nama_jurusan'].toString();
          }
          if (data['kode_jurusan'] != null) {
            _kodeJurusan = data['kode_jurusan'].toString();
          }
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showFormPengajuan() {
    if (_asetTersedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Belum ada stok alat laboratorium yang tersedia untuk dipinjam saat ini."),
          backgroundColor: Color(0xFFD97706),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    int selectedAsetId = int.tryParse(_asetTersedia.first['id_aset'].toString()) ?? 0;
    final formJumlah = TextEditingController(text: '1');
    final formKeperluan = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
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
                          const Text(
                            "Formulir Pinjam Alat Lab",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetCtx),
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text("Pilih Alat / Perangkat Lab", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        initialValue: selectedAsetId,
                        isExpanded: true,
                        items: _asetTersedia.map((a) {
                          final int id = int.tryParse(a['id_aset'].toString()) ?? 0;
                          final String label = "${a['nama_aset']} (${a['lab']} • Sisa ${a['stok_tersedia']} ${a['satuan']})";
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(
                              label,
                              style: const TextStyle(fontSize: 12.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedAsetId = val);
                          }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text("Jumlah Pinjam", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: formJumlah,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Masukkan jumlah unit",
                          hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text("Keperluan / Modul Praktik", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: formKeperluan,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "Tuliskan modul atau tugas praktik yang sedang dikerjakan...",
                          hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final int jml = int.tryParse(formJumlah.text.trim()) ?? 0;
                                  final String keperluan = formKeperluan.text.trim();
                                  if (jml < 1 || keperluan.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Jumlah pinjam dan keperluan wajib diisi."),
                                        backgroundColor: Color(0xFFDC2626),
                                      ),
                                    );
                                    return;
                                  }

                                  setModalState(() => isSubmitting = true);
                                  try {
                                    final res = await ApiService.postJson(
                                      '/kejuruan/peminjaman/$_effectiveIdSiswa',
                                      {
                                        'id_aset': selectedAsetId,
                                        'jumlah': jml,
                                        'keperluan': keperluan,
                                      },
                                    );
                                    if (!mounted) return;
                                    Navigator.pop(sheetCtx);
                                    ScaffoldMessenger.of(this.context).showSnackBar(
                                      SnackBar(
                                        content: Text(res['message'] ?? "Peminjaman alat berhasil dicatat!"),
                                        backgroundColor: const Color(0xFF16A34A),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    _loadData();
                                  } catch (_) {
                                    setModalState(() => isSubmitting = false);
                                  }
                                },
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.send_rounded, size: 18),
                          label: Text(isSubmitting ? "Memproses..." : "Kirim Pengajuan Pinjam"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C3EC7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFormPengajuan,
        backgroundColor: const Color(0xFF4C3EC7),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Pinjam Alat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
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
                      _buildAktifList(),
                      _buildRiwayatList(),
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
                      "Peminjaman Alat Praktik",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      "Inventaris Alat, Perangkat & Toolset Bengkel",
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
        tabs: [
          Tab(text: "Sedang Dipinjam (${_sedangDipinjam.length})"),
          Tab(text: "Riwayat (${_riwayatPinjam.length})"),
        ],
      ),
    );
  }

  Widget _buildAktifList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 85),
      physics: const BouncingScrollPhysics(),
      children: [
        if (_sedangDipinjam.isEmpty) ...[
          _buildEmptyAktifCard(),
          const SizedBox(height: 16),
        ] else ...[
          ..._sedangDipinjam.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAktifItemCard(item),
              )),
          const SizedBox(height: 6),
        ],
        _buildTataTertibCard(),
      ],
    );
  }

  Widget _buildEmptyAktifCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 38,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Tidak Ada Pinjaman Aktif",
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Semua alat dan modul lab telah dikembalikan dengan lengkap.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAktifItemCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF93C5FD), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "DIPINJAM",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.alarm_rounded, size: 12, color: Color(0xFFB45309)),
                    const SizedBox(width: 4),
                    Text(
                      "Batas: ${item['batas_kembali']}",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item['nama_alat'] ?? item['nama'] ?? '-',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.25),
          ),
          const SizedBox(height: 6),
          Text("Kode Aset: ${item['kode_aset'] ?? item['sn'] ?? '-'} • Tiket: ${item['kode'] ?? item['sn'] ?? '-'}",
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          Text("Lokasi: ${item['lab'] ?? item['lokasi'] ?? '-'} • Pinjam: ${item['jam_pinjam'] ?? item['tgl_pinjam'] ?? '-'}",
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
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
                const Icon(Icons.person_pin_rounded, size: 14, color: Color(0xFF4C3EC7)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Petugas Lab: ${item['petugas']}",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 85),
      physics: const BouncingScrollPhysics(),
      children: [
        ..._riwayatPinjam.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRiwayatItemCard(item),
            )),
        const SizedBox(height: 6),
        _buildTataTertibCard(),
      ],
    );
  }

  Widget _buildRiwayatItemCard(Map<String, dynamic> item) {
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
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(item['status'] ?? 'Selesai',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                    ),
                    const Spacer(),
                    Text(item['jam_kembali'] ?? item['tgl_kembali'] ?? '-', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item['nama_alat'] ?? item['nama'] ?? '-',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text("Lokasi: ${item['lab'] ?? item['lokasi'] ?? '-'} • Kondisi: ${item['kondisi'] ?? 'Baik'}",
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: TATA TERTIB & SANKSI ALAT BENGKEL
  // ==========================================
  Widget _buildTataTertibCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C3EC7).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar Palu / Hukum & Judul
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF3730A3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.gavel_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tata Tertib & Sanksi Alat Bengkel",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "SOP Laboratorium $_namaJurusan SMK Wisata Indonesia",
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Item 1: Pengecekan Komponen Awal
          _buildTataTertibItem(
            icon: Icons.verified_user_outlined,
            iconColor: const Color(0xFF4338CA),
            title: "Pengecekan Komponen Awal:",
            description:
                "Wajib periksa kelengkapan baut, kabel power, adaptor, dan kartu garansi mini sebelum membawa alat keluar meja kerja.",
          ),

          // Item 2: Pelaporan Cacat & Kerusakan
          _buildTataTertibItem(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFF0284C7),
            title: "Pelaporan Cacat & Kerusakan:",
            description:
                "Jika menemukan indikator error atau kabel terkelupas, laporkan kepada Toolman selambat-lambatnya 10 menit setelah serah terima.",
          ),

          // Item 3: Sanksi Penggantian
          _buildTataTertibItem(
            icon: Icons.assignment_late_outlined,
            iconColor: const Color(0xFF4338CA),
            title: "Sanksi Penggantian:",
            description:
                "Kerusakan akibat kelalaian operasional (cth: konektor patah, konslet karena polaritas terbalik) wajib diganti secara kelompok/mandiri dalam 7 hari kerja.",
          ),

          const SizedBox(height: 6),

          // Footer: Unit Kerja & Unduh Dokumen SOP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Unit Kerja $_kodeJurusan • SMK Wisata Indonesia",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  final safeKode = _kodeJurusan.trim().isNotEmpty
                      ? _kodeJurusan.trim().replaceAll(RegExp(r'\s+'), '_')
                      : 'KEJURUAN';
                  FileDownloader.downloadFile(
                    context: context,
                    url: 'https://siawi.smkwisataindonesia.sch.id/uploads/sop/SOP_Tata_Tertib_Alat_Bengkel_$safeKode.pdf',
                    defaultFileName: 'SOP_Tata_Tertib_Alat_Bengkel_$safeKode.pdf',
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Unduh Dokumen SOP",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4338CA),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.download_rounded,
                        size: 16,
                        color: Color(0xFF4338CA),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTataTertibItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
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
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF475569),
                  height: 1.45,
                ),
                children: [
                  TextSpan(
                    text: "$title\n",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: Color(0xFF0F172A),
                      height: 1.35,
                    ),
                  ),
                  TextSpan(
                    text: description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
