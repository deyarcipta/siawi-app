// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:get/get.dart';
import 'package:siawi_app/app/modules/home/widget/absen.dart';
import 'package:siawi_app/app/modules/home/widget/berita_terbaru.dart';
import 'package:siawi_app/app/modules/home/widget/data_mahasiswa.dart';
// import 'package:siawi_app/app/models/menu_item.dart';
// import 'package:siawi_app/app/models/menu_items.dart';
import 'package:siawi_app/app/modules/home/widget/header.dart';
import 'package:siawi_app/app/modules/home/widget/jadwal.dart';
import 'package:siawi_app/app/modules/home/widget/menu.dart';
import 'package:siawi_app/utils/colors.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

// import 'package:get/get.dart';
// import 'package:siawi_app/utils/colors.dart';

// import '../controllers/home_controller.dart';

class HomeView extends StatefulWidget {
  final VoidCallback signOut;
  final void Function(bool show)? toggleBottomNavBar;

  const HomeView(this.signOut, {Key? key, this.toggleBottomNavBar})
      : super(key: key);
  // final VoidCallback signOut;
  // const HomeView(this.signOut, {super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var appBarHeight = AppBar().preferredSize.height;
  // ignore: non_constant_identifier_names
  SignOut() {
    setState(() {
      widget.signOut();
    });
  }

  String idSiswa = "";
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idSiswa = preferences.getString("idSiswa")!;
    });
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
              // child: Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 15),
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
                        Header(SignOut),
                        SizedBox(
                          height: size.height * 0.03,
                        ),
                        Wrap(
                          children: <Widget>[
                            DataMahasiswa(SignOut),
                            Absen(SignOut),
                          ],
                        ),
                      ],
                    ),
                  ),
                  JadwalToday(SignOut),
                  SizedBox(height: 20),
                  Menu(SignOut),
                  SizedBox(height: 20),
                  BeritaTerbaru(SignOut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PopupMenuItem<MenuKu> buildItem(MenuKu item) => PopupMenuItem<MenuKu>(
  //       value: item,
  //       child: Row(
  //         children: [
  //           Icon(
  //             item.icon,
  //             color: const Color.fromRGBO(0, 0, 0, 1),
  //             size: 16,
  //           ),
  //           const SizedBox(
  //             width: 12,
  //           ),
  //           Text(item.text),
  //         ],
  //       ),
  //     );
}
