import 'package:get/get.dart';

import '../controllers/riwayat_absen_controller.dart';

class RiwayatAbsenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatAbsenController>(
      () => RiwayatAbsenController(),
    );
  }
}
