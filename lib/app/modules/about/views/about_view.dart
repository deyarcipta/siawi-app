import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/about/widget/about.dart';
import 'package:siawi_app/utils/colors.dart';

class AboutView extends StatefulWidget {
  const AboutView({Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const AboutView(this.signOut, {super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  var appBarHeight = AppBar().preferredSize.height;
  List<About> display_list = List.from(About.aboutData);

  void updateList(String value) {
    // seacrh
    setState(() {
      display_list = About.aboutData
          .where((element) =>
              element.title!.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

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
        child: Stack(
          children: <Widget>[
            Column(
              children: [
                SizedBox(height: 10),
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
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${display_list[index].tentang}",
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
