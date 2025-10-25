import 'dart:io';

import 'package:absensi_smamahardhika/app/data/models/list_data_absen_siswa_model.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:absensi_smamahardhika/app/modules/histori_absen/views/histori_absen_view.dart';
import '../controllers/riwayat_absen_controller.dart';

class RiwayatAbsenView extends GetView<RiwayatAbsenController> {
  const RiwayatAbsenView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RiwayatAbsenController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.onRefreshData,
        color: colorScheme.primary,
        child: Obx(() {
          final data = RiwayatAbsenController.dataAbsenSiswa;

          if (RiwayatAbsenController.isLoadingFirst.value ||
              RiwayatAbsenController.isLoading.value) {
            return _buildSkeletonList(context);
          }

          if (data.isEmpty) {
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

          final sortedData = [...data];
          sortedData.sort((a, b) {
            final aDate = a.absen?.tanggal ?? DateTime(1970);
            final bDate = b.absen?.tanggal ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });

          return Padding(
            padding: EdgeInsets.only(bottom: Platform.isAndroid ? 60 : 100),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              itemCount: sortedData.length,
              itemBuilder: (context, index) =>
                  _buildRiwayatItem(context, sortedData[index]),
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
          Icon(Icons.assignment_late_outlined,
              color: colorScheme.onSurface.withOpacity(0.4), size: 80),
          const SizedBox(height: 12),
          Text(
            "Belum ada histori absensi",
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Histori kehadiran Anda akan muncul di sini",
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Shimmer.fromColors(
          baseColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          highlightColor: colorScheme.surfaceContainerHighest.withOpacity(0.1),
          child: Container(
            height: 78,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 12,
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 180,
                        height: 10,
                        color: colorScheme.surfaceContainerHighest,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRiwayatItem(BuildContext context, AbsenSiswaModel absen) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _statusColor(absen.absen?.status ?? "");
    final statusAbsenMasuk = absen.absen?.statusAbsenMasuk ?? "";
    final statusAbsenPulang = absen.absen?.statusAbsenPulang ?? "";
    final bool hasMasuk = statusAbsenMasuk.isNotEmpty;
    final bool hasPulang = statusAbsenPulang.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: !hasMasuk && !hasPulang
              ? null
              : () {
                  if (hasMasuk && !hasPulang) {
                    Get.to(
                      () => const HistoriAbsenView(),
                      arguments: {
                        "absen": absen,
                        "isMasuk": true,
                      },
                    );
                  } else if (hasMasuk && hasPulang) {
                    AllMaterial.showAbsenDialog(context, absen);
                  }
                },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.assignment_outlined,
                      color: colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AllMaterial.ubahHari(
                            absen.absen?.tanggal?.toIso8601String() ?? ""),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Masuk: ${AllMaterial.ubahJamMenitDetik(absen.absen?.absenMasuk ?? "")} • Pulang: ${AllMaterial.ubahJamMenitDetik(absen.absen?.absenPulang ?? "")}",
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    absen.absen?.status ?? "",
                    style: textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Colors.green;
      case 'izin':
        return Colors.orange;
      case 'alpa':
        return Colors.redAccent;
      case 'sakit':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
