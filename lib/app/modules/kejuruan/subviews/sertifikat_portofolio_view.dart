import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/utils/file_downloader.dart';

class SertifikatPortofolioView extends StatefulWidget {
  final String? idSiswa;
  const SertifikatPortofolioView({this.idSiswa, super.key});

  @override
  State<SertifikatPortofolioView> createState() => _SertifikatPortofolioViewState();
}

class _SertifikatPortofolioViewState extends State<SertifikatPortofolioView> {
  bool _isLoading = true;
  String? _effectiveIdSiswa;
  String _selectedCategory = 'Semua';
  String _namaJurusan = 'Kompetensi Keahlian';

  final List<String> _categories = ['Semua', 'Sertifikat', 'Proyek & Karya', 'Prestasi & Lomba'];

  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _effectiveIdSiswa = widget.idSiswa;
    _loadData();
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
          '/kejuruan/portofolio/$_effectiveIdSiswa',
          forceRefresh: true,
          silent: true,
        );
        if (res != null && res['success'] == true && res['data'] is List) {
          if (res['meta'] is Map && res['meta']['nama_jurusan'] != null) {
            _namaJurusan = res['meta']['nama_jurusan'].toString();
          }
          final List rawList = res['data'];
          _items = rawList.map((e) {
            final m = Map<String, dynamic>.from(e);
            final katKode = (m['kategori_kode'] ?? m['kategori'] ?? 'sertifikat').toString();
            String katLabel = (m['kategori_label'] ?? '').toString();
            if (katLabel.isEmpty) {
              if (katKode == 'proyek_karya') {
                katLabel = 'Proyek & Karya';
              } else if (katKode == 'prestasi_lomba') {
                katLabel = 'Prestasi & Lomba';
              } else {
                katLabel = 'Sertifikat';
              }
            }

            final statusVerif = (m['status_verifikasi'] ?? 'menunggu').toString();
            final statusLabel = (m['status_label'] ??
                    (statusVerif == 'disetujui'
                        ? 'Terverifikasi'
                        : (statusVerif == 'ditolak' ? 'Ditolak' : 'Menunggu Verifikasi')))
                .toString();

            return {
              'judul': m['judul'] ?? m['nama_kegiatan'] ?? 'Portofolio Siswa',
              'kategori_kode': katKode,
              'kategori': katLabel,
              'penerbit': m['penyelenggara'] ?? m['instansi'] ?? 'SMK Wisata Indonesia',
              'nomor': m['nomor_sertifikat'] ?? m['kode'] ?? '-',
              'tanggal': m['tanggal_formatted'] ??
                  (m['tanggal_kegiatan'] != null && m['tanggal_kegiatan'].toString().length >= 10
                      ? m['tanggal_kegiatan'].toString().substring(0, 10)
                      : '-'),
              'status_verifikasi': statusVerif,
              'status': statusLabel,
              'verifikator': m['verifikator_nama'] ?? (m['verifikator'] is Map ? m['verifikator']['nama_guru'] : '-'),
              'catatan_verifikasi': m['catatan_verifikasi'] ?? '-',
              'icon': katKode == 'proyek_karya'
                  ? Icons.inventory_2_rounded
                  : (katKode == 'prestasi_lomba' ? Icons.emoji_events_rounded : Icons.workspace_premium_rounded),
              'color': const Color(0xFF4C3EC7),
              'deskripsi': m['deskripsi'] ?? '-',
              'file_url': m['file_url'] ?? m['file_dokumen'] ?? m['tautan_karya'],
              'tautan_karya': m['tautan_karya'],
            };
          }).toList();
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  int get _countSertifikat {
    return _items.where((e) {
      final kode = (e['kategori_kode'] ?? '').toString().toLowerCase();
      return kode == 'sertifikat' || kode == 'prestasi_lomba';
    }).length;
  }

  int get _countProyek {
    return _items.where((e) {
      final kode = (e['kategori_kode'] ?? '').toString().toLowerCase();
      return kode == 'proyek_karya';
    }).length;
  }

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedCategory == 'Semua') return _items;
    return _items.where((e) => (e['kategori'] ?? '').toString().toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  void _showDetail(Map<String, dynamic> item) {
    final String statusVerif = (item['status_verifikasi'] ?? 'menunggu').toString();
    final bool isApproved = statusVerif == 'disetujui';
    final bool isRejected = statusVerif == 'ditolak';
    final String fileUrl = (item['file_url'] ?? '').toString().trim();

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
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? const Color(0xFFDCFCE7)
                          : (isRejected ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isApproved
                            ? const Color(0xFF86EFAC)
                            : (isRejected ? const Color(0xFFFCA5A5) : const Color(0xFFFDE68A)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isApproved
                              ? Icons.verified_rounded
                              : (isRejected ? Icons.cancel_rounded : Icons.schedule_rounded),
                          size: 13,
                          color: isApproved
                              ? const Color(0xFF16A34A)
                              : (isRejected ? const Color(0xFFDC2626) : const Color(0xFFD97706)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (item['status'] ?? 'Menunggu Verifikasi').toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: isApproved
                                ? const Color(0xFF16A34A)
                                : (isRejected ? const Color(0xFFDC2626) : const Color(0xFFD97706)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item['judul'] ?? 'Portofolio Siswa',
                style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.3),
              ),
              const SizedBox(height: 14),
              _buildInfoRow(Icons.business_rounded, "Penyelenggara / Instansi", item['penerbit'] ?? '-'),
              const SizedBox(height: 10),
              _buildInfoRow(Icons.pin_rounded, "Kompetensi / Referensi", item['nomor'] ?? '-'),
              const SizedBox(height: 10),
              _buildInfoRow(Icons.calendar_today_rounded, "Tanggal Kegiatan", item['tanggal'] ?? '-'),
              const SizedBox(height: 10),
              _buildInfoRow(Icons.description_outlined, "Deskripsi Karya / Sertifikat", item['deskripsi'] ?? '-'),
              if (item['verifikator'] != null && item['verifikator'] != '-') ...[
                const SizedBox(height: 10),
                _buildInfoRow(Icons.person_pin_rounded, "Diverifikasi Oleh", item['verifikator']),
              ],
              if (fileUrl.isNotEmpty) ...[
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      String effectiveUrl = fileUrl;
                      if (!effectiveUrl.startsWith('http://') && !effectiveUrl.startsWith('https://')) {
                        effectiveUrl = 'https://siawi.smkwisataindonesia.sch.id/storage/$effectiveUrl';
                      }
                      final safeJudul = (item['judul'] ?? 'Portofolio')
                          .toString()
                          .replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '_');
                      await FileDownloader.downloadFile(
                        context: context,
                        url: effectiveUrl,
                        defaultFileName: 'Portofolio_$safeJudul.pdf',
                      );
                    },
                    icon: const Icon(Icons.file_download_rounded, size: 18),
                    label: const Text("Unduh Dokumen / Bukti Portofolio"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C3EC7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4C3EC7)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4C3EC7)))
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: const Color(0xFF4C3EC7),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      slivers: [
                        // 1. Hero Card - ikut terscroll ke atas hingga tertutup
                        SliverToBoxAdapter(
                          child: _buildTopHeroCard(),
                        ),

                        // 2. Tab Bar - ikut terscroll lalu menempel (pinned/sticky) di atas
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverFilterBarDelegate(
                            child: _buildFilterBar(),
                            height: 52.0,
                          ),
                        ),

                        // 3. Daftar Berkas - terscroll di bawah tab yang terkunci
                        if (_filteredItems.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _buildEmptyState(),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                            sliver: SliverList.separated(
                              itemCount: _filteredItems.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildCard(_filteredItems[index]);
                              },
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

  Widget _buildTopHeroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
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
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -6,
            child: Icon(
              Icons.verified_user_rounded,
              size: 104,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _namaJurusan.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Koleksi Bukti Prestasi &\nKompetensi Vokasi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19.5,
                    fontWeight: FontWeight.w900,
                    height: 1.22,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Arsip digital resmi keahlian vokasi $_namaJurusan, sertifikasi industri, dan pencapaian praktikum laboratorium.",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.military_tech_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "$_countSertifikat",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 1.5),
                                  const Text(
                                    "Sertifikat Resmi",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.inventory_2_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "$_countProyek",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 1.5),
                                  const Text(
                                    "Proyek Bengkel",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                      "Sertifikat & Portofolio",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      "Koleksi Lisensi Vendor & Karya Praktik Siswa",
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

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedCategory = cat),
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
                    cat,
                    style: TextStyle(
                      fontSize: 12,
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

  Widget _buildCard(Map<String, dynamic> item) {
    IconData icon = item['icon'] is IconData ? item['icon'] : Icons.layers_rounded;
    Color color = item['color'] is Color ? item['color'] : const Color(0xFF4C3EC7);
    final String statusVerif = (item['status_verifikasi'] ?? 'menunggu').toString();
    final bool isApproved = statusVerif == 'disetujui';
    final bool isRejected = statusVerif == 'ditolak';

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetail(item),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(icon, color: color, size: 24),
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
                              color: isApproved
                                  ? const Color(0xFFDCFCE7)
                                  : (isRejected ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['status'] ?? 'Menunggu Verifikasi',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isApproved
                                    ? const Color(0xFF16A34A)
                                    : (isRejected ? const Color(0xFFDC2626) : const Color(0xFFD97706)),
                              ),
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
                        item['judul'] ?? 'Sertifikat Siswa',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.25),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['penerbit'] ?? '-',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "No: ${item['nomor'] ?? '-'}",
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 22),
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
              decoration: const BoxDecoration(color: Color(0xFFFFE4E6), shape: BoxShape.circle),
              child: const Icon(Icons.layers_clear_rounded, size: 48, color: Color(0xFFE11D48)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Belum Ada Portofolio",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 6),
            const Text(
              "Tidak ditemukan sertifikat atau karya untuk kategori ini.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverFilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverFilterBarDelegate({
    required this.child,
    this.height = 52.0,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isPinned = shrinkOffset > 4;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        boxShadow: isPinned
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverFilterBarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
