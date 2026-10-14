import 'package:flutter/material.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/modules/informasi/views/detail_informasi.dart';
import 'package:siawi_app/app/modules/informasi/widget/informasi.dart';

class InformasiView extends StatefulWidget {
  final VoidCallback signOut;
  const InformasiView(this.signOut, {super.key});

  @override
  State<InformasiView> createState() => _InformasiViewState();
}

class _InformasiViewState extends State<InformasiView> {
  final TextEditingController _searchController = TextEditingController();
  List<Informasi> _allInformasiList = [];
  List<Informasi> _filteredInformasiList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInformasi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInformasi() async {
    try {
      final responseData = await ApiService.get('/informasi');
      if (responseData != null && responseData['data'] != null && mounted) {
        final List<dynamic> informasiData = responseData['data'];
        final List<Informasi> loadedList =
            informasiData.map((item) => Informasi.fromJson(item)).toList();

        setState(() {
          _allInformasiList = loadedList;
          _filteredInformasiList = loadedList;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    final cleanQuery = query.trim().toLowerCase();
    setState(() {
      if (cleanQuery.isEmpty) {
        _filteredInformasiList = List.from(_allInformasiList);
      } else {
        _filteredInformasiList = _allInformasiList.where((item) {
          final matchesTitle =
              item.informasi.toLowerCase().contains(cleanQuery);
          final matchesDesc =
              item.ketInformasi.toLowerCase().contains(cleanQuery);
          final matchesDay = item.hari.toLowerCase().contains(cleanQuery);
          return matchesTitle || matchesDesc || matchesDay;
        }).toList();
      }
    });
  }

  void _openPDFViewer(String fileURL, String title) {
    if (fileURL.isEmpty || fileURL == 'null') return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailInformasi(
          fileURL: fileURL,
          title: title,
        ),
      ),
    );
  }

  Color _getAccentColor(int index) {
    const colors = [
      Color(0xFF4C3EC7), // Indigo SIAWI
      Color(0xFF0284C7), // Sky Blue
      Color(0xFF059669), // Emerald Green
      Color(0xFF7C3AED), // Violet
      Color(0xFFD97706), // Amber
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header Lengkung Ungu SIAWI & Search Bar
          _buildHeader(),

          // Konten Daftar Informasi
          Expanded(
            child: _isLoading
                ? _buildLoadingSkeleton()
                : RefreshIndicator(
                    onRefresh: _fetchInformasi,
                    color: const Color(0xFF4C3EC7),
                    backgroundColor: Colors.white,
                    child: _filteredInformasiList.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                            itemCount: _filteredInformasiList.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final item = _filteredInformasiList[index];
                              return _buildInformasiCard(item, index);
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
                              'Pusat Informasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              'Pengumuman & Surat Edaran Sekolah',
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

                  // Modern Search Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari pengumuman atau surat edaran...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF4C3EC7),
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF64748B),
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
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

  Widget _buildInformasiCard(Informasi item, int index) {
    final hasPdf = item.file.isNotEmpty && item.file != 'null';
    final accentColor = _getAccentColor(index);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Garis Aksen Sisi Kiri
              Container(
                width: 5,
                color: accentColor,
              ),

              // Konten Kartu
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris Atas: Tanggal Pelaksanaan & Badge Tipe
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Badge Pelaksanaan / Hari
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
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
                                  Icons.calendar_today_rounded,
                                  size: 12,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  item.hari.isNotEmpty
                                      ? '${item.hari}, ${item.tanggalAwal}'
                                      : (item.tanggalAwal.isNotEmpty
                                          ? item.tanggalAwal
                                          : 'Pengumuman Resmi'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Badge Jenis
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: hasPdf
                                  ? const Color(0xFFEEF2FF)
                                  : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hasPdf
                                      ? Icons.description_rounded
                                      : Icons.campaign_rounded,
                                  size: 12,
                                  color: hasPdf
                                      ? const Color(0xFF4C3EC7)
                                      : const Color(0xFF059669),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  hasPdf ? 'Surat Edaran' : 'Informasi',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: hasPdf
                                        ? const Color(0xFF4C3EC7)
                                        : const Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Judul Informasi
                      Text(
                        item.informasi.isNotEmpty
                            ? item.informasi
                            : 'Pemberitahuan Sekolah',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),

                      // Keterangan Isi Informasi (Jika ada)
                      if (item.ketInformasi.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.ketInformasi,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.45,
                          ),
                        ),
                      ],

                      // Tombol Lihat Lampiran PDF
                      if (hasPdf) ...[
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () =>
                              _openPDFViewer(item.file, item.informasi),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFC7D2FE),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf_rounded,
                                  size: 16,
                                  color: Color(0xFF4C3EC7),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Lihat Surat Edaran PDF',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4C3EC7),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 11,
                                  color: Color(0xFF4C3EC7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchController.text.isNotEmpty;

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
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSearching
                      ? Icons.search_off_rounded
                      : Icons.campaign_rounded,
                  size: 48,
                  color: const Color(0xFF4C3EC7),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isSearching
                    ? 'Informasi Tidak Ditemukan'
                    : 'Belum Ada Informasi',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                isSearching
                    ? 'Tidak ada pengumuman yang cocok dengan kata kunci "${_searchController.text}". Coba cari kata kunci lain.'
                    : 'Belum ada pengumuman atau surat edaran terbaru yang diterbitkan oleh pihak sekolah.',
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

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 120,
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
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 180,
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
}
