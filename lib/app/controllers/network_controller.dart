import 'dart:io';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:absensi_smamahardhika/app/utils/toast_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  bool _initialCheckDone = false;

  @override
  void onInit() {
    super.onInit();
    _startMonitoring();
  }

  void _startMonitoring() {
    Future.delayed(const Duration(seconds: 2), _checkInitialConnection);

    _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        if (!_initialCheckDone) return;

        final hasNetwork = results.any((r) => r != ConnectivityResult.none);

        if (!hasNetwork) {
          _handleDisconnected();
          return;
        }

        final hasInternet = await _checkInternetConnection();
        hasInternet ? _handleConnected() : _handleDisconnected();
      },
    );
  }

  Future<void> _checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();

      final hasNetwork = results.any((r) => r != ConnectivityResult.none);

      if (!hasNetwork) {
        _handleDisconnected();
      } else {
        final hasInternet = await _checkInternetConnection();
        if (hasInternet) {
          _handleConnected();
        } else {
          await Future.delayed(const Duration(seconds: 2));
          final retry = await _checkInternetConnection();
          retry ? _handleConnected() : _handleDisconnected();
        }
      }
    } finally {
      _initialCheckDone = true;
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 3),
      );
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  void _handleConnected() {
    if (!isConnected.value) {
      isConnected.value = true;

      if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
        Get.back();
      }

      ToastService.show("Internet kembali aktif");
    }
  }

  void _handleDisconnected() {
    if (isConnected.value) {
      isConnected.value = false;
      _showNoInternetSheet();
      ToastService.show("Tidak ada koneksi internet");
    }
  }

  void _showNoInternetSheet() {
    if (Get.context == null) {
      Future.delayed(const Duration(milliseconds: 300), _showNoInternetSheet);
      return;
    }

    if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) return;

    try {
      if (!AllMaterial.isDesktop) {
        Get.bottomSheet(
          isDismissible: false,
          enableDrag: false,
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: _sheetContent(),
          ),
        );
      } else {
        Get.defaultDialog(
          barrierDismissible: false,
          title: "",
          middleText: "",
          titlePadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _sheetContent(),
          ),
        );
      }
    } catch (e) {
      debugPrint("⚠️ Gagal menampilkan bottom sheet: $e");
    }
  }

  Widget _sheetContent() {
    return Column(
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
            final hasConnection = await _checkInternetConnection();
            if (hasConnection) {
              _handleConnected();
            } else {
              ToastService.show("Gagal. Masih belum ada koneksi internet.");
            }
          },
          child: const Text("Coba Lagi"),
        ),
      ],
    );
  }
}
