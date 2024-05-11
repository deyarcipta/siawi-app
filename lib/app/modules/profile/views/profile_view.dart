import 'dart:convert';
import 'package:flutter/material.dart';

// import 'package:get/get.dart';
import 'package:siawi_app/app/modules/profile/widget/data_diri.dart';
import 'package:siawi_app/app/modules/profile/widget/orang_tua.dart';
import 'package:siawi_app/app/modules/profile/widget/profil.dart';
import 'package:siawi_app/app/modules/profile/widget/wali.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:siawi_app/utils/tab_silver_delegate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// import '../controllers/profile_controller.dart';

class ProfileView extends StatefulWidget {
  final VoidCallback signOut;
  const ProfileView(this.signOut, {Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const ProfileView(this.signOut, {super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  var appBarHeight = AppBar().preferredSize.height;
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
  String? namaSiswa;
  String? namaJurusan;
  String? namaKelas;
  int presentaseKehadiran = 0;
  double kehadiran = 0;
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
      var kelasData = siswaData['kelas'];
      var jurusanData = siswaData['jurusan'];
      if (siswaData['nis'] != null) {
        setState(() {
          namaSiswa = siswaData['nama_siswa'].toString().toUpperCase();
          namaKelas = kelasData['nama_kelas'].toString();
          namaJurusan = jurusanData['nama_jurusan'].toString();
          // print(nama);
          // print('Nama Kelas: $presentaseKehadiran');
        });
      }
    } else {
      // print(idSiswa);
    }
    setState(() {
      loading = false;
    });
  }

  final tabs = ['Profile', 'Data Diri', 'Orang Tua', 'Wali'];
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
        length: 4,
        child: NestedScrollView(
          physics: const ClampingScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: size.height * .15,
                      decoration: BoxDecoration(
                        color: AppColors.fiveColor,
                      ),
                    ),
                    SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: size.height * 0.09,
                                ),
                                Wrap(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ClipOval(
                                          child: Image.asset(
                                            'assets/images/avatar.png',
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.asset(
                                            'assets/images/qrcode.jpeg',
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                _buildTitle('${namaSiswa}'),
                                _buildTitleData('${namaJurusan}'),
                                _buildTitleData('${namaKelas}'),
                                SizedBox(height: size.height * 0.01),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        // Aksi yang dilakukan ketika tombol ditekan
                                        print('Ubah Foto Profil');
                                      },
                                      child: Text('Ubah Foto Profil'),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 2),
                                      ),
                                    ),
                                    OutlinedButton(
                                      onPressed: () {
                                        // Aksi yang dilakukan ketika tombol ditekan
                                        print('Ubah Data diri');
                                      },
                                      child: Text('Ubah Data Diri'),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 2),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverPersistentHeader(
                delegate: TabSliverDelegate(
                  TabBar(
                    // labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    // indicatorColor: Colors.white,
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
                              child: Text(
                                e,
                                style: TextStyle(fontSize: 12),
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
              Container(
                color: AppColors.backgroundColor2,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: ProfileScreen(widget.signOut)),
              ),
              Container(
                color: AppColors.backgroundColor2,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: DataDiriScreen(widget.signOut)),
              ),
              Container(
                color: AppColors.backgroundColor2,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: OrangTuaScreen(widget.signOut)),
              ),
              Container(
                color: AppColors.backgroundColor2,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: WaliScreen(widget.signOut)),
              ),
            ],
          ),
        ),
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
        fontSize: 16,
        color: Colors.black,
      ),
    ),
  );
}

Widget _buildTitleData(String text) {
  return Container(
    // padding: const EdgeInsets.only(bottom: 5),
    // width: double.maxFinite,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black,
      ),
    ),
  );
}
