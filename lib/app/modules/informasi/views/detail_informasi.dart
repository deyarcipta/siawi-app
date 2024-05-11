import 'package:flutter/material.dart';
// import 'package:siawi_app/app/modules/informasi/widget/informasi.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// ignore: must_be_immutable
class DetailInformasi extends StatelessWidget {
  late String fileURL;

  DetailInformasi({required this.fileURL}) {
    // Lakukan encoding URL di sini setelah nilai fileURL diinisialisasi
    this.fileURL = Uri.encodeComponent(fileURL);
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SfPdfViewer.network(
                  'http://203.194.113.46/storage/file-informasi/$fileURL',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
