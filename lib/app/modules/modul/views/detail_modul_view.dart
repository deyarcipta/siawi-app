import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/modul/views/modul_view.dart';
import 'package:siawi_app/utils/colors.dart';

class DetailModulView extends StatefulWidget {
  // const DetailModulView(this.dataList,{super.key});
  final List<Map<String, dynamic>> players;

  DetailModulView({required this.players});

  @override
  State<DetailModulView> createState() => _DetailModulViewState();
}

class _DetailModulViewState extends State<DetailModulView> {
  List<Map<String, dynamic>> _players = [];

  @override
  void initState() {
    super.initState();
    _players = widget.players;
  }

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
          itemCount: _players.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(_players[index]['name']!),
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
                      builder: (context) => ModulView(player: _players[index]),
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
