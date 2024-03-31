import 'package:get/get.dart';

import '../controllers/tagihan_controller.dart';

class TagihanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TagihanController>(
      () => TagihanController(),
    );
  }
}
