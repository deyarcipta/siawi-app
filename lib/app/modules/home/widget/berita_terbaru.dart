import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/models/berita.dart';
import 'package:siawi_app/app/modules/home/widget/berita_lengkap.dart';

class BeritaTerbaru extends StatefulWidget {
  final VoidCallback signOut;
  const BeritaTerbaru(this.signOut, {super.key});

  @override
  State<BeritaTerbaru> createState() => _BeritaTerbaruState();
}

class _BeritaTerbaruState extends State<BeritaTerbaru> {
  List<Berita> beritaList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBerita();
  }

  Future<void> _fetchBerita() async {
    try {
      final responseData = await ApiService.get('/berita');
      if (responseData != null && responseData['data'] != null && mounted) {
        final List<dynamic> beritaData = responseData['data'];
        setState(() {
          beritaList = beritaData.map((item) => Berita.fromJson(item)).toList();
          isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load berita: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _cleanText(String raw) {
    if (raw.isEmpty) return '';
    String text = raw
        .replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return text;
  }

  String _formatTimeAgo(String dateStr) {
    if (dateStr.isEmpty) return 'Terkini';
    try {
      DateTime date = DateTime.parse(dateStr);
      Duration diff = DateTime.now().difference(date);
      if (diff.inDays <= 0) {
        return 'Hari ini';
      } else if (diff.inDays == 1) {
        return '1 hari lalu';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} hari lalu';
      } else if (diff.inDays < 30) {
        int weeks = (diff.inDays / 7).floor();
        return '$weeks minggu lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (_) {
      return dateStr;
    }
  }

  Map<String, dynamic> _getCategory(String title, int index) {
    String lower = title.toLowerCase();
    if (lower.contains('pkl') || lower.contains('magang') || lower.contains('penting')) {
      return {
        'label': 'Penting',
        'color': const Color(0xFFDC2626), // Merah Crimson
      };
    } else if (lower.contains('uji') || lower.contains('kompetensi') || lower.contains('ujian')) {
      return {
        'label': 'Akademik',
        'color': const Color(0xFF2563EB), // Biru Royal
      };
    } else if (lower.contains('prestasi') || lower.contains('juara') || lower.contains('lomba')) {
      return {
        'label': 'Prestasi',
        'color': const Color(0xFFD97706), // Amber
      };
    } else if (index % 2 == 1) {
      return {
        'label': 'Akademik',
        'color': const Color(0xFF2563EB),
      };
    }
    return {
      'label': 'Kegiatan',
      'color': const Color(0xFF059669), // Emerald
    };
  }

  String _getButtonLabel(String title) {
    String lower = title.toLowerCase();
    if (lower.contains('pkl') || lower.contains('magang')) {
      return 'Detail PKL';
    } else if (lower.contains('uji') || lower.contains('kompetensi')) {
      return 'Detail Uji';
    }
    return 'Detail';
  }

  String _getAuthor(String pembuat) {
    String clean = pembuat.trim();
    if (clean.isEmpty) return 'Humas SMK WI';
    if (int.tryParse(clean) != null) return 'Humas SMK WI';
    if (clean.toLowerCase().contains('mitra:')) {
      return clean.replaceAll(RegExp(r'mitra:\s*', caseSensitive: false), '').trim();
    }
    return clean;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER SECTION
            const Text(
              'Pengumuman & Berita Terkini',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E2432),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Informasi Akademik & Sekolah',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.swap_horiz_rounded,
                      size: 15,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Geser horizontal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. KONTEN BERITA HORIZONTAL CAROUSEL
            if (isLoading)
              SizedBox(
                height: 270,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                    ),
                  ),
                ),
              )
            else if (beritaList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      color: Color(0xFF94A3B8),
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Belum Ada Pengumuman Terbaru',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 248,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.hardEdge,
                  itemCount: beritaList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = beritaList[index];
                    final category = _getCategory(item.judulBerita, index);
                    final buttonLabel = _getButtonLabel(item.judulBerita);
                    final cleanContent = _cleanText(item.isiBerita);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BeritaLengkap(berita: item),
                          ),
                        );
                      },
                      child: Container(
                        width: 255,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // THUMBNAIL GAMBAR DENGAN BADGE KIRI & KANAN
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(19),
                              ),
                              child: SizedBox(
                                height: 130,
                                width: double.infinity,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl:
                                          'https://siawi.smkwisataindonesia.sch.id/storage/berita/${item.cover}',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: const Color(0xFFE2E8F0),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF4F46E5),
                                            ),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: const Color(0xFFE2E8F0),
                                        child: const Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Color(0xFF94A3B8),
                                          size: 32,
                                        ),
                                      ),
                                    ),

                                    // BADGE KIRI ATAS: KATEGORI
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: category['color'] as Color,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.25),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          category['label'] as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // BADGE KANAN ATAS: WAKTU
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.55),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          _formatTimeAgo(item.tanggal),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // KONTEN TEKS & FOOTER
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // JUDUL BERITA
                                  Text(
                                    item.judulBerita,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E293B),
                                      height: 1.25,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),

                                  // RINGKASAN CUPLIKAN BERITA
                                  Text(
                                    cleanContent,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                      height: 1.35,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),

                                  // FOOTER: SUMBER/PENULIS & TOMBOL AKSI
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.account_circle_outlined,
                                              size: 15,
                                              color: Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 5),
                                            Expanded(
                                              child: Text(
                                                _getAuthor(item.pembuat),
                                                style: const TextStyle(
                                                  color: Color(0xFF64748B),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4F46E5),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              buttonLabel,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
