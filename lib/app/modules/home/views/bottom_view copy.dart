// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/home/views/home_view.dart';
// import 'package:get/get.dart';
import 'package:siawi_app/app/modules/informasi/views/informasi_view.dart';
import 'package:siawi_app/utils/colors.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

class _BottomViewState extends StatefulWidget {
  const _BottomViewState({Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const _BottomViewState(this.signOut, {super.key});

  @override
  State<_BottomViewState> createState() => __BottomViewStateState();
}

class __BottomViewStateState extends State<_BottomViewState> {
  int _selectedTabIndex = 2;

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  var appBarHeight = AppBar().preferredSize.height;

  @override
  Widget build(BuildContext context) {
    final _listPage = <Widget>[
      const Text('test1'),
      const Text('test2'),
      const HomeView(),
      const InformasiView(),
      const Text('test3'),
    ];
    final _BottomNavBarItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outlined),
        label: "Profile",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.book),
        label: "Tagihan",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Home",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.balance),
        label: "Point",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: "Setting",
      )
    ];

    final _bottomNavBar = BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.secondColor,
      items: _BottomNavBarItems,
      currentIndex: _selectedTabIndex,
      unselectedItemColor: Colors.white54,
      selectedItemColor: Colors.white,
      onTap: _onNavBarTapped,
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: _listPage[_selectedTabIndex],
      ),
      bottomNavigationBar: _bottomNavBar,
    );
  }
}
