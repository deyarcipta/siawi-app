import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app/routes/app_pages.dart';
import 'package:siawi_app/app/widgets/splash.dart';
// import 'package:siawi_app/app/widgets/version_checker.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/modules/home/views/MyHomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  try {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  } catch (e) {
    debugPrint("Error requesting notification permission: $e");
  }

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  SharedPreferences preferences = await SharedPreferences.getInstance();
  bool isLoggedIn = preferences.getInt('value') == 1;
  String savedRole = preferences.getString('role') ?? 'siswa';
  MyHomePage.activeRole = savedRole;

  runApp(MyApp(isLoggedIn: isLoggedIn, savedRole: savedRole));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String savedRole;
  const MyApp({super.key, this.isLoggedIn = false, this.savedRole = 'siswa'});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SIAWI",
      getPages: AppPages.routes,
      home: SplashScreen(
        onFinished: () {
          Get.offAllNamed(isLoggedIn ? Routes.HOME : Routes.LOGIN);
        },
      ),
    );
  }
}
