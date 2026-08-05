// import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:siawi_app/app/modules/home/views/home_view.dart';
// import 'package:get/get.dart';
// import 'package:siawi_app/app/modules/informasi/views/informasi_view.dart';
import 'package:siawi_app/utils/colors.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

class _BottomViewState extends StatefulWidget {
  final VoidCallback signOut;
  const _BottomViewState(this.signOut);
  // final VoidCallback signOut;
  // const _BottomViewState(this.signOut, {super.key});

  @override
  State<_BottomViewState> createState() => __BottomViewStateState();
}

class __BottomViewStateState extends State<_BottomViewState> {
  void SignOut() {
    setState(() {
      widget.signOut();
    });
  }

  int _selectedTabIndex = 2;

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  var appBarHeight = AppBar().preferredSize.height;

  @override
  Widget build(BuildContext context) {
    final listPage = <Widget>[
      const Text('test1'),
      const Text('test2'),
      // const HomeView(),
      const Text('test3'),
      const Text('test3'),
    ];
    final BottomNavBarItems = <BottomNavigationBarItem>[
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

    final bottomNavBar = BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.secondColor,
      items: BottomNavBarItems,
      currentIndex: _selectedTabIndex,
      unselectedItemColor: Colors.white54,
      selectedItemColor: Colors.white,
      onTap: _onNavBarTapped,
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: listPage[_selectedTabIndex],
      ),
      bottomNavigationBar: bottomNavBar,
    );
  }
}
