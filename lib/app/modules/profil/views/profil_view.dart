import 'dart:io';

import 'package:absensi_smamahardhika/app/modules/home/controllers/home_controller.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/profil_controller.dart';

final controller = Get.put(ProfilController());

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: ProfilController.refreshData,
        child: Obx(() {
          final profil = HomeController.dataSiswa.value;
          final kelas = HomeController.dataKelasSiswa.firstOrNull;

          if (ProfilController.isLoading.value) {
            return _buildSkeleton(context);
          }

          if (profil == null) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return ListView(
                  children: [
                    SizedBox(
                      height: constraints.maxHeight,
                      child: _buildEmptyState(context),
                    ),
                  ],
                );
              },
            );
          }

          return Padding(
            padding: EdgeInsets.only(bottom: Platform.isAndroid ? 60 : 100),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                          backgroundImage: profil.data?.fotoUrl != null &&
                                  profil.data?.fotoUrl != ""
                              ? NetworkImage(profil.data?.fotoUrl ?? "")
                              : const AssetImage(
                                      'assets/images/avatar_default.png')
                                  as ImageProvider,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    profil.data?.nama ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    "NISN: ${profil.data?.nisn ?? ""}",
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (kelas?.nama != null)
                  _profilItem(
                    context,
                    Icons.class_outlined,
                    "Kelas",
                    kelas?.nama ?? "",
                  ),
                if (kelas?.jurusan?.nama != null)
                  _profilItem(
                    context,
                    CupertinoIcons.book,
                    "Jurusan",
                    kelas?.jurusan?.nama ?? "",
                  ),
                _profilItem(
                  context,
                  Icons.person_outline,
                  "Jenis Kelamin",
                  AllMaterial.parseGender(profil.data?.jenisKelamin ?? ""),
                ),
                _profilItem(
                  context,
                  CupertinoIcons.person_2,
                  "Nama Orang Tua",
                  profil.data?.orangtua?.nama ?? "",
                ),
                if (profil.data?.orangtua?.noTelepon != null)
                  _profilItem(
                    context,
                    CupertinoIcons.phone,
                    "Kontak Orang Tua",
                    profil.data?.orangtua?.noTelepon ?? "",
                  ),
                if (profil.data?.orangtua?.email != null)
                  _profilItem(
                    context,
                    Icons.email_outlined,
                    "Email Orang Tua",
                    profil.data?.orangtua?.email ?? "",
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined,
              color: colorScheme.onSurface.withOpacity(0.4), size: 80),
          const SizedBox(height: 12),
          Text(
            "Data Profil tidak ditemukan",
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Data profil akan tampil di sini.",
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profilItem(
      BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : "-",
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final baseColor = colorScheme.surfaceContainerHighest
        .withOpacity(Get.isDarkMode ? 0.25 : 0.4);
    final highlightColor =
        colorScheme.onSurface.withOpacity(Get.isDarkMode ? 0.15 : 0.25);

    Widget shimmerBox({double? width, double? height, double radius = 8}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1300),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: shimmerBox(width: 110, height: 110, radius: 55),
          ),
          const SizedBox(height: 16),
          Center(child: shimmerBox(width: 120, height: 20)),
          const SizedBox(height: 8),
          Center(child: shimmerBox(width: 80, height: 14)),
          const SizedBox(height: 20),
          for (int i = 0; i < 5; i++) ...[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  shimmerBox(width: 32, height: 32, radius: 10),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        shimmerBox(width: 100, height: 12, radius: 6),
                        const SizedBox(height: 6),
                        shimmerBox(width: 160, height: 14, radius: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
