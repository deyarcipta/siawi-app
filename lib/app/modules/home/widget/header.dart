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

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  var appBarHeight = AppBar().preferredSize.height;

  String? nama;
  String? fileFoto;
  String? namaJurusan;

  Future<String?> getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? idSiswa = preferences.getString('idSiswa');
    return idSiswa;
  }

  @override
  void initState() {
    super.initState();
    getIdSiswa().then((idSiswa) {
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
    final response = await http.get(
        Uri.parse('https://siawi.smkwisataindonesia.sch.id/api/home/$idSiswa'));

    if (response.statusCode == 200) {
      var datasiswa = json.decode(response.body);
      var siswaData = datasiswa['data'];
      if (siswaData['nis'] != null) {
        setState(() {
          nama = siswaData['nama_siswa'].toString();
          fileFoto = siswaData['foto'].toString();
        });
      }
    } else {
      print('Error: ${response.statusCode}');
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  backgroundColor: Colors.transparent,
                  child: fileFoto == null
                      ? CircularProgressIndicator() // Indikator loading saat fileFoto null
                      : ClipOval(
                          child: Image.network(
                            'https://siawi.smkwisataindonesia.sch.id/storage/foto-siswa/$fileFoto',
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                );
                              }
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 26,
                              );
                            },
                          ),
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
