import 'package:absensi_smamahardhika/app/controllers/general_controller.dart';
import 'package:absensi_smamahardhika/app/data/apis/api_url.dart';
import 'package:absensi_smamahardhika/app/data/models/data_siswa_model.dart';
import 'package:absensi_smamahardhika/app/modules/home/controllers/home_controller.dart';
import 'package:absensi_smamahardhika/app/modules/home/views/home_view.dart';
import 'package:absensi_smamahardhika/app/modules/login/views/login_view.dart';
import 'package:absensi_smamahardhika/app/services/http_service.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:absensi_smamahardhika/app/utils/app_scroll.dart';
import 'package:absensi_smamahardhika/app/utils/app_theme.dart';
import 'package:absensi_smamahardhika/app/utils/loading_splash.dart';
import 'package:absensi_smamahardhika/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:location/location.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);

  await GetStorage.init();

  AllMaterial.themeMode.value = AllMaterial.box.read("themeMode") == "dark"
      ? ThemeMode.dark
      : ThemeMode.light;
  var locationService = Location();

  runApp(
    Obx(
      () => GetMaterialApp(
        themeMode: AllMaterial.themeMode.value,
        debugShowCheckedModeBanner: false,
        title: "Esensi Online Siswa",
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
            // ignore: no_leading_underscores_for_local_identifiers
            bool _serviceEnabled;
            // ignore: no_leading_underscores_for_local_identifiers
            PermissionStatus _permissionGranted;

            _serviceEnabled = await locationService.serviceEnabled();
            if (!_serviceEnabled) {
              _serviceEnabled = await locationService.requestService();
              if (!_serviceEnabled) {
                return;
              }
            }

            _permissionGranted = await locationService.hasPermission();
            if (_permissionGranted == PermissionStatus.denied) {
              _permissionGranted = await locationService.requestPermission();
              if (_permissionGranted != PermissionStatus.granted) {
                return;
              }
            }
            final token = AllMaterial.box.read("token");
            if (token != null) {
              int? statusCode;
              var response = await HttpService.request(
                url: ApiUrl.dataSiswaUrl,
                type: RequestType.get,
                onError: (error) {
                  print(error);
                },
                onStuck: (error) {
                  print(error);
                },
                showLoading: false,
                onStatus: (code) async {
                  statusCode = code;
                  print(code);

                  if (code == 401) {
                    await GeneralController.logout(autoLogout: true);
                    ToastService.show("Sesi habis, silahkan login kembali!");
                    Get.offAll(() => LoginView());
                  }
                },
              );

              if (response != null && statusCode != null && statusCode! < 400) {
                HomeController.dataSiswa.value =
                    DataSiswaModel.fromJson(response);
                Get.offAll(() => HomeView());
              }
            } else {
              Get.offAll(() => LoginView());
            }
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
