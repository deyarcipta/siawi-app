import 'dart:convert';
import 'package:flutter/material.dart';

// import 'package:get/get.dart';
import 'package:siawi_app/app/modules/dokumen/views/detail_dokumen.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// import '../controllers/dokumen_controller.dart';
import 'package:siawi_app/app/modules/dokumen/widget/dokumen_list.dart';

class DokumenView extends StatefulWidget {
  final VoidCallback signOut;
  const DokumenView(this.signOut, {Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const DokumenView(this.signOut, {super.key});

  @override
  State<DokumenView> createState() => _DokumenViewState();
}

class _DokumenViewState extends State<DokumenView> {
  Future<String?> getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? idSiswa = preferences.getString('idSiswa');
    return idSiswa;
  }

  @override
  void initState() {
    super.initState();
    getIdSiswa().then((idSiswa) {
      // Jika idSiswa tidak null, panggil _lihatData
      if (idSiswa != null) {
        _fetchdokumen(idSiswa);
      }
    });
  }

  List<DokumenList> dokumenList = [];
  Future<void> _fetchdokumen(String idSiswa) async {
    final response = await http.get(Uri.parse(
        'https://siawi.smkwisataindonesia.sch.id/api/dokumen/$idSiswa'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> dokumenData = responseData['data'];
      setState(() {
        dokumenList.clear();
        for (var item in dokumenData) {
          DokumenList dokumen = DokumenList.fromJson(item);
          dokumenList.add(dokumen);
        }
      });
    } else {
      print('Failed to load jadwal hari ini');
    }
  }

  var appBarHeight = AppBar().preferredSize.height;

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        leading: BackButton(color: AppColors.white),
        title: Text(
          'SI AWI',
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: Image.asset(
              'assets/logo/logo-splash.png',
              width: 30,
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: ListView.builder(
          itemCount: dokumenList.length,
          itemBuilder: (context, index) {
            DokumenList dokumen = dokumenList[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  // side: BorderSide(width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                tileColor: AppColors.thirdColor,
                leading: Image.asset(
                  "assets/icon/absen.png",
                  width: 25,
                  height: 25,
                ),
                title:
                    Text('Jenis Dokumen ${dokumenList[index].jenis_dokumen}'),
                trailing: Icon(Icons.arrow_forward_rounded),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailDokumen(dokumen)));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
