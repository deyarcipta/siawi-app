import 'dart:convert';
import 'package:flutter/material.dart';

// import 'package:get/get.dart';
import 'package:siawi_app/app/modules/rapot/views/detail_rapot.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/app/data/api_service.dart';

// import '../controllers/rapot_controller.dart';
import 'package:siawi_app/app/modules/rapot/widget/rapot_list.dart';

class RapotView extends StatefulWidget {
  final VoidCallback signOut;
  const RapotView(this.signOut, {Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const RapotView(this.signOut, {super.key});

  @override
  State<RapotView> createState() => _RapotViewState();
}

class _RapotViewState extends State<RapotView> {
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
        _fetchRapot(idSiswa);
      }
    });
  }

  List<RapotList> rapotList = [];
  Future<void> _fetchRapot(String idSiswa) async {
    try {
      final responseData = await ApiService.get('/rapot/$idSiswa');
      if (responseData != null && responseData['data'] != null) {
        final List<dynamic> rapotData = responseData['data'];
        setState(() {
          rapotList.clear();
          for (var item in rapotData) {
            RapotList rapot = RapotList.fromJson(item);
            rapotList.add(rapot);
          }
        });
      }
    } catch (e) {
      print('Failed to load rapot: $e');
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
          itemCount: rapotList.length,
          itemBuilder: (context, index) {
            RapotList rapot = rapotList[index];
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
                title: Text('Semester ${rapotList[index].semester}'),
                trailing: Icon(Icons.arrow_forward_rounded),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailRapot(rapot)));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
