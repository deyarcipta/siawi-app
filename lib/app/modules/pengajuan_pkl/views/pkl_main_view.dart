import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/modules/pengajuan_pkl/views/pengajuan_pkl_view.dart';
import 'package:siawi_app/app/modules/pengajuan_pkl/views/presensi_pkl_view.dart';
import 'package:siawi_app/utils/colors.dart';

class PklMainView extends StatefulWidget {
  final VoidCallback signOut;
  final int initialTabIndex; // 0 for Presensi, 1 for Pengajuan Surat

  const PklMainView(this.signOut, {super.key, this.initialTabIndex = 0});

  @override
  State<PklMainView> createState() => _PklMainViewState();
}

class _PklMainViewState extends State<PklMainView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTabIndex;
    _tabController = TabController(length: 2, vsync: this, initialIndex: _currentTab);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _currentTab = _tabController.index;
      });
    });

    _checkSmartTabDefault();
  }

  Future<void> _checkSmartTabDefault() async {
    if (widget.initialTabIndex != 0) return; // Explicitly requested tab

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idSiswa = prefs.getString('idSiswa');
      if (idSiswa != null) {
        String? cacheRaw = prefs.getString('cached_student_header_$idSiswa');
        if (cacheRaw != null && cacheRaw.isNotEmpty) {
          var cMap = jsonDecode(cacheRaw);
          bool hasPkl = cMap['hasPkl'] == true;
          // Jika belum ada penempatan PKL aktif, arahkan awal ke tab Pengajuan Surat
          if (!hasPkl && mounted) {
            _tabController.animateTo(1);
            setState(() => _currentTab = 1);
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Menu PKL',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              labelColor: AppColors.mainColor,
              unselectedLabelColor: Colors.white.withOpacity(0.85),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.how_to_reg_rounded, size: 18),
                      SizedBox(width: 6),
                      Text('Presensi PKL'),
                    ],
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('Pengajuan Surat'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PresensiPklView(
            onSwitchToPengajuan: () {
              _tabController.animateTo(1);
            },
          ),
          PengajuanPklView(widget.signOut),
        ],
      ),
    );
  }
}

