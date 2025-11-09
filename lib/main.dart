import 'package:absensi_smamahardhika/app/controllers/general_controller.dart';
import 'package:absensi_smamahardhika/app/controllers/network_controller.dart';
import 'package:absensi_smamahardhika/app/data/apis/api_url.dart';
import 'package:absensi_smamahardhika/app/data/models/data_siswa_model.dart';
import 'package:absensi_smamahardhika/app/modules/home/controllers/home_controller.dart';
import 'package:absensi_smamahardhika/app/modules/home/views/home_view.dart';
import 'package:absensi_smamahardhika/app/modules/login/views/login_view.dart';
import 'package:absensi_smamahardhika/app/modules/pengaturan/controllers/pengaturan_controller.dart';
import 'package:absensi_smamahardhika/app/services/http_service.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:absensi_smamahardhika/app/utils/app_scroll.dart';
import 'package:absensi_smamahardhika/app/utils/app_theme.dart';
import 'package:absensi_smamahardhika/app/utils/loading_splash.dart';
import 'package:absensi_smamahardhika/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart'
    hide PermissionStatus;

import 'app/routes/app_pages.dart';

var locationService = Location();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  Get.put(NetworkController());
  await GetStorage.init();

  AllMaterial.themeMode.value = AllMaterial.box.read("themeMode") == "dark"
      ? ThemeMode.dark
      : AllMaterial.themeMode.value =
          AllMaterial.box.read("themeMode") == "light"
              ? ThemeMode.light
              : ThemeMode.system;
  PengaturanController.toggleDarkMode(
      AllMaterial.box.read("isDarkMode") ?? false);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    Obx(
      () => GetMaterialApp(
        themeMode: AllMaterial.themeMode.value,
        debugShowCheckedModeBanner: false,
        title: "Absensi Smahardhika",
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: const NoAlwaysScrollableBehavior(),
            child: child!,
          );
        },
        home: LoadingSplashView(
          title: "Tunggu Sebentar!",
          animationAsset: 'assets/images/loading.json',
          onCompleted: () async {
            PermissionStatus permissionGranted =
                await locationService.hasPermission();

            if (permissionGranted == PermissionStatus.denied ||
                permissionGranted == PermissionStatus.deniedForever) {
              permissionGranted = await locationService.requestPermission();

              if (permissionGranted != PermissionStatus.granted) {
                _showPermissionSheet();
                return;
              }
            }

            bool serviceEnabled = await locationService.serviceEnabled();
            if (!serviceEnabled) {
              serviceEnabled = await locationService.requestService();
              if (!serviceEnabled) {
                _showEnableLocationSheet();
                return;
              }
            }

            await checkAuth();
          },
        ),
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 350),
        getPages: AppPages.routes,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
      ),
    ),
  );
}

Future<void> checkAuth() async {
  final token = AllMaterial.box.read("token");
  if (token != null) {
    int? statusCode;
    var response = await HttpService.request(
      url: ApiUrl.dataSiswaUrl,
      type: RequestType.get,
      onError: (error) => print(error),
      onStuck: (error) => print(error),
      showLoading: false,
      onStatus: (code) async {
        statusCode = code;
        if (code == 401) {
          await GeneralController.logout(autoLogout: true);
          ToastService.show("Sesi habis, silahkan login kembali!");
          Get.offAll(() => LoginView());
        }
      },
    );

    if (response != null && statusCode != null && statusCode! < 400) {
      HomeController.dataSiswa.value = DataSiswaModel.fromJson(response);
      Get.offAll(() => HomeView());
    }
  } else {
    Get.offAll(() => LoginView());
  }
}

void _showEnableLocationSheet() {
  Get.bottomSheet(
    isDismissible: false,
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off, size: 48, color: Colors.redAccent),
          const SizedBox(height: 10),
          const Text(
            "Lokasi belum aktif",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Silakan aktifkan layanan lokasi agar aplikasi dapat berjalan dengan baik.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              bool enabled = await locationService.requestService();
              if (enabled) {
                Get.back();
                Get.offAll(
                  () => LoadingSplashView(
                    title: "Memuat...",
                    animationAsset: 'assets/images/loading.json',
                    onCompleted: () async {
                      await checkAuth();
                    },
                  ),
                );
              }
            },
            child: const Text("Aktifkan Lokasi"),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

void _showPermissionSheet() {
  Get.bottomSheet(
    isDismissible: false,
    Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.my_location, size: 48, color: Colors.orangeAccent),
          const SizedBox(height: 10),
          const Text(
            "Izin lokasi dibutuhkan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Berikan izin lokasi agar aplikasi dapat menentukan posisi Anda.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
              ToastService.show("Silakan aktifkan izin lokasi di pengaturan.");
            },
            child: const Text("Buka Pengaturan"),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
    enableDrag: false,
  );
}
