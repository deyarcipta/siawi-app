import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/modules/home/widget/berita_terbaru.dart';
import 'package:siawi_app/app/modules/home/widget/jadwal.dart';
import 'package:siawi_app/app/modules/home/widget/menu.dart';
import 'package:siawi_app/app/modules/home/widget/parent_dashboard_header.dart';
import 'package:siawi_app/app/modules/home/widget/student_dashboard_header.dart';
import 'package:siawi_app/app/modules/home/widget/parent_quick_services.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:siawi_app/app/modules/home/widget/version_checker.dart'; // Import version checker

class HomeView extends StatefulWidget {
  final VoidCallback signOut;
  final void Function(bool show)? toggleBottomNavBar;
  final String? initialRole;

  const HomeView(this.signOut, {super.key, this.toggleBottomNavBar, this.initialRole});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final String currentVersion = VersionChecker.appVersion; // Versi aplikasi saat ini disinkronkan
  final String apiUrl = "/latest-version"; // URL API
  late String role;
  bool _isRoleLoaded = false;
  String? _activeChildId;

  @override
  void initState() {
    super.initState();
    if (widget.initialRole != null && widget.initialRole!.isNotEmpty) {
      role = widget.initialRole!;
      _isRoleLoaded = true;
    } else {
      role = 'loading';
    }
    _loadRole();
    _checkForUpdate(); // Periksa pembaruan saat halaman dimuat
  }

  Future<void> _loadRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        role = preferences.getString('role') ?? 'siswa';
        _activeChildId = preferences.getString('idSiswa');
        _isRoleLoaded = true;
      });
    }
  }

  void _checkForUpdate() {
    final versionChecker = VersionChecker(
      context: context,
      currentVersion: currentVersion,
      apiUrl: apiUrl,
    );
    versionChecker.checkForUpdate(); // Panggil pengecekan versi
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRoleLoaded && role == 'loading') {
      return Scaffold(
        backgroundColor: AppColors.mainColor,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: size.height * .36,
              decoration: BoxDecoration(
                color: AppColors.mainColor,
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: size.height * 0.015,
                        ),
                        if (role == 'orang_tua')
                          ParentDashboardHeader(
                            widget.signOut,
                            onChildChanged: (newChildId) {
                              setState(() {
                                _activeChildId = newChildId;
                              });
                            },
                          )
                        else
                          StudentDashboardHeader(widget.signOut),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (role == 'orang_tua')
                    ParentQuickServices(widget.signOut, childId: _activeChildId)
                  else ...[
                    Menu(widget.signOut),
                    const SizedBox(height: 20),
                    JadwalToday(widget.signOut),
                  ],
                  const SizedBox(height: 20),
                  BeritaTerbaru(widget.signOut),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
