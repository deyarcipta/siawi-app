import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'package:siawi_app/app/widgets/splash.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await FlutterDownloader.initialize(
  //     debug:
  //         true // Setel nilai debug menjadi false saat aplikasi sudah siap untuk produksi
  //     );
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return GetMaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: "Application",
    //   initialRoute: Routes.LOGIN,
    //   getPages: AppPages.routes,
    // );
    // ignore: dead_code
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 4)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Application",
            initialRoute: Routes.LOGIN,
            getPages: AppPages.routes,
          );
        }
      },
    );
  }
}
