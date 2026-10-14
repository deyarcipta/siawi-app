import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/dokumen/views/detail_dokumen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/modules/dokumen/widget/dokumen_list.dart';

class DokumenView extends StatefulWidget {
  final VoidCallback signOut;
  const DokumenView(this.signOut, {super.key});

  @override
  State<DokumenView> createState() => _DokumenViewState();
}

class _DokumenViewState extends State<DokumenView> {
  bool _isLoading = true;
  List<DokumenList> dokumenList = [];
  String? _namaSiswa;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? idSiswa = preferences.getString('idSiswa');
    if (idSiswa != null) {
      await _fetchDokumen(idSiswa);
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchDokumen(String idSiswa) async {
    try {
      final responseData = await ApiService.get('/dokumen/$idSiswa');
      if (responseData != null && responseData['data'] != null) {
        final List<dynamic> dokumenData = responseData['data'];
        List<DokumenList> temp = [];
        for (var item in dokumenData) {
          temp.add(DokumenList.fromJson(item));
        }
        if (mounted) {
          setState(() {
            dokumenList = temp;
            if (responseData['siswa'] != null) {
              _namaSiswa = responseData['siswa']['nama_siswa']?.toString();
            }
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF4C3EC7),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dokumen Administrasi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              _namaSiswa != null ? _namaSiswa! : 'Berkas Resmi Siswa',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
            tooltip: 'Segarkan Data',
            onPressed: _loadData,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Image.asset(
                'assets/logo/logo-splash.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4C3EC7),
                strokeWidth: 2.8,
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF4C3EC7),
              onRefresh: _loadData,
              child: dokumenList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      itemCount: dokumenList.length,
                      itemBuilder: (context, index) {
                        final dokumen = dokumenList[index];
                        return _buildDokumenItemCard(dokumen);
                      },
                    ),
            ),
    );
  }

  Widget _buildDokumenItemCard(DokumenList dokumen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailDokumen(dokumen)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon PDF Red Modern Container
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Color(0xFFEF4444),
                      size: 26,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Nama Dokumen & Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dokumen.jenis_dokumen.isNotEmpty
                            ? dokumen.jenis_dokumen
                            : "Dokumen Siswa",
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "PDF DIGITAL",
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Ketuk untuk membuka",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tombol Panah Buka
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Color(0xFF4C3EC7),
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
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFEDE9FE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 40,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Belum Ada Dokumen Terlampir",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Dokumen administrasi seperti Ijazah, KK, atau Akta akan muncul di sini setelah diunggah oleh pihak sekolah.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
