import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/absensi/views/absensi_view.dart';
import 'package:siawi_app/app/modules/informasi/views/informasi_view.dart';
import 'package:siawi_app/app/modules/jadwal/views/jadwal_view.dart';
import 'package:siawi_app/app/modules/kalender/views/kalender_view.dart';
import 'package:siawi_app/app/modules/modul/views/modul_mapel_view.dart';
import 'package:siawi_app/app/modules/point_siswa/views/point_siswa_view.dart';
import 'package:siawi_app/app/modules/rapot/views/rapot_view.dart';
import 'package:siawi_app/app/modules/tagihan/views/tagihan_view.dart';
import 'package:siawi_app/utils/colors.dart';

class Menu extends StatefulWidget {
  final VoidCallback signOut;
  const Menu(this.signOut, {Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Total horizontal padding is 30 (15 left + 15 right)
        // Total spacing between cards is 15 (3 gaps * 5)
        double totalHorizontalPadding = 30;
        double totalSpacing = 15;
        double availableWidth =
            constraints.maxWidth - totalHorizontalPadding - totalSpacing;
        double width = availableWidth /
            4; // Lebar untuk setiap card, dengan 4 card per baris

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Wrap(
            spacing: 5.0,
            runSpacing: 5.0,
            children: <Widget>[
              MenuCard(
                title: "Informasi Sekolah",
                img: "assets/icon/informasi.png",
                tujuan: InformasiView(widget.signOut),
                width: width,
              ),
              MenuCard(
                title: "Kalender Sekolah",
                img: "assets/icon/kalender-sekolah.png",
                tujuan: KalenderView(widget.signOut),
                width: width,
              ),
              MenuCard(
                title: "Absensi",
                img: "assets/icon/absen.png",
                tujuan: AbsensiView(widget.signOut),
                width: width,
              ),
              MenuCard(
                title: "Jadwal Mata Pelajaran",
                img: "assets/icon/jadwal.png",
                tujuan: JadwalView(widget.signOut),
                width: width,
              ),
              MenuCard(
                title: "e-rapot",
                img: "assets/icon/e-rapot.png",
                tujuan: RapotView(widget.signOut),
                width: width,
              ),
              MenuCard(
                title: "Tagihan",
                img: "assets/icon/tagihan.png",
                tujuan: TagihanView(widget.signOut),
                width: width,
              ),
              MenuCard(
                title: "Point Siswa",
                img: "assets/icon/point.png",
                tujuan: PointSiswaView(widget.signOut),
                width: width,
              ),
              MenuCard(
                title: "Modul",
                img: "assets/icon/modul.png",
                tujuan: ModulMapelView(),
                width: width,
              ),
            ],
          ),
        );
      },
    );
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  final String img;
  final tujuan;
  final double width;

  const MenuCard({
    Key? key,
    required this.title,
    required this.img,
    required this.tujuan,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => tujuan),
        );
      },
      child: SizedBox(
        width: width,
        height: width * 1.3, // Sesuaikan rasio tinggi dengan lebar
        child: Card(
          color: AppColors.thirdColor,
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    img,
                    width: width * 0.5,
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
