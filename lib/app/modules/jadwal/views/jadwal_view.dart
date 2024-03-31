import 'package:flutter/material.dart';
import 'package:siawi_app/app/models/jadwal.dart';
import 'package:siawi_app/app/modules/jadwal/widget/jadwal_list.dart';

// import 'package:get/get.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:siawi_app/utils/tab_silver_delegate.dart';

// import '../controllers/jadwal_controller.dart';

class JadwalView extends StatefulWidget {
  const JadwalView({Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const JadwalView(this.signOut, {super.key});

  @override
  State<JadwalView> createState() => _JadwalViewState();
}

class _JadwalViewState extends State<JadwalView> {
  var appBarHeight = AppBar().preferredSize.height;

  final senin = Jadwal.generateSenin();
  final selasa = Jadwal.generateSelasa();
  final rabu = Jadwal.generateRabu();
  final kamis = Jadwal.generateKamis();
  final jumat = Jadwal.generateJumat();

  final tabs = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
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
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
                            children: [
                              _buildTitle('Jadwal Mata Pelajaran'),
                              _buildTitleData(
                                  'Teknik Jaringan Komputer & Telekomunikasi'),
                              _buildTitleData('XII TKJ'),
                              // ),
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
              JadwalList('Senin', senin),
              JadwalList('Selasa', selasa),
              JadwalList('Rabu', rabu),
              JadwalList('Kamis', kamis),
              JadwalList('Jumat', jumat),
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
        fontSize: 14,
        color: Colors.white,
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
        color: Colors.white,
      ),
    ),
  );
}
