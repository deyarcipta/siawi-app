import 'package:flutter/material.dart';

// import 'package:get/get.dart';
import 'package:siawi_app/app/modules/profile/widget/data_diri.dart';
import 'package:siawi_app/app/modules/profile/widget/orang_tua.dart';
import 'package:siawi_app/app/modules/profile/widget/profil.dart';
import 'package:siawi_app/app/modules/profile/widget/wali.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:siawi_app/utils/tab_silver_delegate.dart';

// import '../controllers/profile_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const ProfileView(this.signOut, {super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  var appBarHeight = AppBar().preferredSize.height;
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
                                            'assets/images/avatar.jpg',
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
                                _buildTitle('ILHAM MUHAMMAD ALAMSYAH'),
                                _buildTitleData(
                                    'Teknik Jaringan Komputer & Telekomunikasi'),
                                _buildTitleData('XII TKJ'),
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
                    child: ProfileScreen()),
              ),
              Container(
                color: AppColors.backgroundColor2,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: DataDiriScreen()),
              ),
              Container(
                color: AppColors.backgroundColor2,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: OrangTuaScreen()),
              ),
              Container(
                color: AppColors.backgroundColor2,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: WaliScreen()),
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
