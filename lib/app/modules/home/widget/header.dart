// import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:focused_menu/focused_menu.dart';
import 'package:siawi_app/app/models/menu_item.dart';
import 'package:siawi_app/app/models/menu_items.dart';
// import 'package:siawi_app/app/modules/login/views/login_view.dart';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

class Header extends StatefulWidget {
  Header({Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const Header(this.signOut, {super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  // SignOut() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   setState(() {
  //     preferences.remove("value");
  //   });
  //   Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(builder: (BuildContext context) => LoginView()),
  //       (route) => false);
  // }

  // String username = "";
  // getPref() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   setState(() {
  //     username = preferences.getString("username")!;
  //     // nama = preferences.getString("nama")!;
  //     _lihatData(username);
  //   });
  // }

  var appBarHeight = AppBar().preferredSize.height;

  // @override
  // void initState() {
  //   super.initState();
  //   getPref();
  //   _lihatData(username);
  // }

  // var nama, foto;
  // bool loading = false;
  // Future<void> _lihatData(String username) async {
  //   setState(() {
  //     loading = true;
  //   });
  //   final response = await http.get(Uri.parse(
  //       'https://smkwisataindonesia.sch.id/mywistek/data/dataSiswa.php?nis=$username'));
  //   // print(response.statusCode);

  //   if (response.statusCode == 200) {
  //     var datasiswa = jsonDecode(response.body);
  //     if (datasiswa['nis'] != null) {
  //       setState(() {
  //         nama = datasiswa['nama'];
  //         foto = datasiswa['foto'];
  //         // dataSiswa = datasiswa['nama'][0];
  //         // print(nama);
  //       });
  //     }
  //   } else {
  //     print('failed');
  //   }
  //   setState(() {
  //     loading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 250,
          child: const Column(
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
                'Ilham Muhammad Alamsyah',
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
              // IconButton(
              //   onPressed: () {
              //     setState(() {
              //       print('test');
              //     });
              //   },
              //   iconSize: 24,
              //   icon: Icon(
              //     Icons.notification_add_outlined,
              //     color: AppColors.white,
              //   ),
              // ),
              PopupMenuButton<MenuKu>(
                onSelected: (item) => onSelected(context, item),
                itemBuilder: (context) => [
                  // ...MenuItems.itemFirst
                  //     .map(buildItem)
                  //     .toList(),
                  // const PopupMenuDivider(),
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
        // SignOut();
        break;
    }
  }
}
