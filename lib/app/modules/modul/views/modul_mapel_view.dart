import 'package:flutter/material.dart';

// import 'package:get/get.dart';
import 'package:siawi_app/app/modules/modul/views/detail_modul_view.dart';
import 'package:siawi_app/app/modules/modul/widget/modul_list.dart';
import 'package:siawi_app/utils/colors.dart';

// import '../controllers/modul_controller.dart';

class ModulMapelView extends StatefulWidget {
  const ModulMapelView({super.key});
  // final List<Map<String, List<Map<String, String>>>> teams;
  // ModulMapelView({required this.teams});

  @override
  State<ModulMapelView> createState() => _ModulMapelViewState();
}

class _ModulMapelViewState extends State<ModulMapelView> {
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: ListView.builder(
          itemCount: teams.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(teams[index]['name']! as String),
                shape: RoundedRectangleBorder(
                  // side: BorderSide(width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                tileColor: AppColors.thirdColor,
                leading: Image.asset(
                  "assets/icon/modul.png",
                  width: 25,
                  height: 25,
                ),
                trailing: Icon(Icons.arrow_forward_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailModulView(players: teams[index]['players']!),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}


// class ModulMapelView extends GetView<ModulController> {
//   const ModulMapelView({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ModulMapelView'),
//         centerTitle: true,
//       ),
//       body: ListView.builder(
//         itemCount: parentList.length,
//         itemBuilder: (context, index) {
//           var parent = parentList[index].keys.first;
//           return ListTile(
//             title: Text(parent),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       DetailPage(dataList: parentList[index][parent]),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
