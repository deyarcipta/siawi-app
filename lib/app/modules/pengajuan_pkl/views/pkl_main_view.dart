import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/pkl_service.dart';
import 'package:siawi_app/app/modules/pengajuan_pkl/views/pengajuan_pkl_view.dart';
import 'package:siawi_app/app/modules/pengajuan_pkl/views/presensi_pkl_view.dart';

class PklMainView extends StatefulWidget {
  final VoidCallback signOut;
  final int? initialTabIndex; // 0 for Presensi, 1 for Pengajuan Surat

  const PklMainView(this.signOut, {super.key, this.initialTabIndex});

  @override
  State<PklMainView> createState() => _PklMainViewState();
}

class _PklMainViewState extends State<PklMainView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;
  bool _hasActivePkl = false;
  String? _namaPerusahaanAktif;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTabIndex ?? 0;
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: _currentTab);
    _tabController.addListener(() {
      if (_currentTab != _tabController.index && mounted) {
        setState(() {
          _currentTab = _tabController.index;
        });
      }
    });

    _checkSmartTabDefault();
  }

  Future<void> _checkSmartTabDefault() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idSiswa = prefs.getString('idSiswa');
      if (idSiswa == null || idSiswa.isEmpty) return;

      bool cachedHasPkl = false;
      String? cachedPerusahaan;
      String? cacheRaw = prefs.getString('cached_student_header_$idSiswa');
      if (cacheRaw != null && cacheRaw.isNotEmpty) {
        try {
          var cMap = jsonDecode(cacheRaw);
          cachedHasPkl = cMap['hasPkl'] == true;
          cachedPerusahaan = cMap['pklNamaPerusahaan']?.toString();
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _hasActivePkl = cachedHasPkl;
          _namaPerusahaanAktif = cachedPerusahaan;
        });
      }

      // Jika user membuka dari menu utama (initialTabIndex == null) dan belum ditempatkan,
      // arahkan langsung ke tab Pengajuan Surat agar tidak membingungkan.
      if (widget.initialTabIndex == null && !cachedHasPkl && mounted) {
        _tabController.animateTo(1);
        setState(() => _currentTab = 1);
      }

      // Cek status penempatan terbaru secara silent (tanpa memunculkan notifikasi error)
      final targetData = await PklService.getStatusPresensi(idSiswa);
      if (!mounted) return;

      final bool activeNow = targetData != null && targetData['perusahaan'] != null;
      final String? namaMitra =
          targetData?['perusahaan']?['nama_perusahaan']?.toString();

      setState(() {
        _hasActivePkl = activeNow;
        if (namaMitra != null && namaMitra.isNotEmpty) {
          _namaPerusahaanAktif = namaMitra;
        }
      });

      if (widget.initialTabIndex == null) {
        final int desiredTab = activeNow ? 0 : 1;
        if (_currentTab != desiredTab) {
          _tabController.animateTo(desiredTab);
          setState(() => _currentTab = desiredTab);
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildModernHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4C3EC7),
            Color(0xFF312596),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x334C3EC7),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Ornamen lingkaran dekoratif
            Positioned(
              right: -35,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              left: -25,
              bottom: 15,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar: Back Button + Title + School Logo
                  Row(
                    children: [
                      Material(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const SizedBox(
                            width: 38,
                            height: 38,
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
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
                                const Flexible(
                                  child: Text(
                                    'Layanan PKL Terpadu',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17.5,
                                      letterSpacing: -0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _hasActivePkl
                                        ? const Color(0xFF10B981)
                                            .withValues(alpha: 0.25)
                                        : Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _hasActivePkl
                                          ? const Color(0xFF6EE7B7)
                                              .withValues(alpha: 0.6)
                                          : Colors.white.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Text(
                                    _hasActivePkl ? 'PKL Aktif' : 'BKK & Hubin',
                                    style: TextStyle(
                                      color: _hasActivePkl
                                          ? const Color(0xFFA7F3D0)
                                          : Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _hasActivePkl &&
                                      _namaPerusahaanAktif != null &&
                                      _namaPerusahaanAktif!.isNotEmpty
                                  ? 'Mitra: $_namaPerusahaanAktif'
                                  : 'Presensi Industri & Pengajuan Surat PKL',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/logo/logo-splash.png',
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Modern Segmented Tab Switcher
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E166B).withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSegmentedTabItem(
                            index: 0,
                            title: 'Presensi PKL',
                            subtitle: _hasActivePkl
                                ? 'Absen GPS & Selfie'
                                : 'Setelah Ditempatkan',
                            icon: Icons.where_to_vote_rounded,
                            showDot: _hasActivePkl,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildSegmentedTabItem(
                            index: 1,
                            title: 'Pengajuan Surat',
                            subtitle: 'Permohonan Mitra',
                            icon: Icons.mark_email_read_rounded,
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
    );
  }

  Widget _buildSegmentedTabItem({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    bool showDot = false,
  }) {
    final bool isSelected = _currentTab == index;

    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() => _currentTab = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEEF2FF)
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 17,
                color: isSelected ? const Color(0xFF4C3EC7) : Colors.white,
              ),
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showDot) ...[
                        const SizedBox(width: 5),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF64748B)
                          : Colors.white.withValues(alpha: 0.7),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildModernHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PresensiPklView(
                  onSwitchToPengajuan: () {
                    _tabController.animateTo(1);
                    setState(() => _currentTab = 1);
                  },
                ),
                PengajuanPklView(
                  widget.signOut,
                  isEmbedded: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
