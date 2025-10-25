import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PengaturanController extends GetxController {
  @override
  void onInit() {
    super.onInit();

    // final isDark = AllMaterial.box.read('isDarkMode') ?? false;
    var isDark = AllMaterial.isDarkMode.isTrue;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    });
  }

  static void toggleDarkMode(bool isDark) {
    AllMaterial.isDarkMode.value = isDark;
    AllMaterial.box.write('isDarkMode', isDark);

    Future.microtask(() {
      Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
      AllMaterial.box.write("themeMode", isDark ? "dark" : "light");
    });
  }
}
