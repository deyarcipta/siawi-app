import 'package:get/get.dart';

import '../controllers/point_siswa_controller.dart';

class PointSiswaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PointSiswaController>(
      () => PointSiswaController(),
    );
  }
}
