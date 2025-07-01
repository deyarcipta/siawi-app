import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:siawi_app/utils/colors.dart';
// import '../controllers/tagihan_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class TagihanView extends StatefulWidget {
  final VoidCallback signOut;
  const TagihanView(this.signOut, {Key? key}) : super(key: key);
  @override
  _TagihanViewState createState() => _TagihanViewState();
}

class _TagihanViewState extends State<TagihanView> {
  WebViewController? _controller;
  String? nis;
  bool isLoading = true; // Track loading state

  Future<String?> getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? nis = preferences.getString('nis');
    return nis;
  }

  String? linkTagihan;
  Future<void> _fetchTagihan() async {
    final response =
        await http.get(Uri.parse('http://103.75.209.90/api/tagihan'));
    if (response.statusCode == 200) {
      var tagihan = json.decode(response.body);
      var tagihanData = tagihan['data'];
      setState(() {
        linkTagihan = tagihanData['link'].toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    await _fetchTagihan();
    String? nisValue = await getIdSiswa();
    setState(() {
      nis = nisValue;
    });

    if (nis != null) {
      print('gimana hasilnya : $linkTagihan');
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {},
            onPageStarted: (String url) {
              setState(() {
                isLoading = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse('$linkTagihan$nis'));
    }
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
      body: Stack(
        children: [
          WebViewWidget(controller: _controller ?? WebViewController()),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
