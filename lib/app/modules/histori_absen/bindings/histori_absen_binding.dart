import 'package:get/get.dart';

import '../controllers/histori_absen_controller.dart';

class HistoriAbsenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoriAbsenController>(
      () => HistoriAbsenController(),
    );
  }
}
