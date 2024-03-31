import 'package:get/get.dart';

import '../modules/about/bindings/about_binding.dart';
import '../modules/about/views/about_view.dart';
import '../modules/absensi/bindings/absensi_binding.dart';
import '../modules/absensi/views/absensi_view.dart';
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
      page: () => MyHomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.INFORMASI,
      page: () => InformasiView(),
      binding: InformasiBinding(),
    ),
    GetPage(
      name: _Paths.TAGIHAN,
      page: () => TagihanView(),
      binding: TagihanBinding(),
    ),
    GetPage(
      name: _Paths.KALENDER,
      page: () => KalenderView(),
      binding: KalenderBinding(),
    ),
    GetPage(
      name: _Paths.ABSENSI,
      page: () => const AbsensiView(),
      binding: AbsensiBinding(),
    ),
    GetPage(
      name: _Paths.JADWAL,
      page: () => const JadwalView(),
      binding: JadwalBinding(),
    ),
    GetPage(
      name: _Paths.RAPOT,
      page: () => const RapotView(),
      binding: RapotBinding(),
    ),
    GetPage(
      name: _Paths.POINT_SISWA,
      page: () => const PointSiswaView(),
      binding: PointSiswaBinding(),
    ),
    GetPage(
      name: _Paths.MODUL,
      page: () => ModulMapelView(),
      binding: ModulBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT,
      page: () => const AboutView(),
      binding: AboutBinding(),
    ),
  ];

  static get signOut => null;
}
