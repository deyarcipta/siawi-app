import 'package:get/get.dart';

import '../controllers/dokumen_controller.dart';

class DokumenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokumenController>(
      () => DokumenController(),
    );
  }
}
