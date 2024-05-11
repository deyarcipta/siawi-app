import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/rapot/widget/rapot_list.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DetailRapot extends StatelessWidget {
  final RapotList rapot;

  DetailRapot(this.rapot) {
    rapot.fileRapot = Uri.encodeComponent(rapot.fileRapot);
  }
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
        child: Column(
          children: <Widget>[
            Container(
              color: AppColors.fiveColor,
              height: size.height * .08,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Semester ${rapot.semester}',
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.white,
                      ),
                    ),
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.download,
                    //     size: 20,
                    //     color: AppColors.white,
                    //   ),
                    //   onPressed: null,
                    // ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SfPdfViewer.network(
                  'http://203.194.113.46/storage/file_rapot/${rapot.fileRapot}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
