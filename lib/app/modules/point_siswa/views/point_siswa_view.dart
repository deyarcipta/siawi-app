import 'package:flutter/material.dart';

// import 'package:get/get.dart';
import 'package:siawi_app/app/modules/point_siswa/widget/point_list.dart';
import 'package:siawi_app/utils/colors.dart';

// import '../controllers/point_siswa_controller.dart';

class PointSiswaView extends StatefulWidget {
  const PointSiswaView({Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const PointSiswaView(this.signOut, {super.key});

  @override
  State<PointSiswaView> createState() => _PointSiswaViewState();
}

class _PointSiswaViewState extends State<PointSiswaView> {
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
                width: double.infinity,
                height: size.height * .29,
                decoration: BoxDecoration(
                  color: AppColors.fiveColor,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 25),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/avatar.jpg',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      _buildTitle('ILHAM MUHAMMAD ALAMSYAH'),
                      _buildTitleData(
                          'Teknik Jaringan Komputer & Telekomunikasi'),
                      _buildTitleData('XII TKJ'),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Point Pelanggaran Siswa",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: 'Total Point : '),
                            TextSpan(
                                text: '100',
                                style: TextStyle(color: Colors.red))
                          ],
                        ),
                      ),
                    ],
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.keterangan,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            item.point,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                      // subtitle: Text(item.keterangan),
                      // subtitleTextStyle: TextStyle(
                      //   fontSize: 14,
                      //   fontWeight: FontWeight.w500,
                      //   color: Colors.black,
                      // ),
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
    padding: const EdgeInsets.only(top: 10),
    child: Text(
      text,
      maxLines: 2,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
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
