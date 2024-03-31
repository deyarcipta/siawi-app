import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/absensi/views/absensi_view.dart';
// import 'package:siawi_app/app/modules/home/views/MyHomePage.dart';
// import 'package:get/get.dart';
import 'package:siawi_app/app/modules/informasi/views/informasi_view.dart';
import 'package:siawi_app/app/modules/jadwal/views/jadwal_view.dart';
import 'package:siawi_app/app/modules/kalender/views/kalender_view.dart';
import 'package:siawi_app/app/modules/modul/views/modul_mapel_view.dart';
import 'package:siawi_app/app/modules/point_siswa/views/point_siswa_view.dart';
import 'package:siawi_app/app/modules/rapot/views/rapot_view.dart';
import 'package:siawi_app/app/modules/tagihan/views/tagihan_view.dart';
// import 'package:get/get.dart';
// import 'package:siawi_app/app/modules/home/widget/header.dart';
// import 'package:siawi_app/app/modules/jadwal/widget/jadwal_bar.dart';
// import 'package:siawi_app/app/modules/login/views/login_view.dart';
// import 'package:siawi_app/app/routes/app_pages.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/utils/colors.dart';

class Menu extends StatefulWidget {
  Menu({Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const Menu(this.signOut, {super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    // return Expanded(
    //   child: Padding(
    //     padding: EdgeInsets.symmetric(horizontal: 15),
    //     child: GridView.count(
    //       crossAxisCount: 4,
    //       childAspectRatio: .85,
    //       crossAxisSpacing: 10,
    //       mainAxisSpacing: 10,
    //       children: <Widget>[
    //         Container(
    //           padding: EdgeInsets.all(10),
    //           decoration: BoxDecoration(
    //             color: AppColors.thirdColor,
    //             borderRadius: BorderRadius.circular(13),
    //           ),
    //           child: Column(
    //             children: <Widget>[
    //               Image.asset(
    //                 'assets/images/default.png',
    //                 width: 40,
    //               ),
    //               SizedBox(
    //                 height: 2,
    //               ),
    //               Text(
    //                 'Informasi Sekolah',
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(
    //                   fontSize: 10,
    //                 ),
    //               )
    //             ],
    //           ),
    //         ),
    //         Container(
    //           padding: EdgeInsets.all(10),
    //           decoration: BoxDecoration(
    //             color: AppColors.thirdColor,
    //             borderRadius: BorderRadius.circular(13),
    //           ),
    //           child: Column(
    //             children: <Widget>[
    //               Image.asset(
    //                 'assets/images/default.png',
    //                 width: 40,
    //               ),
    //               SizedBox(
    //                 height: 2,
    //               ),
    //               Text(
    //                 'Informasi Sekolah',
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(
    //                   fontSize: 10,
    //                 ),
    //               )
    //             ],
    //           ),
    //         ),
    //         Container(
    //           padding: EdgeInsets.all(10),
    //           decoration: BoxDecoration(
    //             color: AppColors.thirdColor,
    //             borderRadius: BorderRadius.circular(13),
    //           ),
    //           child: Column(
    //             children: <Widget>[
    //               Image.asset(
    //                 'assets/images/default.png',
    //                 width: 40,
    //               ),
    //               SizedBox(
    //                 height: 2,
    //               ),
    //               Text(
    //                 'Informasi Sekolah',
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(
    //                   fontSize: 10,
    //                 ),
    //               )
    //             ],
    //           ),
    //         ),
    //         Container(
    //           padding: EdgeInsets.all(10),
    //           decoration: BoxDecoration(
    //             color: AppColors.thirdColor,
    //             borderRadius: BorderRadius.circular(13),
    //           ),
    //           child: Column(
    //             children: <Widget>[
    //               Image.asset(
    //                 'assets/images/default.png',
    //                 width: 40,
    //               ),
    //               SizedBox(
    //                 height: 2,
    //               ),
    //               Text(
    //                 'Informasi Sekolah',
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(
    //                   fontSize: 10,
    //                 ),
    //               )
    //             ],
    //           ),
    //         ),
    //         Container(
    //           padding: EdgeInsets.all(10),
    //           decoration: BoxDecoration(
    //             color: AppColors.thirdColor,
    //             borderRadius: BorderRadius.circular(13),
    //           ),
    //           child: Column(
    //             children: <Widget>[
    //               Image.asset(
    //                 'assets/images/default.png',
    //                 width: 40,
    //               ),
    //               SizedBox(
    //                 height: 2,
    //               ),
    //               Text(
    //                 'Informasi Sekolah',
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(
    //                   fontSize: 10,
    //                 ),
    //               )
    //             ],
    //           ),
    //         ),
    //         Container(
    //           padding: EdgeInsets.all(10),
    //           decoration: BoxDecoration(
    //             color: AppColors.thirdColor,
    //             borderRadius: BorderRadius.circular(13),
    //           ),
    //           child: Column(
    //             children: <Widget>[
    //               Image.asset(
    //                 'assets/images/default.png',
    //                 width: 40,
    //               ),
    //               SizedBox(
    //                 height: 2,
    //               ),
    //               Text(
    //                 'Informasi Sekolah',
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(
    //                   fontSize: 10,
    //                 ),
    //               )
    //             ],
    //           ),
    //         ),
    //         Container(
    //           padding: EdgeInsets.all(10),
    //           decoration: BoxDecoration(
    //             color: AppColors.thirdColor,
    //             borderRadius: BorderRadius.circular(13),
    //           ),
    //           child: Column(
    //             children: <Widget>[
    //               Image.asset(
    //                 'assets/images/default.png',
    //                 width: 40,
    //               ),
    //               SizedBox(
    //                 height: 2,
    //               ),
    //               Text(
    //                 'Informasi Sekolah',
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(
    //                   fontSize: 10,
    //                 ),
    //               )
    //             ],
    //           ),
    //         ),
    //         Container(
    //           padding: EdgeInsets.all(10),
    //           decoration: BoxDecoration(
    //             color: AppColors.thirdColor,
    //             borderRadius: BorderRadius.circular(13),
    //           ),
    //           child: Column(
    //             children: <Widget>[
    //               Image.asset(
    //                 'assets/images/default.png',
    //                 width: 40,
    //               ),
    //               SizedBox(
    //                 height: 2,
    //               ),
    //               Text(
    //                 'Informasi Sekolah',
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(
    //                   fontSize: 10,
    //                 ),
    //               )
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Wrap(
        spacing: 5.0,
        runSpacing: 5.0,
        children: <Widget>[
          MenuCard(
            title: "Informasi Sekolah",
            img: "assets/icon/informasi.png",
            tujuan: InformasiView(),
          ),
          MenuCard(
            title: "Kalender Sekolah",
            img: "assets/icon/kalender-sekolah.png",
            tujuan: KalenderView(),
          ),
          MenuCard(
            title: "Absensi",
            img: "assets/icon/absen.png",
            tujuan: AbsensiView(),
          ),
          MenuCard(
            title: "Jadwal Mata Pelajaran",
            img: "assets/icon/jadwal.png",
            tujuan: JadwalView(),
          ),
          MenuCard(
            title: "e-rapot",
            img: "assets/icon/e-rapot.png",
            tujuan: RapotView(),
          ),
          MenuCard(
            title: "Tagihan",
            img: "assets/icon/tagihan.png",
            tujuan: TagihanView(),
          ),
          MenuCard(
            title: "Point Siswa",
            img: "assets/icon/point.png",
            tujuan: PointSiswaView(),
          ),
          MenuCard(
            title: "Modul",
            img: "assets/icon/modul.png",
            tujuan: ModulMapelView(),
          ),
        ],
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  final String img;
  final tujuan;
  const MenuCard({
    Key? key,
    required this.title,
    required this.img,
    required this.tujuan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => tujuan));
      },
      child: SizedBox(
        width: 85.0,
        height: 110.0,
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
                    width: 40,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
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
