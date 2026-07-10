import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/modules/home/widget/kebiasan_anak.dart';
import 'package:siawi_app/app/modules/home/widget/absen.dart';
import 'package:siawi_app/app/modules/home/widget/berita_terbaru.dart';
import 'package:siawi_app/app/modules/home/widget/data_mahasiswa.dart';
import 'package:siawi_app/app/modules/home/widget/header.dart';
import 'package:siawi_app/app/modules/home/widget/jadwal.dart';
import 'package:siawi_app/app/modules/home/widget/menu.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:siawi_app/app/modules/home/widget/version_checker.dart'; // Import version checker

class HomeView extends StatefulWidget {
  final VoidCallback signOut;
  final void Function(bool show)? toggleBottomNavBar;

  const HomeView(this.signOut, {Key? key, this.toggleBottomNavBar})
      : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final String currentVersion = "1.1.3"; // Versi aplikasi saat ini
  final String apiUrl = "/latest-version"; // URL API

  @override
  void initState() {
    super.initState();
    _checkForUpdate(); // Periksa pembaruan saat halaman dimuat
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
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: size.height * .30,
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
                          height: size.height * 0.02,
                        ),
                        Header(widget.signOut),
                        SizedBox(
                          height: size.height * 0.03,
                        ),
                        Wrap(
                          children: <Widget>[
                            DataMahasiswa(widget.signOut),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Absen(widget.signOut),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Absen(widget.signOut),
                      ),
                      Expanded(
                        flex: 1,
                        child: KebiasanAnakIndonesia(widget.signOut),
                      ),
                    ],
                  ),
                  JadwalToday(widget.signOut),
                  SizedBox(height: 20),
                  Menu(widget.signOut),
                  SizedBox(height: 20),
                  BeritaTerbaru(widget.signOut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
