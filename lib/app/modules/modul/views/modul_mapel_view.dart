import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/modul/views/detail_modul_view.dart';
import 'package:siawi_app/app/modules/modul/widget/modul_list.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ModulMapelView extends StatefulWidget {
  const ModulMapelView({Key? key}) : super(key: key);

  @override
  State<ModulMapelView> createState() => _ModulMapelViewState();
}

class _ModulMapelViewState extends State<ModulMapelView> {
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
        _fetchModul(idSiswa);
      }
    });
  }

  List<ModulList> modulList = [];
  Future<void> _fetchModul(String idSiswa) async {
    final response =
        await http.get(Uri.parse('http://203.194.113.46/api/modul/$idSiswa'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Map<String, dynamic> modulData = responseData['data'];
      setState(() {
        modulList.clear();
        modulData.forEach((key, value) {
          ModulList module = ModulList.fromJson(value);
          modulList.add(module);
        });
      });
    } else {
      print('Failed to load jadwal hari ini');
    }
  }

  @override
  Widget build(BuildContext context) {
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: ListView.builder(
          itemCount: modulList.length,
          itemBuilder: (context, index) {
            ModulList modul = modulList[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(modul.namaMapel),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                tileColor: AppColors.thirdColor,
                leading: Image.asset(
                  "assets/icon/modul.png",
                  width: 25,
                  height: 25,
                ),
                trailing: Icon(Icons.arrow_forward_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailModulView(modulItems: modul.modulItems),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
