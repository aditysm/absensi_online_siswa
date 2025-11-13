// ignore_for_file: use_build_context_synchronously

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

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
        home: Builder(builder: (context) {
          return LoadingSplashView(
            title: "Tunggu Sebentar!",
            animationAsset: 'assets/images/loading.json',
            onCompleted: () async {
              bool serviceEnabled = await locationService.serviceEnabled();
              if (!serviceEnabled) {
                serviceEnabled = await locationService.requestService();
                if (!serviceEnabled) {
                  _showEnableLocationSheet(context);
                  return;
                }
              }

              PermissionStatus permissionGranted =
                  await locationService.hasPermission();
              if (permissionGranted == PermissionStatus.denied) {
                permissionGranted = await locationService.requestPermission();
                if (permissionGranted != PermissionStatus.granted) {
                  _showPermissionSheet(context);
                  return;
                }
              } else if (permissionGranted == PermissionStatus.deniedForever) {
                _showPermissionSheet(context);
                return;
              }

              await checkAuth(context);
            },
          );
        }),
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 350),
        getPages: AppPages.routes,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
      ),
    ),
  );
}

Future<void> checkAuth(BuildContext context) async {
  final token = AllMaterial.box.read("token");
  if (token != null) {
    int? statusCode;
    var response = await HttpService.request(
      url: ApiUrl.dataSiswaUrl,
      type: RequestType.get,
      onError: (error) => _showErrorBuilderSheet(context),
      onStuck: (error) => print(error),
      showLoading: false,
      onStatus: (code) async {
        statusCode = code;
        if (code == 401) {
          await GeneralController.logout(autoLogout: true);
          ToastService.show("Sesi habis, silahkan login kembali!");
          Get.offAll(() => LoginView());
        } else if (code == 403) {
          _showErrorBuilderSheet(context);
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
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
}

void _showEnableLocationSheet(BuildContext context) {
  Get.bottomSheet(
    isDismissible: false,
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            "Silahkan aktifkan layanan lokasi agar aplikasi dapat berjalan dengan baik.",
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
                      await checkAuth(context);
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

void _showErrorBuilderSheet(BuildContext context) {
  Get.bottomSheet(
    isDismissible: false,
    Container(
      width: Get.width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mobile_off_sharp, size: 48, color: Colors.redAccent),
          const SizedBox(height: 10),
          const Text(
            "Terjadi Kesalahan Tidak Diketahui",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Silahkan tutup aplikasi dan coba lagi.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              AllMaterial.executeExit();
              GeneralController.logout(autoLogout: true);
            },
            child: const Text("Keluar Aplikasi"),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
    enableDrag: false,
  );
}

void _showPermissionSheet(BuildContext context) {
  Get.bottomSheet(
    isDismissible: false,
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
              ToastService.show("Silahkan aktifkan izin lokasi di pengaturan.");
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
