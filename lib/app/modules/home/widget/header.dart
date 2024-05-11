// import 'package:get/get.dart';
// import 'package:focused_menu/focused_menu.dart';
// import 'package:siawi_app/app/modules/login/views/login_view.dart';
// import 'package:siawi_app/app/modules/login/views/login_view.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:siawi_app/app/models/menu_item.dart';
import 'package:siawi_app/app/models/menu_items.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/app/modules/password/views/password_view.dart';

class Header extends StatefulWidget {
  final VoidCallback signOut;
  const Header(this.signOut, {Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const Header(this.signOut, {super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  var appBarHeight = AppBar().preferredSize.height;

  String? nama;
  String? namaJurusan;
  Future<String?> getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? idSiswa = preferences.getString('idSiswa');
    return idSiswa;
  }

  @override
  void initState() {
    super.initState();
    // Panggil getIdSiswa dan tunggu hasilnya
    getIdSiswa().then((idSiswa) {
      // Jika idSiswa tidak null, panggil _lihatData
      if (idSiswa != null) {
        _lihatData(idSiswa);
      }
    });
  }

  bool loading = false;
  Future<void> _lihatData(String idSiswa) async {
    setState(() {
      loading = true;
    });
    final response =
        await http.get(Uri.parse('http://203.194.113.46/api/home/$idSiswa'));
    // print(response.statusCode);

    if (response.statusCode == 200) {
      var datasiswa = json.decode(response.body);
      var siswaData = datasiswa['data'];
      // var kelasData = siswaData['kelas'];
      // var jurusanData = siswaData['jurusan'];
      if (siswaData['nis'] != null) {
        setState(() {
          nama = siswaData['nama_siswa'].toString();
          // namaJurusan = jurusanData['nama_jurusan'];
          // print(nama);
          // print('Nama Kelas: $namaJurusan');
        });
      }
    } else {
      print(idSiswa);
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome,',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                nama ?? 'Loading...',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              PopupMenuButton<MenuKu>(
                onSelected: (item) => onSelected(context, item),
                itemBuilder: (context) => [
                  ...MenuItems.itemFirst.map(buildItem).toList(),
                  ...MenuItems.itemSecond.map(buildItem).toList(),
                ],
                icon: CircleAvatar(
                  child: Image.asset(
                    'assets/images/default.png',
                    fit: BoxFit.cover,
                    width: 26,
                  ),
                ),
                offset: Offset(0.0, appBarHeight),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<MenuKu> buildItem(MenuKu item) => PopupMenuItem<MenuKu>(
        value: item,
        child: Row(
          children: [
            Icon(
              item.icon,
              color: Colors.black,
              size: 20,
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
        widget.signOut();
        break;
      case MenuItems.itemPassword:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PasswordView(widget.signOut)));
        break;
    }
  }
}
