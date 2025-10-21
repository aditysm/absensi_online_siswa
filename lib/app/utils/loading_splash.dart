import 'package:absensi_smamahardhika/app/utils/app_colors.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoadingSplashView extends StatelessWidget {
  final String title;
  final String animationAsset;
  final Color? backgroundColor;
  final Duration duration;
  final VoidCallback onCompleted;

  const LoadingSplashView({
    super.key,
    required this.title,
    required this.animationAsset,
    required this.onCompleted,
    this.backgroundColor,
    this.duration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    Future.delayed(duration, onCompleted);

    return Scaffold(
      body: Obx(
        () => Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AllMaterial.themeMode.value == ThemeMode.dark
                ? AppColors.darkBackgroundAlt
                : AppColors.lightPrimary,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  animationAsset,
                  repeat: true,
                ),
                const SizedBox(height: 24),
                Text(
                  title,
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
