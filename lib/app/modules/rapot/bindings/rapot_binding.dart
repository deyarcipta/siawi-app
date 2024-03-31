import 'package:get/get.dart';

import '../controllers/rapot_controller.dart';

class RapotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RapotController>(
      () => RapotController(),
    );
  }
}
