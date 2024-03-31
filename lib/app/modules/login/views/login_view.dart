import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:siawi_app/app/modules/home/views/MyHomePage.dart';
// import 'package:siawi_app/app/modules/home/views/home_view.dart';
import 'package:siawi_app/utils/colors.dart';

import '../controllers/login_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginSiawi(),
    );
  }
}

class LoginSiawi extends StatefulWidget {
  const LoginSiawi({super.key});

  @override
  State<LoginSiawi> createState() => _LoginSiawiState();
}

_launchURL() async {
  final url = Uri.parse(
    'https://wa.me/6285172331507?text=Halo%20nama%20saya%20ilham%20kelas%20XII-TJKT%20saya%20lupa%20password%20login%20sistem%20informasi%20akademik%20wisata%20indonesia.',
  );
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}

class _LoginSiawiState extends State<LoginSiawi> {
  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
        children: [
          Image.asset(
            "assets/logo/logo-login.png",
            width: 300,
            height: 300,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "SISTEM INFORMASI AKADEMIK",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mainColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "WISATA INDONESIA",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mainColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: SizedBox(
                  height: 72,
                  width: 320,
                  //apply padding to all four sides
                  child: TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.all(0),
                      hintText: "NIS",
                      prefixIcon: Container(
                        padding: const EdgeInsets.only(left: 20, right: 15),
                        child: Icon(
                          Icons.email,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          width: 2,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: SizedBox(
                  height: 50,
                  width: 320, //apply padding to all four sides
                  child: TextFormField(
                    // validator: (e) {
                    //   if (e!.isEmpty) {
                    //     return "Please insert password";
                    //   }
                    // },
                    obscureText: _secureText,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.all(0),
                      hintText: "Password",
                      suffixIcon: IconButton(
                        onPressed: showHide,
                        icon: Icon(_secureText
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.only(left: 20, right: 15),
                        child: Icon(
                          Icons.lock,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          width: 2,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Container(
                  height: 25,
                  width: 330,
                  alignment: Alignment.topRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text(
                      'Lupa Password ?',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: _launchURL,
                    // onPressed: () {
                    //   launcher.launchUrl(
                    //     Uri.parse("https://smkwisataindonesia.sch.id"),
                    //     mode: launcher.LaunchMode.externalApplication,
                    //   );
                    // },
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    fixedSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                        //to set border radius to button
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    "MASUK",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
