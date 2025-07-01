import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:get/get.dart';
import 'package:siawi_app/app/modules/home/views/MyHomePage.dart';
import 'package:siawi_app/app/modules/login/views/lupa_password_view.dart';
// import 'package:siawi_app/app/modules/home/views/home_view.dart';
import 'package:siawi_app/utils/colors.dart';

// import 'package:fluttertoast/fluttertoast.dart';
import '../controllers/login_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends GetView<LoginController> {
  // const LoginView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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

enum LoginStatus { notSignIn, signIn }

class _LoginSiawiState extends State<LoginSiawi> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  late String nis, password;
  final _key = GlobalKey<FormState>();

  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form != null && form.validate()) {
      form.save();
      // print("$nis, $password");
      login();
    }
  }

  login() async {
    final response =
        await http.post(Uri.parse('http://103.75.209.90/api/login'), body: {
      'nis': nis,
      'password': password,
    });
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      if (jsonResponse['success']) {
        Fluttertoast.showToast(
          msg: 'Login Berhasil',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );

        var userData = jsonResponse['data'];
        int value = 1;
        var idSiswaAPI = userData['id_siswa'].toString();
        var nisApi = userData['nis'].toString();

        setState(() {
          _loginStatus = LoginStatus.signIn;
          savePref(value, idSiswaAPI, nisApi);
        });

        print('Berhasil login: $nisApi');
      } else {
        var errorMessage =
            jsonResponse['message'] ?? "Terjadi kesalahan saat login";

        Fluttertoast.showToast(
          msg: errorMessage,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );

        print('Gagal login: $errorMessage');
      }
    } else {
      // Tangani error selain 200, misalnya 401 atau 422
      var jsonResponse = json.decode(response.body);
      var errorMessage =
          jsonResponse['message'] ?? "Terjadi kesalahan pada server";

      Fluttertoast.showToast(
        msg: errorMessage, // Gunakan pesan dari server jika ada
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );

      print('Error ${response.statusCode}: $errorMessage');
    }
  }

  savePref(int value, String idSiswa, String nis) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt('value', value);
      preferences.setString('idSiswa', idSiswa);
      preferences.setString('nis', nis);
      // ignore: deprecated_member_use
      preferences.commit();
    });
  }

  // ignore: prefer_typing_uninitialized_variables
  var value;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");

      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  // ignore: non_constant_identifier_names
  SignOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", 0);
      // ignore: deprecated_member_use
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Form(
            key: _key,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
              children: [
                Image.asset(
                  "assets/logo/logo-login.png",
                  width: 300,
                  height: 300,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
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
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
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
                          validator: (e) {
                            if (e != null && e.isEmpty) {
                              return "Please insert nis";
                            }
                            return null;
                          },
                          onSaved: (e) => nis = e!,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.white,
                            contentPadding: const EdgeInsets.all(0),
                            hintText: "NIS",
                            prefixIcon: Container(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 15),
                              child: const Icon(
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
                          obscureText: _secureText,
                          onSaved: (e) => password = e!,
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
                              padding:
                                  const EdgeInsets.only(left: 20, right: 15),
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LupaPasswordView()),
                            );
                          },
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
                          check();
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
          ),
        );
      case LoginStatus.signIn:
        return MyHomePage(SignOut);
    }
  }

  Widget errmsg(String text) {
    //error message widget.
    return Container(
      padding: EdgeInsets.all(15.00),
      margin: EdgeInsets.only(bottom: 10.00),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.red,
          border: Border.all(color: Colors.red, width: 2)),
      child: Row(children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 6.00),
          child: Icon(Icons.info, color: Colors.white),
        ), // icon for error message

        Text(text, style: TextStyle(color: Colors.white, fontSize: 18)),
        //show error message text
      ]),
    );
  }
}
