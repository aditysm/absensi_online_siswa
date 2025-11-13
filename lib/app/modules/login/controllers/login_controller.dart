import 'package:absensi_smamahardhika/app/data/apis/api_url.dart';
import 'package:absensi_smamahardhika/app/modules/home/views/home_view.dart';
import 'package:absensi_smamahardhika/app/modules/pengaturan/controllers/pengaturan_controller.dart';
import 'package:absensi_smamahardhika/app/services/http_service.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:absensi_smamahardhika/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;
  final emailC = TextEditingController();
  final emailF = FocusNode();
  final passwordC = TextEditingController();
  final passwordF = FocusNode();
  final showPassword = false.obs;

  final emailError = "".obs;
  final passwordError = "".obs;
  final allError = "".obs;

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  @override
  void onInit() async {
    if (emailC.text.isEmpty) {
      await Future.delayed(Durations.medium1);
      emailF.requestFocus();
    } else {
      await Future.delayed(Durations.medium1);
      passwordF.requestFocus();
    }
    emailC.addListener(() {
      if (emailC.text.isNotEmpty) {
        emailError.value = '';
        allError.value = '';
      }
    });
    passwordC.addListener(() {
      if (passwordC.text.isNotEmpty) {
        passwordError.value = '';
        allError.value = '';
      }
    });
    super.onInit();
  }

  bool _validateForm() {
    bool isValid = true;

    if (emailC.text.trim().isEmpty) {
      emailError.value = "NISN tidak boleh kosong!";
      emailF.requestFocus();
      isValid = false;
    }

    if (passwordC.text.trim().isEmpty) {
      passwordError.value = "Password tidak boleh kosong";
      passwordF.requestFocus();
      isValid = false;
    }

    if (!isValid) {
      Future.delayed(Duration(milliseconds: 300));
      allError.value = "Periksa kembali input Anda.";
      emailF.requestFocus();
    }

    return isValid;
  }

  Future<void> login() async {
    if (!_validateForm()) {
      return;
    }
    isLoading.value = true;
    await Future.delayed(Durations.medium1);
    emailF.unfocus();
    passwordF.unfocus();
    final data = await HttpService.request(
      url: ApiUrl.loginUrl,
      isLogin: true,
      type: RequestType.post,
      body: {
        "identifier": emailC.text.trim(),
        "password": passwordC.text,
      },
      showLoading: true,
      loadingMessage: "Mencoba Login...",
      successMessage: "Login Berhasil",
      errorMessage: "Login Gagal",
      onError: (error) {
        allError.value = error.toString();
        print("eakkk: $error");
        isLoading.value = false;
      },
      onStuck: (stuck) async {
        isLoading.value = false;
        await Future.delayed(Durations.medium2);
        if (stuck is Map<String, String>) {
          emailError.value = stuck['email'] ?? '';
          passwordError.value = stuck['password'] ?? '';
          allError.value = "Periksa input yang salah!";
        } else if (stuck is Map && stuck.containsKey('message')) {
          allError.value = stuck['message'].toString();
        } else {
          allError.value = "Terjadi kesalahan";
        }
      },
    );

    print("data: $data");

    if (data != null &&
        data is Map &&
        data.containsKey("access_token") &&
        data.containsKey("refresh_token")) {
      AllMaterial.box.write("token", data["access_token"] ?? "");
      AllMaterial.box.write("refreshToken", data["refresh_token"] ?? "");
      AllMaterial.box.write("role", data["role"].toString().toLowerCase());
      AllMaterial.token.value = data["access_token"] ?? "";
      AllMaterial.role.value = data["role"].toString().toLowerCase();
      AllMaterial.refreshToken.value = data["refresh_token"] ?? "";
      PengaturanController.toggleDarkMode(ThemeMode.system != ThemeMode.dark);
      print(data["role"].toString().toLowerCase());
      ToastService.show("Login berhasil. Selamat Datang!");
      Get.offAll(() => HomeView());
      await Future.delayed(Durations.medium3);
      emailC.clear();
      passwordC.clear();
    } else {
      if (data is Map && data.containsKey("message")) {
        ToastService.show(data["message"]);
      } else {
        ToastService.show("Login gagal, silakan periksa kembali");
      }
    }
    isLoading.value = false;
  }

  void forgotPassword() {}
}
