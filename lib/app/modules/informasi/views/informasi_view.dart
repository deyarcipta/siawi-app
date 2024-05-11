import 'dart:convert';
// import 'dart:io'; // Import dart:io untuk menggunakan kelas Directory

import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:siawi_app/app/modules/informasi/widget/informasi.dart';
import 'package:siawi_app/app/modules/informasi/views/detail_informasi.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:accordion/accordion.dart';
import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';

class InformasiView extends StatefulWidget {
  final VoidCallback signOut;
  const InformasiView(this.signOut, {Key? key}) : super(key: key);

  @override
  State<InformasiView> createState() => _InformasiViewState();
}

class _InformasiViewState extends State<InformasiView> {
  var appBarHeight = AppBar().preferredSize.height;

  List<Informasi> informasiList = [];

  @override
  void initState() {
    super.initState();
    _fetchInformasi();
  }

  Future<void> _fetchInformasi() async {
    final response =
        await http.get(Uri.parse('http://203.194.113.46/api/informasi'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> informasiData = responseData['data'];
      setState(() {
        informasiList.clear();
        for (var item in informasiData) {
          Informasi informasi = Informasi.fromJson(item);
          informasiList.add(informasi);
        }
      });
    } else {
      print('Failed to load informasi');
    }
  }

  void updateList(String value) {
    setState(() {
      informasiList = informasiList
          .where((element) =>
              element.informasi.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  void _openPDFViewer(String fileURL) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailInformasi(fileURL: fileURL),
      ),
    );
  }

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
        child: Stack(
          children: <Widget>[
            Column(
              children: [
                Container(
                  margin: EdgeInsets.all(16),
                  child: TextFormField(
                    style: TextStyle(
                      color: AppColors.mainColor,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      filled: true,
                      fillColor: AppColors.thirdColor,
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Cari Informasi',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: AppColors.secondColor,
                        ),
                      ),
                    ),
                    onChanged: (value) => updateList(value),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: informasiList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      child: Accordion(
                        paddingListTop: 5,
                        paddingListBottom: 5,
                        paddingListHorizontal: 12,
                        headerBorderColor: Colors.black,
                        headerBorderColorOpened: Colors.black,
                        headerBackgroundColor: AppColors.fourColor,
                        headerBackgroundColorOpened: AppColors.fourColor,
                        contentBackgroundColor: AppColors.thirdColor,
                        contentBorderColor: AppColors.thirdColor,
                        contentBorderWidth: 3,
                        scaleWhenAnimating: true,
                        openAndCloseAnimation: true,
                        rightIcon: Icon(Icons.keyboard_arrow_down,
                            color: Colors.black, size: 22),
                        headerPadding: const EdgeInsets.symmetric(
                            vertical: 7, horizontal: 15),
                        children: [
                          AccordionSection(
                            isOpen: false,
                            contentVerticalPadding: 10,
                            leftIcon: const Icon(Icons.info_outline_rounded,
                                color: Colors.black),
                            header: Text(
                              '${informasiList[index].informasi}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: size.width * 0.7,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Pelaksanaan ${informasiList[index].informasi} diadakan pada : ",
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "Hari : ${informasiList[index].hari}",
                                        ),
                                        Text(
                                          "Tanggal : ${informasiList[index].tanggalAwal}",
                                        ),
                                        Text(
                                          "Silakan Download File Edaran Untuk Informasi Lebih Lanjut",
                                        ),
                                      ]),
                                ),
                                InkWell(
                                  onTap: () {
                                    _openPDFViewer(informasiList[index].file);
                                  },
                                  child: Icon(Icons.picture_as_pdf),
                                ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
