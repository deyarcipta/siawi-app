import 'package:get/get.dart';

import '../controllers/modul_controller.dart';

class ModulBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModulController>(
      () => ModulController(),
    );
  }
}
