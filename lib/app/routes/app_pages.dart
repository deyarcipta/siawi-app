import 'package:get/get.dart';

import '../modules/about/bindings/about_binding.dart';
import '../modules/about/views/about_view.dart';
import '../modules/absensi/bindings/absensi_binding.dart';
import '../modules/absensi/views/absensi_view.dart';
import '../modules/dokumen/bindings/dokumen_binding.dart';
import '../modules/dokumen/views/dokumen_view.dart';
import '../modules/dokumen_gabungan/bindings/dokumen_gabungan_binding.dart';
import '../modules/dokumen_gabungan/views/dokumen_gabungan_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/MyHomePage.dart';
import '../modules/informasi/bindings/informasi_binding.dart';
import '../modules/informasi/views/informasi_view.dart';
import '../modules/jadwal/bindings/jadwal_binding.dart';
import '../modules/jadwal/views/jadwal_view.dart';
import '../modules/kalender/bindings/kalender_binding.dart';
import '../modules/kalender/views/kalender_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/modul/bindings/modul_binding.dart';
import '../modules/modul/views/modul_mapel_view.dart';
import '../modules/password/bindings/password_binding.dart';
import '../modules/password/views/password_view.dart';
import '../modules/point_siswa/bindings/point_siswa_binding.dart';
import '../modules/point_siswa/views/point_siswa_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/rapot/bindings/rapot_binding.dart';
import '../modules/rapot/views/rapot_view.dart';
import '../modules/tagihan/bindings/tagihan_binding.dart';
import '../modules/tagihan/views/tagihan_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => MyHomePage(signOut != null ? signOut! : () {}),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.INFORMASI,
      page: () => InformasiView(signOut != null ? signOut! : () {}),
      binding: InformasiBinding(),
    ),
    GetPage(
      name: _Paths.TAGIHAN,
      page: () => TagihanView(signOut != null ? signOut! : () {}),
      binding: TagihanBinding(),
    ),
    GetPage(
      name: _Paths.KALENDER,
      page: () => KalenderView(signOut != null ? signOut! : () {}),
      binding: KalenderBinding(),
    ),
    GetPage(
      name: _Paths.ABSENSI,
      page: () => AbsensiView(signOut != null ? signOut! : () {}),
      binding: AbsensiBinding(),
    ),
    GetPage(
      name: _Paths.JADWAL,
      page: () => JadwalView(signOut != null ? signOut! : () {}),
      binding: JadwalBinding(),
    ),
    GetPage(
      name: _Paths.RAPOT,
      page: () => RapotView(signOut != null ? signOut! : () {}),
      binding: RapotBinding(),
    ),
    GetPage(
      name: _Paths.POINT_SISWA,
      page: () => PointSiswaView(signOut != null ? signOut! : () {}),
      binding: PointSiswaBinding(),
    ),
    GetPage(
      name: _Paths.MODUL,
      page: () => ModulMapelView(),
      binding: ModulBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(signOut != null ? signOut! : () {}),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT,
      page: () => const AboutView(),
      binding: AboutBinding(),
    ),
    GetPage(
      name: _Paths.PASSWORD,
      page: () => PasswordView(signOut != null ? signOut! : () {}),
      binding: PasswordBinding(),
    ),
    GetPage(
      name: _Paths.DOKUMEN_GABUNGAN,
      page: () => DokumenGabunganView(signOut != null ? signOut! : () {}),
      binding: DokumenGabunganBinding(),
    ),
    GetPage(
      name: _Paths.DOKUMEN,
      page: () => DokumenView(signOut != null ? signOut! : () {}),
      binding: DokumenBinding(),
    ),
  ];

  static get signOut => null;
}
