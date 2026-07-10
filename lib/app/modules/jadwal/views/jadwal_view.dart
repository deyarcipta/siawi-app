import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/app/data/api_service.dart';
// import 'package:siawi_app/app/models/jadwal.dart';
import 'package:siawi_app/app/modules/jadwal/widget/jadwal_list.dart';

import 'package:siawi_app/utils/colors.dart';
import 'package:siawi_app/utils/tab_silver_delegate.dart';
import 'package:auto_size_text/auto_size_text.dart';

class JadwalView extends StatefulWidget {
  final VoidCallback signOut;

  const JadwalView(this.signOut, {Key? key}) : super(key: key);

  @override
  State<JadwalView> createState() => _JadwalViewState();
}

class _JadwalViewState extends State<JadwalView> {
  final tabs = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
  late String _idSiswa = '';

  @override
  void initState() {
    super.initState();
    _loadIdSiswa();
  }

  Future<void> _loadIdSiswa() async {
    final idSiswa = await _getIdSiswa();
    setState(() {
      _idSiswa = idSiswa!;
      _lihatData(idSiswa);
    });
  }

  Future<String?> _getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('idSiswa');
  }

  bool loading = false;
  String? namaKelas;
  String? namaJurusan;
  Future<void> _lihatData(String idSiswa) async {
    setState(() {
      loading = true;
    });
    try {
      final datasiswa = await ApiService.get('/home/$idSiswa');
      if (datasiswa != null && datasiswa['data'] != null) {
        var siswaData = datasiswa['data'];
        var kelasData = siswaData['kelas'];
        var jurusanData = siswaData['jurusan'];
        if (siswaData['nis'] != null) {
          setState(() {
            namaKelas = kelasData['nama_kelas'].toString();
            namaJurusan = jurusanData['nama_jurusan'].toString();
          });
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
      body: DefaultTabController(
        length: 5,
        child: NestedScrollView(
            physics: const ClampingScrollPhysics(),
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                  child: Wrap(
                    children: <Widget>[
                      SafeArea(
                        child: Container(
                          width: double.infinity,
                          height: size.height * .1,
                          decoration: BoxDecoration(
                            color: AppColors.fiveColor,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // Menambahkan ini
                              children: [
                                _buildTitle('Jadwal Mata Pelajaran'),
                                _buildTitleData('$namaJurusan'),
                                _buildTitleData('$namaKelas'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  delegate: TabSliverDelegate(
                    TabBar(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      isScrollable: false,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: AppColors.mainColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                        ),
                      ),
                      tabs: tabs
                          .map((e) => Tab(
                                child: AutoSizeText(
                                  e,
                                  style: TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  minFontSize: 10,
                                  maxFontSize: 12,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                JadwalList(
                  hari: 'senin',
                  signOut: widget.signOut,
                  scrollKey: '',
                ),
                JadwalList(
                  hari: 'selasa',
                  signOut: widget.signOut,
                  scrollKey: '',
                ),
                JadwalList(
                  hari: 'rabu',
                  signOut: widget.signOut,
                  scrollKey: '',
                ),
                JadwalList(
                  hari: 'kamis',
                  signOut: widget.signOut,
                  scrollKey: '',
                ),
                JadwalList(
                  hari: 'jumat',
                  signOut: widget.signOut,
                  scrollKey: '',
                ),
              ],
            )),
      ),
    );
  }
}

Widget _buildTitle(String text) {
  return Container(
    padding: const EdgeInsets.only(top: 10),
    child: Text(
      text,
      maxLines: 2,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.white,
      ),
    ),
  );
}

Widget _buildTitleData(String text) {
  return Container(
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white,
      ),
    ),
  );
}
