import 'package:get/get.dart';

import '../controllers/dokumen_gabungan_controller.dart';

class DokumenGabunganBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokumenGabunganController>(
      () => DokumenGabunganController(),
    );
  }
}
