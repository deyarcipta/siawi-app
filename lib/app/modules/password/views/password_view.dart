import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/modules/home/views/home_view.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:http/http.dart' as http;
// import 'package:fluttertoast/fluttertoast.dart';

class PasswordView extends StatefulWidget {
  final VoidCallback signOut;
  const PasswordView(this.signOut, {Key? key}) : super(key: key);

  @override
  State<PasswordView> createState() => _PasswordViewState();
}

class _PasswordViewState extends State<PasswordView> {
  late String password1;
  late String password2;
  late String? _idSiswa;
  final _formKey = GlobalKey<FormState>();

  Future<String?> _loadIdSiswa() async {
    final idSiswa = await _getIdSiswa();
    setState(() {
      _idSiswa = idSiswa;
    });
    return idSiswa;
  }

  Future<String?> _getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('idSiswa');
  }

  void gantiPassword(String idSiswa) async {
    final response = await http
        .post(Uri.parse('http://103.75.209.90/api/ubahPassword'), body: {
      'idSiswa': idSiswa,
      'password1': password1,
      'password2': password2,
    });

    // print('password : ${response.statusCode}');
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        // Jika login berhasil, akses data pengguna
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password Berhasil Diganti'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigasi ke halaman lain setelah menampilkan pesan toast
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeView(widget.signOut)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password Gagal Diganti'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const SizedBox(
              //   height: 50,
              // ),
              Container(
                width: 125,
                height: 125,
                child: Image.asset(
                  "assets/logo/logo-splash.png",
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                child: SizedBox(
                  height: 72,
                  width: 320,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    onSaved: (value) => password1 = value!,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.all(0),
                      hintText: "Password Baru",
                      prefixIcon: Container(
                        padding: const EdgeInsets.only(left: 20, right: 15),
                        child: const Icon(
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
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: SizedBox(
                  height: 50,
                  width: 320,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password again';
                      }
                      return null;
                    },
                    onSaved: (value) => password2 = value!,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.all(0),
                      hintText: "Ulangi Password Baru",
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _loadIdSiswa().then((idSiswa) {
                            if (idSiswa != null) {
                              gantiPassword(idSiswa);
                            } else {
                              // Fluttertoast.showToast(
                              //   msg: 'Gagal memuat ID siswa',
                              //   backgroundColor: Colors.red,
                              //   textColor: Colors.white,
                              //   toastLength: Toast.LENGTH_SHORT,
                              // );
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        fixedSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        "SIMPAN",
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
      ),
    );
  }
}
