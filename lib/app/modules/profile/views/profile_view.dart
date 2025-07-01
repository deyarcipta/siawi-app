import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg
import 'package:siawi_app/app/modules/profile/views/edit_data_diri.dart';
import 'package:siawi_app/app/modules/profile/views/qrcode_view.dart';
import 'package:siawi_app/app/modules/profile/views/upload_foto.dart';
import 'package:siawi_app/app/modules/profile/widget/data_diri.dart';
import 'package:siawi_app/app/modules/profile/widget/orang_tua.dart';
import 'package:siawi_app/app/modules/profile/widget/profil.dart';
import 'package:siawi_app/app/modules/profile/widget/wali.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:siawi_app/utils/tab_silver_delegate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileView extends StatefulWidget {
  final VoidCallback signOut;
  const ProfileView(this.signOut, {Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  var appBarHeight = AppBar().preferredSize.height;

  Future<String?> getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('idSiswa');
  }

  @override
  void initState() {
    super.initState();
    getIdSiswa().then((idSiswa) {
      if (idSiswa != null) {
        _lihatData(idSiswa);
        // fetchQRCode();
      }
    });
  }

  void SignOut() {
    setState(() {
      widget.signOut();
    });
  }

  String idSiswa = "";
  String? qrCodeSvg; // Store SVG data as a string
  bool loading = false;
  String? namaSiswa;
  String? namaJurusan;
  String? namaKelas;
  String? nis;
  String? fileFoto;

  Future<void> _lihatData(String idSiswa) async {
    setState(() {
      loading = true;
    });
    final response =
        await http.get(Uri.parse('http://103.75.209.90/api/home/$idSiswa'));

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
          fileFoto = siswaData['foto']?.toString();
          nis = siswaData['nis']?.toString();
        });
        fetchQRCode();
      }
    } else {
      // Handle error
      print('Error fetching data: ${response.statusCode}');
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> fetchQRCode() async {
    try {
      final response = await http.get(
        Uri.parse('http://103.75.209.90/api/generate-qrcode?data=$nis'),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Store the SVG data as a string
          qrCodeSvg = response.body;
        });
      } else {
        print('Failed to load QR Code');
      }
    } catch (e) {
      print('Error fetching QR Code: $e');
    }
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      radius: 45,
                                      child: fileFoto == null
                                          ? CircularProgressIndicator()
                                          : ClipOval(
                                              child: Image.network(
                                                'http://103.75.209.90/storage/foto-siswa/$fileFoto',
                                                fit: BoxFit.cover,
                                                width: 90,
                                                height: 90,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  } else {
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
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
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                    size: 26,
                                                  );
                                                },
                                              ),
                                            ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  QrCode(widget.signOut)),
                                        );
                                      },
                                      child: qrCodeSvg == null
                                          ? CircularProgressIndicator()
                                          : SvgPicture.string(
                                              qrCodeSvg!,
                                              width:
                                                  65, // Set your desired width
                                              height:
                                                  65, // Set your desired height
                                              fit: BoxFit.contain,
                                            ),
                                    ),
                                  ],
                                ),
                                _buildTitle('${namaSiswa ?? 'Loading...'}'),
                                _buildTitleData('${namaJurusan ?? ''}'),
                                _buildTitleData('${namaKelas ?? ''}'),
                                SizedBox(height: size.height * 0.01),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UploadFoto(SignOut)),
                                        );
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UbahDataDiriScreen(
                                                      widget.signOut)),
                                        );
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
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black,
      ),
    ),
  );
}
