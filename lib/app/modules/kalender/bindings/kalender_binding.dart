import 'package:get/get.dart';

import '../controllers/kalender_controller.dart';

class KalenderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KalenderController>(
      () => KalenderController(),
    );
  }
}
