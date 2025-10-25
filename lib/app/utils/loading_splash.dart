import 'dart:async';
import 'package:absensi_smamahardhika/app/utils/app_colors.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:absensi_smamahardhika/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:location/location.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoadingSplashView extends StatefulWidget {
  final String title;
  final String animationAsset;
  final Color? backgroundColor;
  final Duration duration;
  final Future<void> Function() onCompleted;

  const LoadingSplashView({
    super.key,
    required this.title,
    required this.animationAsset,
    required this.onCompleted,
    this.backgroundColor,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<LoadingSplashView> createState() => _LoadingSplashViewState();
}

class _LoadingSplashViewState extends State<LoadingSplashView>
    with WidgetsBindingObserver {
  final Location locationService = Location();
  final Connectivity connectivity = Connectivity();

  bool _hasResumed = false;
  bool _hasCompleted = false;
  Timer? _checkOverlayTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startLoadingSequence();
  }

  Future<void> _startLoadingSequence() async {
    await Future.delayed(widget.duration);

    if (!mounted || _hasCompleted) return;

    _checkOverlayTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (!mounted || _hasCompleted) {
        timer.cancel();
        return;
      }

      final connectivityResult = await connectivity.checkConnectivity();
      final hasConnection = connectivityResult.first != ConnectivityResult.none;

      if (!hasConnection) {
        timer.cancel();
        _showNoInternetSheet();
        return;
      }

      if (Get.isDialogOpen != true && Get.isBottomSheetOpen != true) {
        timer.cancel();
        _hasCompleted = true;
        await widget.onCompleted();
      }
    });
  }

  void _showNoInternetSheet() {
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
            const Icon(Icons.wifi_off, size: 48, color: Colors.redAccent),
            const SizedBox(height: 10),
            const Text(
              "Tidak ada koneksi internet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Pastikan Anda tersambung ke jaringan Wi-Fi atau data seluler.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await connectivity.checkConnectivity();
                final connected = result.first != ConnectivityResult.none;
                if (connected) {
                  Get.back();
                  _startLoadingSequence();
                } else {
                  ToastService.show(
                    "Gagal, masih belum ada koneksi internet.",
                  );
                }
              },
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  void dispose() {
    _checkOverlayTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && !_hasResumed) {
      _hasResumed = true;
      final PermissionStatus status = await locationService.hasPermission();
      if (status == PermissionStatus.granted) {
        if (Get.isBottomSheetOpen == true) Get.back();
        if (!_hasCompleted) {
          _hasCompleted = true;
          await widget.onCompleted();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                (AllMaterial.themeMode.value == ThemeMode.dark
                    ? AppColors.darkBackgroundAlt
                    : AppColors.lightPrimary),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  widget.animationAsset,
                  repeat: true,
                ),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Sedang memeriksa data...",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
