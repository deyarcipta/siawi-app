import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/modules/kejuruan/subviews/detail_modul_praktik_view.dart';
import 'package:siawi_app/utils/file_downloader.dart';

class ModulPraktikView extends StatefulWidget {
  final String? idSiswa;
  const ModulPraktikView({this.idSiswa, super.key});

  @override
  State<ModulPraktikView> createState() => _ModulPraktikViewState();
}

class _ModulPraktikViewState extends State<ModulPraktikView> {
  bool _isLoading = true;
  String? _effectiveIdSiswa;
  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = ['Semua', 'Dasar Kejuruan', 'Konsentrasi Keahlian', 'Job Sheet'];

  List<Map<String, dynamic>> _allModul = [];

  @override
  void initState() {
    super.initState();
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
          '/kejuruan/modul/$_effectiveIdSiswa',
          forceRefresh: true,
          silent: true,
        );
        if (res != null && res['success'] == true && res['data'] is List) {
          final List rawList = res['data'];
          _allModul = rawList.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      } catch (_) {}
    }



    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredModul {
    return _allModul.where((item) {
      final kategori = (item['kategori'] ?? '').toString();
      final judul = (item['judul_modul'] ?? item['nama_modul'] ?? item['judul'] ?? '').toString().toLowerCase();
      final komp = (item['kompetensi'] is Map ? item['kompetensi']['nama_kompetensi'] : item['kompetensi'] ?? '').toString().toLowerCase();
      final guru = (item['guru'] is Map ? item['guru']['nama_guru'] : item['guru'] ?? '').toString().toLowerCase();

      final matchesCategory = _selectedCategory == 'Semua' || kategori.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesQuery = _searchQuery.isEmpty ||
          judul.contains(_searchQuery.toLowerCase()) ||
          komp.contains(_searchQuery.toLowerCase()) ||
          guru.contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _showModulDetail(Map<String, dynamic> item) {
    String judul = (item['judul'] ?? item['judul_modul'] ?? item['nama_modul'] ?? 'Modul Praktik').toString();
    String kode = (item['kode_modul'] ?? item['kode'] ?? 'MODUL').toString();
    String kategori = (item['kategori'] ?? 'Konsentrasi Keahlian').toString();
    String komp = (item['kompetensi'] is Map ? item['kompetensi']['nama_kompetensi'] : item['kompetensi'] ?? '-').toString();
    String guru = (item['guru'] is Map ? item['guru']['nama_guru'] : item['guru'] ?? '-').toString();
    String revisi = (item['revisi'] ?? ('Versi ${item['versi'] ?? '1.0'}')).toString();
    String halaman = (item['halaman'] ?? 'Panduan Praktik').toString();
    String ukuran = (item['ukuran'] ?? 'Modul Digital').toString();
    String fileUrl = (item['file_url'] ?? item['file_lembar_kerja'] ?? item['file'] ?? '').toString();
    String tujuan = (item['tujuan'] ?? '').toString();
    String alatBahan = (item['alat_bahan'] ?? '').toString();
    String langkahKerja = (item['langkah_kerja'] ?? '').toString();
    List<dynamic> rubriks = item['rubriks'] is List ? item['rubriks'] : [];

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
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                    ),
                    child: Text(
                      kode,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4C3EC7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      kategori,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const Spacer(),
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
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              _buildDetailItem(Icons.psychology_rounded, "Kompetensi Inti", komp),
              const SizedBox(height: 10),
              _buildDetailItem(Icons.person_rounded, "Guru Penyusun", guru),
              const SizedBox(height: 10),
              _buildDetailItem(Icons.info_outline_rounded, "Informasi Modul", "$revisi • $halaman • $ukuran"),
              const SizedBox(height: 22),
              Row(
                children: [
                  if (fileUrl.trim().isNotEmpty) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          final safeKode = kode.replaceAll(RegExp(r'\s+'), '_');
                          final safeJudul = judul.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
                          final fileName = '${safeKode}_$safeJudul.pdf';

                          String effectiveUrl = fileUrl.trim();
                          if (!effectiveUrl.startsWith('http://') && !effectiveUrl.startsWith('https://')) {
                            effectiveUrl = 'https://siawi.smkwisataindonesia.sch.id/storage/modul_praktik/${Uri.encodeComponent(effectiveUrl)}';
                          }

                          await FileDownloader.downloadFile(
                            context: context,
                            url: effectiveUrl,
                            defaultFileName: fileName,
                          );
                        },
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text("Unduh Berkas"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4C3EC7),
                          side: const BorderSide(color: Color(0xFF4C3EC7), width: 1.3),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailModulPraktikView(
                              judul: judul,
                              kode: kode,
                              kategori: kategori,
                              guru: guru,
                              fileUrl: fileUrl,
                              tujuan: tujuan,
                              alatBahan: alatBahan,
                              langkahKerja: langkahKerja,
                              rubriks: rubriks,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                      label: const Text("Baca Modul"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C3EC7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4C3EC7)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
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
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4C3EC7)))
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: const Color(0xFF4C3EC7),
                    child: _filteredModul.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            itemCount: _filteredModul.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildModulCard(_filteredModul[index]);
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
                          "Modul & Job Sheet Praktik",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          "Bahan Ajar & Panduan Praktikum Mandiri",
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
                    hintText: "Cari judul modul atau materi...",
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

  Widget _buildModulCard(Map<String, dynamic> item) {
    String judul = (item['judul'] ?? item['judul_modul'] ?? item['nama_modul'] ?? 'Modul Praktik').toString();
    String kode = (item['kode_modul'] ?? item['kode'] ?? 'MODUL').toString();
    String komp = (item['kompetensi'] is Map ? item['kompetensi']['nama_kompetensi'] : item['kompetensi'] ?? '-').toString();
    String guru = (item['guru'] is Map ? item['guru']['nama_guru'] : item['guru'] ?? '-').toString();
    String revisi = (item['revisi'] ?? ('Versi ${item['versi'] ?? '1.0'}')).toString();
    String halaman = (item['halaman'] ?? 'Panduan Praktik').toString();

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
          onTap: () => _showModulDetail(item),
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
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(Icons.menu_book_rounded, color: Color(0xFFD97706), size: 24),
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
                              kode,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4C3EC7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "$revisi • $halaman",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Kompetensi: $komp",
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Guru: $guru",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D9488),
                        ),
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
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_stories_rounded, size: 48, color: Color(0xFFD97706)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Modul Tidak Ditemukan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Tidak ada modul praktik yang sesuai dengan pencarian atau kategori ini.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
