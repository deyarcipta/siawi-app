import 'package:flutter/material.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;

class DetailInformasi extends StatelessWidget {
  late String fileURL;

  DetailInformasi({required this.fileURL}) {
    // Encode the URL after initializing the value
    this.fileURL = Uri.encodeComponent(fileURL);
  }

  var appBarHeight = AppBar().preferredSize.height;

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<void>(
        future: _checkPdfUrl(fileURL),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load PDF'));
          } else {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: SfPdfViewer.network(
                        'http://103.75.209.90/storage/file-informasi/$fileURL',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _checkPdfUrl(String url) async {
    final response = await http
        .head(Uri.parse('http://103.75.209.90/storage/file-informasi/$url'));
    if (response.statusCode != 200) {
      throw Exception('PDF not found');
    }
  }
}
