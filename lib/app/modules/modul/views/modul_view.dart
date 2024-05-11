import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/modul/widget/modul_list.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ModulView extends StatefulWidget {
  final ModulItem modul;

  ModulView(this.modul);

  @override
  State<ModulView> createState() => _ModulViewState();
}

class _ModulViewState extends State<ModulView> {
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
                height: size.height * .1,
                width: size.width,
                decoration: BoxDecoration(
                  color: AppColors.fiveColor,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.modul.namaModul ?? 'No data available'}',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
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
            ),
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SfPdfViewer.network(
                  'http://203.194.113.46/storage/file_modul/${widget.modul.fileModul}'),
            ),
          ],
        ),
      ),
    );
  }
}
