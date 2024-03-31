import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:siawi_app/app/modules/absensi/widget/absen_list.dart';
// import 'package:siawi_app/app/modules/absensi/widget/absen.dart';
import 'package:siawi_app/utils/colors.dart';

// import 'package:get/get.dart';

// import '../controllers/absensi_controller.dart';

class AbsensiView extends StatefulWidget {
  const AbsensiView({Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const AbsensiView(this.signOut, {super.key});

  @override
  State<AbsensiView> createState() => _AbsensiViewState();
}

class _AbsensiViewState extends State<AbsensiView> {
  var appBarHeight = AppBar().preferredSize.height;

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
      body: SingleChildScrollView(
        child: Wrap(
          children: <Widget>[
            SafeArea(
              child: Container(
                height: size.height * .25,
                decoration: BoxDecoration(
                  color: AppColors.fiveColor,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircularPercentIndicator(
                        animation: true,
                        radius: 60.0,
                        lineWidth: 10.0,
                        percent: 0.9,
                        center: new Text(
                          "90",
                          style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 26.0,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: AppColors.mainColor,
                        progressColor: AppColors.thirdColor,
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          _buildTitle('ILHAM MUHAMMAD ALAMSYAH'),
                          Container(
                            width: size.width * 0.5,
                            // child: Padding(
                            // padding: EdgeInsets.only(right: 100),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    _buildTitleData('Hadir'),
                                    _buildData(': 90'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildTitleData('Sakit'),
                                    _buildData(': 3'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildTitleData('Izin'),
                                    _buildData(': 2'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildTitleData('Alfa'),
                                    _buildData(': 5'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildTitleData('Tidak Hadir'),
                                    _buildData(': 10'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                children: <Widget>[
                  Text(
                    "Data Kehadiran",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: myData.map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        // side: BorderSide(width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      tileColor: AppColors.thirdColor,
                      leading: Image.asset(
                        item.img,
                        width: 25,
                        height: 25,
                      ),
                      title: Text(item.tanggal),
                      titleTextStyle: TextStyle(
                          fontSize: 10,
                          color: AppColors.sixColor,
                          fontWeight: FontWeight.w500),
                      subtitle: Text(item.keterangan),
                      subtitleTextStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      trailing: Container(
                        width: 15, // Lebar lingkaran
                        height: 15, // Tinggi lingkaran
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // Mengatur bentuk lingkaran
                          color: item.warna, // Mengatur warna lingkaran
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTitle(String text) {
  return Container(
    width: 200,
    padding: const EdgeInsets.only(top: 25),
    child: Text(
      text,
      maxLines: 2,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Colors.white,
      ),
    ),
  );
}

Widget _buildTitleData(String text) {
  return Container(
    width: 65,
    padding: const EdgeInsets.only(bottom: 8),
    // width: double.maxFinite,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.white,
      ),
    ),
  );
}

Widget _buildData(String text) {
  return Container(
    width: 50,
    padding: const EdgeInsets.only(bottom: 8),
    // width: double.maxFinite,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.white,
      ),
    ),
  );
}
