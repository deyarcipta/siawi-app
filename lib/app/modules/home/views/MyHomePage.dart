// import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/about/views/about_view.dart';
import 'package:siawi_app/app/modules/home/views/home_view.dart';
import 'package:siawi_app/app/modules/point_siswa/views/point_siswa_view.dart';
import 'package:siawi_app/app/modules/profile/views/profile_view.dart';
// import 'package:get/get.dart';
// import 'package:siawi_app/app/modules/informasi/views/informasi_view.dart';
import 'package:siawi_app/app/modules/tagihan/views/tagihan_view.dart';
import 'package:siawi_app/utils/colors.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 2;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKey.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_selectedIndex != 0) {
            setState(() {
              _selectedIndex = 0;
            });
            return false;
          }
        }
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Navigator(
          key: _navigatorKey,
          onGenerateRoute: (routeSettings) {
            WidgetBuilder builder;
            switch (routeSettings.name) {
              case '/profile':
                builder = (BuildContext context) => ProfileView();
                break;
              case '/tagihan':
                builder = (BuildContext context) => TagihanView();
                break;
              case '/':
                builder = (BuildContext context) => HomeView();
                break;
              case '/point':
                builder = (BuildContext context) => PointSiswaView();
                break;
              case '/about':
                builder = (BuildContext context) => AboutView();
                break;
              default:
                throw Exception('Invalid route: ${routeSettings.name}');
            }
            return MaterialPageRoute(builder: builder, settings: routeSettings);
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              label: "Profile",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: "Tagihan",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.balance),
              label: "Point",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: "About",
            )
          ],
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.secondColor,
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.white54,
          selectedItemColor: Colors.white,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              switch (index) {
                case 0:
                  _navigatorKey.currentState!.pushNamed('/profile');
                  break;
                case 1:
                  _navigatorKey.currentState!.pushNamed('/tagihan');
                  break;
                case 2:
                  _navigatorKey.currentState!.pushNamed('/');
                  break;
                case 3:
                  _navigatorKey.currentState!.pushNamed('/point');
                  break;
                case 4:
                  _navigatorKey.currentState!.pushNamed('/about');
                  break;
              }
            });
          },
        ),
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           _buildOffstageNavigator(0),
//           _buildOffstageNavigator(1),
//           _buildOffstageNavigator(2),
//           _buildOffstageNavigator(3),
//           _buildOffstageNavigator(4),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outlined),
//             label: "Profile",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.book),
//             label: "Tagihan",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: "Home",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.balance),
//             label: "Point",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: "Setting",
//           )
//         ],
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: AppColors.secondColor,
//         currentIndex: _selectedIndex,
//         unselectedItemColor: Colors.white54,
//         selectedItemColor: Colors.white,
//         // selectedItemColor: Colors.blue,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildOffstageNavigator(int tabIndex) {
//     return Offstage(
//       offstage: _selectedIndex != tabIndex,
//       child: Navigator(
//         onGenerateRoute: (routeSettings) {
//           return MaterialPageRoute(
//             builder: (context) {
//               switch (tabIndex) {
//                 case 0:
//                   return const HomeView();
//                 case 1:
//                   return const TagihanView();
//                 case 2:
//                   return const HomeView();
//                 case 3:
//                   return const HomeView();
//                 case 4:
//                   return const HomeView();
//                 default:
//                   return const HomeView();
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
// }
