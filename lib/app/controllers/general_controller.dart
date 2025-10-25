import 'package:absensi_smamahardhika/app/data/apis/api_url.dart';
import 'package:absensi_smamahardhika/app/modules/home/controllers/home_controller.dart';
import 'package:absensi_smamahardhika/app/modules/login/views/login_view.dart';
import 'package:absensi_smamahardhika/app/services/http_service.dart';
import 'package:absensi_smamahardhika/app/utils/app_colors.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:absensi_smamahardhika/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneralController extends GetxController {
  static Future<void> logout({bool autoLogout = false}) async {
    Future<void> clearSession() async {
      await AllMaterial.box.erase();
      AllMaterial.token.value = "";
      AllMaterial.role.value = "";
      AllMaterial.refreshToken.value = "";
      AllMaterial.idSiswa.value = 0;
      HomeController.isLoadingFirst.value = false;
      HomeController.dataSiswa.value = null;
      if (!autoLogout) {
        HomeController.selectedIndex.value = 0;
        HomeController.onPageChanged(0);
        HomeController.pageController.jumpToPage(0);
      }
    }

    if (autoLogout) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (AllMaterial.idSiswa.value != 0) {
        Get.offAll(() => LoginView());
      }
      await clearSession();
      return;
    }

    AllMaterial.cusDialogValidasi(
      title: "Logout",
      subtitle: "Anda akan keluar dari Akun saat ini. Lanjutkan?",
      icon: Icons.warning,
      iconColor: AppColors.colorError,
      cancelText: "LANJUT",
      confirmText: "BATAL",
      onCancel: () async {
        await Future.delayed(const Duration(milliseconds: 400));
        Get.back();

        await HttpService.request(
          url: ApiUrl.logoutUrl,
          isLogin: true,
          type: RequestType.post,
          showLoading: true,
          loadingMessage: "Mencoba Logout...",
          successMessage: "Logout Berhasil!",
          errorMessage: "Logout Gagal!",
          onError: (error) {
            ToastService.show(HttpService.getErrorMessageFromException(error));
            print("Logout Error: $error");
          },
          onStatus: (statusCode) async {
            if (statusCode == 200) {
              Get.offAll(() => LoginView());
              await Future.delayed(const Duration(milliseconds: 400));
              await clearSession();
              print("Logout status code: $statusCode");
              ToastService.show("Logout berhasil!");
            }
          },
        );
      },
      onConfirm: () => Get.back(),
    );
  }
}
