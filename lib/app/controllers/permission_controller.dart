import 'package:absensi_smamahardhika/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

class PermissionWatcher with WidgetsBindingObserver {
  final Location locationService = Location();

  void startWatching(BuildContext context) {
    WidgetsBinding.instance.addObserver(this);
  }

  void stopWatching() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      PermissionStatus status = await locationService.hasPermission();
      bool serviceEnabled = await locationService.serviceEnabled();

      if (status == PermissionStatus.granted && serviceEnabled) {
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        checkAuth(Get.context!);
      }
    }
  }
}
