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
import 'package:siawi_app/app/data/api_service.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

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

Future<void> _launchURL() async {
  final url = Uri.parse(
    'https://wa.me/6285172331507?text=Halo%20nama%20saya%20ilham%20kelas%20XII-TJKT%20saya%20lupa%20password%20login%20sistem%20informasi%20akademik%20wisata%20indonesia.',
  );
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}

enum LoginStatus { notSignIn, signIn, loading }

class _LoginSiawiState extends State<LoginSiawi> {
  LoginStatus _loginStatus = LoginStatus.loading;
  late String nis, password;
  final _key = GlobalKey<FormState>();

  bool _secureText = true;

  void showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  void check() {
    final form = _key.currentState;
    if (form != null && form.validate()) {
      form.save();
      // print("$nis, $password");
      login();
    }
  }

  Future<void> login() async {
    try {
      final jsonResponse = await ApiService.post('/login', {
        'nis': nis,
        'password': password,
      });

      if (jsonResponse != null && jsonResponse['success'] == true) {
        Fluttertoast.showToast(
          msg: jsonResponse['message'] ?? 'Login Berhasil',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );

        var userData = jsonResponse['data'];
        int value = 1;
        var role =
            (jsonResponse['role'] ?? userData['role'] ?? 'siswa').toString();
        var idSiswaAPI = (userData['id_siswa'] ?? '').toString();
        var nisApi = (userData['nis'] ?? userData['username'] ?? '').toString();
        var namaOrtu = (userData['nama_lengkap'] ?? '').toString();
        var idOrangTua = (userData['id_orang_tua'] ?? '').toString();
        var childrenList =
            jsonResponse['children'] ?? userData['children'] ?? [];
        String childrenJson = jsonEncode(childrenList);

        // Jika orang tua dan memiliki anak, gunakan anak pertama jika idSiswaAPI kosong
        if (role == 'orang_tua' &&
            idSiswaAPI.isEmpty &&
            childrenList is List &&
            childrenList.isNotEmpty) {
          idSiswaAPI = (childrenList[0]['id_siswa'] ?? '').toString();
        }

        await savePref(
          value: value,
          idSiswa: idSiswaAPI,
          nis: nisApi,
          role: role,
          namaOrtu: namaOrtu,
          idOrangTua: idOrangTua,
          childrenJson: childrenJson,
        );

        setState(() {
          _loginStatus = LoginStatus.signIn;
        });

        print('Berhasil login sebagai $role: $nisApi');
      } else {
        var errorMessage =
            jsonResponse?['message'] ?? "Terjadi kesalahan saat login";

        Fluttertoast.showToast(
          msg: errorMessage,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );

        print('Gagal login: $errorMessage');
      }
    } catch (e) {
      print('Exception during login: $e');
    }
  }

  Future<void> savePref({
    required int value,
    required String idSiswa,
    required String nis,
    required String role,
    String? namaOrtu,
    String? idOrangTua,
    String? childrenJson,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt('value', value);
    await preferences.setString('idSiswa', idSiswa);
    await preferences.setString('nis', nis);
    await preferences.setString('role', role);
    if (namaOrtu != null && namaOrtu.isNotEmpty) {
      await preferences.setString('namaOrtu', namaOrtu);
    }
    if (idOrangTua != null && idOrangTua.isNotEmpty) {
      await preferences.setString('idOrangTua', idOrangTua);
    }
    if (childrenJson != null && childrenJson.isNotEmpty) {
      await preferences.setString('childrenJson', childrenJson);
    }
  }

  // ignore: prefer_typing_uninitialized_variables
  var value;
  Future<void> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");

      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  // ignore: non_constant_identifier_names
  Future<void> SignOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt("value", 0);
    await preferences.remove("role");
    await preferences.remove("namaOrtu");
    await preferences.remove("idOrangTua");
    await preferences.remove("childrenJson");
    setState(() {
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
      case LoginStatus.loading:
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: const SizedBox.shrink(),
        );
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
                              return "Silakan masukkan username";
                            }
                            return null;
                          },
                          onSaved: (e) => nis = e!,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.white,
                            contentPadding: const EdgeInsets.all(0),
                            hintText: "Username (NIS / ortu_nis)",
                            prefixIcon: Container(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 15),
                              child: const Icon(
                                Icons.person,
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
