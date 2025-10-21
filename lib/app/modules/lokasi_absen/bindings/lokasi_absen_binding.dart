import 'package:get/get.dart';

import '../controllers/lokasi_absen_controller.dart';

class LokasiAbsenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LokasiAbsenController>(
      () => LokasiAbsenController(),
    );
  }
}
