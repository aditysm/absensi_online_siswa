import 'package:get/get.dart';

import '../controllers/buat_absen_controller.dart';

class BuatAbsenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BuatAbsenController>(
      () => BuatAbsenController(),
    );
  }
}
