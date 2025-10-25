import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _startMonitoring();
  }

  void _startMonitoring() {
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.first == ConnectivityResult.none) {
        // Tidak ada koneksi
        isConnected.value = false;
        _showNoInternetSheet();
      } else {
        // Ada koneksi
        if (!isConnected.value) {
          isConnected.value = true;
          if (Get.isBottomSheetOpen == true) Get.back(); // tutup sheet otomatis
        }
      }
    });
  }

  void _showNoInternetSheet() {
    if (Get.isBottomSheetOpen == true) return;

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
            const Icon(Icons.wifi_off, size: 50, color: Colors.redAccent),
            const SizedBox(height: 10),
            const Text(
              "Tidak ada koneksi internet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Pastikan perangkat Anda tersambung ke Wi-Fi atau data seluler.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await _connectivity.checkConnectivity();
                if (result.first != ConnectivityResult.none) {
                  isConnected.value = true;
                  if (Get.isBottomSheetOpen == true) Get.back();
                } else {
                  Get.snackbar(
                    "Gagal",
                    "Masih belum ada koneksi internet.",
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }
}
