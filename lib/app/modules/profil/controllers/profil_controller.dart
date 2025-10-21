import 'package:absensi_smamahardhika/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';

class ProfilController extends GetxController {
  static var isLoading = false.obs;

  static Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await HomeController.getDataSiswa();

      print(HomeController.selectedIndex.value);
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
