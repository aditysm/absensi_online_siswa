import 'dart:io';

import 'package:absensi_smamahardhika/app/data/models/list_data_jadwal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/jadwal_absen_controller.dart';

class JadwalAbsenView extends GetView<JadwalAbsenController> {
  const JadwalAbsenView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JadwalAbsenController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.onRefreshData,
        color: colorScheme.primary,
        child: Obx(
          () {
            if (JadwalAbsenController.isLoadingFirst.value ||
                JadwalAbsenController.isLoading.value) {
              return _buildSkeletonList(context);
            }

            final data = JadwalAbsenController.dataJadwal;
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

            return Padding(
              padding: EdgeInsets.only(bottom: Platform.isAndroid ? 60 : 100),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                itemCount: data.length,
                itemBuilder: (context, index) =>
                    _buildJadwalCard(context, data[index]),
              ),
            );
          },
        ),
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
          Icon(Icons.timer_off_outlined,
              color: colorScheme.onSurface.withOpacity(0.4), size: 80),
          const SizedBox(height: 12),
          Text(
            "Belum ada jadwal absensi",
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Jadwal absensi akan tampil di sini.",
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Shimmer.fromColors(
          baseColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          highlightColor: colorScheme.surfaceContainerHighest.withOpacity(0.1),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 50,
                      height: 20,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildJadwalCard(BuildContext context, JadwalModel jadwal) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isActive = jadwal.isActive ?? false;
    final bool isSpecial = jadwal.specialDay ?? false;
    final accentColor = colorScheme.primary;
    final hariDisplay =
        (isSpecial && (jadwal.specialDayName?.isNotEmpty ?? false))
            ? "${jadwal.hari} (${jadwal.specialDayName})"
            : (jadwal.hari ?? "Hari Ini");

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isSpecial
                        ? Icons.celebration_outlined
                        : Icons.watch_later_outlined,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    maxLines: 2,
                    hariDisplay,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                _buildStatusChip(isActive),
              ],
            ),
            const SizedBox(height: 12),
            _fluentInfoRow("Jam Masuk", jadwal.batasJamMasuk ?? "-", context),
            _fluentInfoRow("Batas Masuk", jadwal.maxJamMasuk ?? "-", context),
            _fluentInfoRow("Jam Pulang", jadwal.batasJamPulang ?? "-", context),
            _fluentInfoRow(
                "Keterangan",
                jadwal.keterangan?.trim().isNotEmpty == true
                    ? jadwal.keterangan!
                    : "-",
                context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    final color = isActive ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? "Aktif" : "Nonaktif",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _fluentInfoRow(String label, String value, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                color: colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              ":",
              style: TextStyle(
                fontSize: 13.5,
                color: colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
