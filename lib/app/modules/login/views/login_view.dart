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
  const String message =
      "Halo Admin Helpdesk SMK Wisata Indonesia,\nSaya mengalami kendala saat hendak login ke aplikasi SIAWI Mobile. Mohon bantuannya untuk pengecekan akun saya.\n\n• Nama / Akun: \n• Kendala: \n\nTerima kasih.";
  final Uri url = Uri.parse(
    "https://wa.me/6285172331507?text=${Uri.encodeComponent(message)}",
  );
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

enum LoginStatus { notSignIn, signIn, loading }

class _LoginSiawiState extends State<LoginSiawi> {
  LoginStatus _loginStatus = LoginStatus.loading;
  String nis = '';
  String password = '';
  final _key = GlobalKey<FormState>();
  final TextEditingController _nisController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _secureText = true;
  bool _isSubmitting = false;
  String? _nisError;
  String? _passwordError;

  void showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  void check() {
    setState(() {
      _nisError = _nisController.text.trim().isEmpty
          ? "Silakan masukkan NIS atau username"
          : null;
      _passwordError = _passwordController.text.isEmpty
          ? "Silakan masukkan password"
          : null;
    });

    if (_nisError == null && _passwordError == null) {
      nis = _nisController.text.trim();
      password = _passwordController.text;
      login();
    }
  }

  Widget _buildFieldBox({
    required IconData icon,
    required Widget child,
    bool hasError = false,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasError ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Blok sekat ungu lavender kiri persis seperti pada gambar
          Container(
            width: 58,
            height: double.infinity,
            color: const Color(0xFFEDE9FE),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: const Color(0xFF6366F1),
              size: 22,
            ),
          ),
          // Input field
          Expanded(child: child),
        ],
      ),
    );
  }

  Future<void> login() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final jsonResponse = await ApiService.post('/login', {
        'nis': nis.trim(),
        'password': password.trim(),
      });

      if (jsonResponse != null && jsonResponse['success'] == true) {
        Fluttertoast.showToast(
          msg: jsonResponse['message'] ?? 'Login Berhasil',
          backgroundColor: const Color(0xFF10B981),
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

        if (mounted) {
          setState(() {
            _loginStatus = LoginStatus.signIn;
          });
        }
      } else {
        var errorMessage =
            jsonResponse?['message'] ?? "Terjadi kesalahan saat login";

        Fluttertoast.showToast(
          msg: errorMessage,
          backgroundColor: const Color(0xFFEF4444),
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Gagal terhubung ke server. Periksa koneksi internet Anda.",
        backgroundColor: const Color(0xFFEF4444),
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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

  int? value;
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
  void dispose() {
    _nisController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.loading:
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.mainColor,
              strokeWidth: 2.5,
            ),
          ),
        );
      case LoginStatus.notSignIn:
        final size = MediaQuery.of(context).size;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Stack(
            children: [
              // 1. LATAR BELAKANG ELEGAN GRADASI ATAS
              Container(
                height: size.height * 0.40,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4C3EC7),
                      Color(0xFF6B5DE8),
                      Color(0xFF7E72EE),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                child: Stack(
                  children: [
                    // Lingkaran ornamen aksen 1
                    Positioned(
                      top: -40,
                      right: -30,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    // Lingkaran ornamen aksen 2
                    Positioned(
                      bottom: 40,
                      left: -50,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. KONTEN FORM LOGIN
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 18),

                      // LOGO & IDENTITAS SEKOLAH
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/logo/logo-splash.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              "SIAWI",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "SMK WISATA INDONESIA",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                "Sistem Informasi Akademik Mobile",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // CARD UTAMA FORM LOGIN
                      Container(
                        padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5B4BD1).withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Masuk ke Akun",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Masukkan kredensial untuk melanjutkan ke aplikasi",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // FIELD 1: USERNAME / NIS
                              const Text(
                                "NIS / Username Akun",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildFieldBox(
                                icon: Icons.person_outline_rounded,
                                hasError: _nisError != null,
                                child: TextFormField(
                                  controller: _nisController,
                                  textInputAction: TextInputAction.next,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 16,
                                    ),
                                    hintText: "Contoh: 243223 / ortu_243223",
                                    hintStyle: TextStyle(
                                      fontSize: 13.5,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              if (_nisError != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 14, top: 5),
                                  child: Text(
                                    _nisError!,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFFEF4444),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 18),

                              // FIELD 2: PASSWORD
                              const Text(
                                "Password",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildFieldBox(
                                icon: Icons.lock_outline_rounded,
                                hasError: _passwordError != null,
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _secureText,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => check(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 16,
                                    ),
                                    hintText: "Masukkan kata sandi",
                                    hintStyle: const TextStyle(
                                      fontSize: 13.5,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _secureText
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF94A3B8),
                                        size: 20,
                                      ),
                                      onPressed: showHide,
                                    ),
                                  ),
                                ),
                              ),
                              if (_passwordError != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 14, top: 5),
                                  child: Text(
                                    _passwordError!,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFFEF4444),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 10),

                              // LINK LUPA PASSWORD
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LupaPasswordView(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    "Lupa Password?",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF5B4BD1),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // TOMBOL MASUK DENGAN GRADASI
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : check,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 4,
                                    shadowColor:
                                        const Color(0xFF5B4BD1).withValues(alpha: 0.35),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: _isSubmitting
                                            ? [
                                                const Color(0xFF9CA3AF),
                                                const Color(0xFF9CA3AF),
                                              ]
                                            : [
                                                const Color(0xFF4C3EC7),
                                                const Color(0xFF6B5DE8),
                                              ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: _isSubmitting
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.4,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Text(
                                                  "MASUK SEKARANG",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.8,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // INFO HINT PENGGUNAAN AKUN
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.info_outline_rounded,
                                      size: 16,
                                      color: Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: const TextSpan(
                                          style: TextStyle(
                                            fontSize: 11.2,
                                            color: Color(0xFF64748B),
                                            height: 1.35,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "Siswa ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF334155),
                                              ),
                                            ),
                                            TextSpan(text: "login dengan NIS. "),
                                            TextSpan(
                                              text: "Orang Tua/Wali ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF334155),
                                              ),
                                            ),
                                            TextSpan(
                                              text: "login dengan username ortu_NIS.",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // BANTUAN WHATSAPP & FOOTER
                      TextButton.icon(
                        onPressed: _launchURL,
                        icon: const Icon(
                          Icons.support_agent_rounded,
                          size: 18,
                          color: Color(0xFF475569),
                        ),
                        label: const Text(
                          "Kendala Login? Hubungi Admin",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),
                      const Text(
                        "© 2024 SMK Wisata Indonesia Jakarta",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
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
