import 'package:flutter/material.dart';

// import 'package:get/get.dart';
// import 'package:siawi_app/app/modules/home/views/home_view.dart';
import 'package:siawi_app/app/modules/informasi/widget/informasi.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:accordion/accordion.dart';

// import '../controllers/informasi_controller.dart';

class InformasiView extends StatefulWidget {
  const InformasiView({Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const HomeView(this.signOut, {super.key});

  @override
  State<InformasiView> createState() => _InformasiViewState();
}

class _InformasiViewState extends State<InformasiView> {
  var appBarHeight = AppBar().preferredSize.height;

  List<Informasi> display_list = List.from(Informasi.informasiData);

  void updateList(String value) {
    // seacrh
    setState(() {
      display_list = Informasi.informasiData
          .where((element) =>
              element.title!.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
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
                      hintText: 'Cari Inforsmasi',
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
                  itemCount: display_list.length,
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
                              '${display_list[index].title}',
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
                                          "Pelaksanaan ${display_list[index].title} diadakan pada : ",
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "Hari : ${display_list[index].hari}",
                                        ),
                                        Text(
                                          "Tanggal : ${display_list[index].tanggal}",
                                        ),
                                        Text(
                                          "Syarat : ${display_list[index].syarat}",
                                        ),
                                      ]),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.download),
                                  tooltip: 'Increase volume by 10',
                                  onPressed: () {
                                    setState(() {
                                      print('berhasil');
                                    });
                                  },
                                ),
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
