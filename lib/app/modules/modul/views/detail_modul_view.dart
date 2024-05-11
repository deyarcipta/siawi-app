import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/modul/views/modul_view.dart';
import 'package:siawi_app/app/modules/modul/widget/modul_list.dart';
import 'package:siawi_app/utils/colors.dart';

class DetailModulView extends StatefulWidget {
  final List<ModulItem> modulItems;

  DetailModulView({required this.modulItems});

  @override
  State<DetailModulView> createState() => _DetailModulViewState();
}

class _DetailModulViewState extends State<DetailModulView> {
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
          itemCount: widget.modulItems.length,
          itemBuilder: (context, index) {
            var module = widget.modulItems[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(module.namaModul),
                shape: RoundedRectangleBorder(
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
                          ModulView(module), // Pass the module parameter
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
