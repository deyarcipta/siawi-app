import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/modules/about/views/about_view.dart';
import 'package:siawi_app/app/modules/home/views/home_view.dart';
import 'package:siawi_app/app/modules/jadwal/views/jadwal_view.dart';
import 'package:siawi_app/app/modules/modul/views/modul_mapel_view.dart';
import 'package:siawi_app/app/modules/point_siswa/views/point_siswa_view.dart';
import 'package:siawi_app/app/modules/profile/views/profile_view.dart';
import 'package:get/get.dart';
import 'package:siawi_app/app/modules/tagihan/views/tagihan_view.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/app/data/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:siawi_app/app/routes/app_pages.dart';

class MyHomePage extends StatefulWidget {
  final VoidCallback signOut;
  final String? initialRole;
  static String activeRole = 'siswa';
  const MyHomePage(this.signOut, {super.key, this.initialRole});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _showBottomNavBar = true;
  void _toggleBottomNavBar(bool show) {
    setState(() {
      _showBottomNavBar = show;
    });
  }

  Future<void> SignOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt("value", 0);
    await preferences.remove("role");
    await preferences.remove("namaOrtu");
    await preferences.remove("idOrangTua");
    await preferences.remove("childrenJson");
    MyHomePage.activeRole = 'siswa';
    setState(() {
      _showBottomNavBar = false;
      widget.signOut();
    });
    Get.offAllNamed(Routes.LOGIN);
  }

  String idSiswa = "";
  late String role;

  Future<void> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        idSiswa = preferences.getString("idSiswa") ?? "";
        role = preferences.getString("role") ?? "siswa";
        MyHomePage.activeRole = role;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    role = widget.initialRole ?? MyHomePage.activeRole;
    getPref().then((_) {
      if (idSiswa.isNotEmpty) {
        _initFirebaseMessaging();
      }
    });
  }

  Future<void> _initFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    try {
      String? token = await messaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        _sendTokenToServer(token);
      }

      messaging.onTokenRefresh.listen((newToken) {
        _sendTokenToServer(newToken);
      });
    } catch (e) {
      print('Error getting FCM Token: $e');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        Get.snackbar(
          message.notification!.title ?? 'Notifikasi',
          message.notification!.body ?? '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.mainColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(15),
          borderRadius: 15,
        );
      }
    });
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      final jsonResponse = await ApiService.post('/update-fcm-token', {
        'idSiswa': idSiswa,
        'fcm_token': token,
      });
      if (jsonResponse != null) {
        print('FCM Token successfully synced with server');
      }
    } catch (e) {
      print('Error syncing FCM Token to server: $e');
    }
  }

  int _selectedIndex = 2;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final isFirstRouteInCurrentTab =
            !await _navigatorKey.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_selectedIndex != 0) {
            setState(() {
              _selectedIndex = 0;
            });
          } else {
            await SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: Navigator(
          key: _navigatorKey,
          onGenerateRoute: (routeSettings) {
            WidgetBuilder builder;
            switch (routeSettings.name) {
              case '/profile':
                builder = (BuildContext context) => ProfileView(SignOut);
                break;
              case '/tagihan':
                builder = (BuildContext context) => TagihanView(SignOut);
                break;
              case '/jadwal':
                builder = (BuildContext context) => JadwalView(SignOut);
                break;
              case '/modul':
                builder = (BuildContext context) => ModulMapelView(signOut: SignOut);
                break;
              case '/':
                builder = (BuildContext context) =>
                    HomeView(SignOut, toggleBottomNavBar: _toggleBottomNavBar, initialRole: role);
                break;
              case '/point':
                builder = (BuildContext context) => PointSiswaView(SignOut);
                break;
              case '/about':
                builder = (BuildContext context) => const AboutView();
                break;
              default:
                throw Exception('Invalid route: ${routeSettings.name}');
            }
            return MaterialPageRoute(builder: builder, settings: routeSettings);
          },
        ),
        bottomNavigationBar: _showBottomNavBar
            ? BottomNavigationBar(
                items: role == "orang_tua"
                    ? const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person_outlined),
                          label: "Profile",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.account_balance_wallet_outlined),
                          label: "Tagihan",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: "Home",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.rule_outlined),
                          label: "Point",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.info_outline),
                          label: "About",
                        )
                      ]
                    : const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person_outlined),
                          label: "Profile",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.calendar_month_outlined),
                          label: "Jadwal",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: "Home",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.menu_book_outlined),
                          label: "Modul",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.info_outline),
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
                    if (role == "orang_tua") {
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
                    } else {
                      switch (index) {
                        case 0:
                          _navigatorKey.currentState!.pushNamed('/profile');
                          break;
                        case 1:
                          _navigatorKey.currentState!.pushNamed('/jadwal');
                          break;
                        case 2:
                          _navigatorKey.currentState!.pushNamed('/');
                          break;
                        case 3:
                          _navigatorKey.currentState!.pushNamed('/modul');
                          break;
                        case 4:
                          _navigatorKey.currentState!.pushNamed('/about');
                          break;
                      }
                    }
                  });
                },
              )
            : null, // Hapus BottomNavigationBar jika _showBottomNavBar adalah false
      ),
    );
  }
}
