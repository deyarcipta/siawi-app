import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/modul/views/detail_modul_view.dart';
import 'package:siawi_app/app/modules/modul/widget/modul_list.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/app/data/api_service.dart';

class ModulMapelView extends StatefulWidget {
  const ModulMapelView({super.key});

  @override
  State<ModulMapelView> createState() => _ModulMapelViewState();
}

class _ModulMapelViewState extends State<ModulMapelView> {
  bool isLoading = true;

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
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  List<ModulList> modulList = [];
  Future<void> _fetchModul(String idSiswa) async {
    try {
      final responseData = await ApiService.get('/modul/$idSiswa');
      if (responseData != null && responseData['data'] != null) {
        final List<dynamic> modulData = responseData['data'];
        setState(() {
          modulList.clear();
          for (var value in modulData) {
            ModulList module = ModulList.fromJson(value);
            modulList.add(module);
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to load modul: $e');
      setState(() {
        isLoading = false;
      });
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
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.mainColor,
                ),
              )
            : modulList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada modul yang ditambahkan oleh guru',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
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
                                builder: (context) => DetailModulView(
                                    modulItems: modul.modulItems),
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
