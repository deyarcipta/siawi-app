// import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:siawi_app/app/modules/home/widget/absen.dart';
import 'package:siawi_app/app/modules/home/widget/berita_terbaru.dart';
import 'package:siawi_app/app/modules/home/widget/data_mahasiswa.dart';
import 'package:siawi_app/app/models/menu_item.dart';
import 'package:siawi_app/app/models/menu_items.dart';
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
  const HomeView({Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const HomeView(this.signOut, {super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var appBarHeight = AppBar().preferredSize.height;

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
                        Header(),
                        SizedBox(
                          height: size.height * 0.03,
                        ),
                        Wrap(
                          children: <Widget>[
                            DataMahasiswa(),
                            Absen(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  JadwalToday(),
                  SizedBox(height: 20),
                  Menu(),
                  SizedBox(height: 20),
                  BeritaTerbaru(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<MenuKu> buildItem(MenuKu item) => PopupMenuItem<MenuKu>(
        value: item,
        child: Row(
          children: [
            Icon(
              item.icon,
              color: const Color.fromRGBO(0, 0, 0, 1),
              size: 16,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(item.text),
          ],
        ),
      );

  void onSelected(BuildContext context, MenuKu item) {
    switch (item) {
      case MenuItems.itemLogout:
        // SignOut();
        break;
    }
  }
}
