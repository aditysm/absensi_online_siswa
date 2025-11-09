// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:absensi_smamahardhika/app/data/models/list_data_absen_siswa_model.dart';
import 'package:absensi_smamahardhika/app/modules/buat_absen/controllers/buat_absen_controller.dart';
import 'package:absensi_smamahardhika/app/modules/buat_absen/views/buat_absen_view.dart';
import 'package:absensi_smamahardhika/app/modules/histori_absen/views/histori_absen_view.dart';
import 'package:absensi_smamahardhika/app/modules/home/controllers/home_controller.dart';
import 'package:absensi_smamahardhika/app/services/location_service.dart';
import 'package:absensi_smamahardhika/app/utils/app_colors.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/beranda_controller.dart';

final controller = Get.put(BerandaController());

class BerandaView extends GetView<BerandaController> {
  const BerandaView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: HomeController.refreshData,
        color: colorScheme.primary,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Obx(
              () => Text(
                "Hai, ${HomeController.dataSiswa.value?.data?.nama ?? ""}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Obx(
              () => Text(
                "NISN: ${HomeController.dataSiswa.value?.data?.nisn ?? ""}",
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () {
                final canAbsen = HomeController.canAbsen.value;
                final diluarRadius = HomeController.diluarRadius.value;
                final jenisGeneral = HomeController.jenisAbsenGeneral.value;
                final jadwal = BerandaController.jadwalHariIni.value;

                final now = DateTime.now();
                final jamMasuk = parseTimeSafe(jadwal?.batasJamMasuk, now);
                final jamPulang = parseTimeSafe(jadwal?.batasJamPulang, now);

                final sudahAbsenMasuk = BerandaController
                        .jadwalTigaHari.firstOrNull?.absen?.statusAbsenMasuk !=
                    null;
                final sudahAbsenPulang = BerandaController
                        .jadwalTigaHari.firstOrNull?.absen?.statusAbsenPulang !=
                    null;

                String label =
                    "Absen ${jenisGeneral.isEmpty ? 'Sekarang' : jenisGeneral.capitalizeFirst!}";
                String statusInfo = "";

                if (sudahAbsenMasuk && sudahAbsenPulang) {
                  statusInfo = "Anda sudah absen masuk & pulang hari ini.";
                } else if (sudahAbsenMasuk && now.isBefore(jamPulang)) {
                  statusInfo = HomeController.catatanAbsen.value;
                } else if (sudahAbsenMasuk && now.isAfter(jamPulang)) {
                  statusInfo = HomeController.catatanAbsen.value;
                } else if (now.isBefore(jamMasuk)) {
                  statusInfo = "Belum waktu absen masuk.";
                } else if (now.isAfter(jamMasuk) && now.isBefore(jamPulang)) {
                  statusInfo =
                      "Jam masuk sudah lewat, Anda akan tercatat sebagai telat.";
                } else {
                  statusInfo = HomeController.catatanAbsen.value;
                }

                JenisAbsenEnum parseJenis(String jenis) {
                  switch (jenis.toLowerCase()) {
                    case 'masuk':
                      return JenisAbsenEnum.masuk;
                    case 'pulang':
                      return JenisAbsenEnum.pulang;
                    case 'telat':
                      return JenisAbsenEnum.telat;
                    case 'izinorsakitordispensasi':
                      return JenisAbsenEnum.izinOrSakitOrDispensasi;
                    case 'izinorsakitordispensasiortelat':
                      return JenisAbsenEnum.izinOrSakitOrDispensasiOrTelat;
                    default:
                      return JenisAbsenEnum.masuk;
                  }
                }

                bool bisaAbsenUtama = false;
                bool bisaAbsenKecil = false;

                if (!canAbsen) {
                  bisaAbsenUtama = false;
                  bisaAbsenKecil = false;
                } else if (diluarRadius) {
                  bisaAbsenUtama = false;
                  bisaAbsenKecil = true;
                } else if (sudahAbsenMasuk && now.isBefore(jamPulang)) {
                  bisaAbsenUtama = false;
                  bisaAbsenKecil = true;
                } else {
                  bisaAbsenUtama = true;
                  bisaAbsenKecil = true;
                }

                if (jenisGeneral.toLowerCase().contains('izin') ||
                    jenisGeneral.toLowerCase().contains('sakit') ||
                    jenisGeneral.toLowerCase().contains('dispensasi')) {
                  bisaAbsenUtama = false;
                  bisaAbsenKecil = canAbsen;
                }

                bool isSuccess = !diluarRadius && canAbsen;
                bool isWarning = diluarRadius && canAbsen;
                bool isError = !canAbsen || (diluarRadius && !canAbsen);

                final dark = AllMaterial.isDarkMode.value;
                Color bgColor;
                Color borderColor;
                Color iconColor;
                Color textColor;
                IconData iconData;

                if (isSuccess) {
                  bgColor = dark
                      ? Colors.green.withOpacity(0.15)
                      : Colors.green.shade50;
                  borderColor = dark
                      ? Colors.greenAccent.withOpacity(0.4)
                      : Colors.green.shade200;
                  iconColor = dark
                      ? Colors.greenAccent.shade100
                      : Colors.green.shade600;
                  textColor = dark
                      ? Colors.greenAccent.shade100
                      : Colors.green.shade700;
                  iconData = Icons.check_circle_rounded;
                } else if (isWarning) {
                  bgColor = dark
                      ? Colors.amber.withOpacity(0.15)
                      : Colors.amber.shade50;
                  borderColor = dark
                      ? Colors.amberAccent.withOpacity(0.4)
                      : Colors.amber.shade200;
                  iconColor = dark
                      ? Colors.amberAccent.shade100
                      : Colors.amber.shade700;
                  textColor = dark
                      ? Colors.amberAccent.shade100
                      : Colors.amber.shade800;
                  iconData = Icons.warning_amber_rounded;
                } else {
                  bgColor =
                      dark ? Colors.red.withOpacity(0.15) : Colors.red.shade50;
                  borderColor = dark
                      ? Colors.redAccent.withOpacity(0.4)
                      : Colors.red.shade200;
                  iconColor =
                      dark ? Colors.redAccent.shade100 : Colors.red.shade600;
                  textColor =
                      dark ? Colors.redAccent.shade100 : Colors.red.shade700;
                  iconData = Icons.error_outline_rounded;
                }

                String displayMsg = "";

                if ((now.isAfter(jamPulang) && !sudahAbsenPulang) ||
                    (now.isAfter(jamPulang) &&
                        !sudahAbsenPulang &&
                        !sudahAbsenMasuk)) {
                  displayMsg = statusInfo;
                } else {
                  if (sudahAbsenMasuk && sudahAbsenPulang) {
                    displayMsg =
                        "Anda tidak dapat melakukan absen lagi.\n$statusInfo";
                  } else if (diluarRadius &&
                      !canAbsen &&
                      now.isBefore(jamPulang)) {
                    displayMsg =
                        "Anda berada di luar area absensi.\nSilahkan mendekat ke lokasi yang ditentukan dan absen sesuai jam kerja.";
                  } else if (diluarRadius && canAbsen) {
                    displayMsg =
                        "Anda berada di luar radius lokasi.\nNamun Anda masih dapat melakukan absen izin, sakit, atau dispensasi.";
                  } else if (!diluarRadius && canAbsen) {
                    displayMsg = statusInfo;
                  } else if (!canAbsen) {
                    displayMsg = HomeController.catatanAbsen.value;
                  }
                }

                if (displayMsg.isEmpty) {
                  displayMsg = "Status absensi belum tersedia.";
                }

                final mainButton = Tooltip(
                  message: statusInfo,
                  child: ElevatedButton.icon(
                    onPressed: bisaAbsenUtama
                        ? () {
                            BuatAbsenController.selectedJenisAbsen.value =
                                parseJenis(jenisGeneral);
                            Get.to(() => const BuatAbsenView(), arguments: {
                              "fromSmall": false,
                              "jenisAbsen": jenisGeneral,
                            });
                          }
                        : null,
                    icon: const Icon(Icons.fingerprint_rounded, size: 22),
                    label: Text(
                      label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: bisaAbsenUtama ? 3 : 0,
                      backgroundColor: bisaAbsenUtama
                          ? AppColors.lightPrimaryVariant
                          : Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      fixedSize: Size.fromWidth(Get.width),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                );

                final smallButtons = Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSmallButton(
                      icon: Icons.assignment_turned_in_rounded,
                      label: "Izin",
                      active: bisaAbsenKecil,
                      onTap: bisaAbsenKecil
                          ? () {
                              BuatAbsenController.selectedJenisAbsen.value =
                                  JenisAbsenEnum.izinOrSakitOrDispensasi;
                              Get.to(() => const BuatAbsenView(), arguments: {
                                "fromSmall": true,
                                "jenisAbsen": "Izin",
                              });
                            }
                          : null,
                    ),
                    _buildSmallButton(
                      icon: Icons.healing_rounded,
                      label: "Sakit",
                      active: bisaAbsenKecil,
                      onTap: bisaAbsenKecil
                          ? () {
                              BuatAbsenController.selectedJenisAbsen.value =
                                  JenisAbsenEnum.izinOrSakitOrDispensasi;
                              Get.to(() => const BuatAbsenView(), arguments: {
                                "fromSmall": true,
                                "jenisAbsen": "Sakit",
                              });
                            }
                          : null,
                    ),
                    _buildSmallButton(
                      icon: Icons.event_busy_rounded,
                      label: "Dispensasi",
                      active: bisaAbsenKecil,
                      onTap: bisaAbsenKecil
                          ? () {
                              BuatAbsenController.selectedJenisAbsen.value =
                                  JenisAbsenEnum.izinOrSakitOrDispensasi;
                              Get.to(() => const BuatAbsenView(), arguments: {
                                "fromSmall": true,
                                "jenisAbsen": "Dispensasi",
                              });
                            }
                          : null,
                    ),
                  ],
                );

                return Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: Get.width,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(iconData, color: iconColor, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              displayMsg,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildJadwalCard(context),
                    const SizedBox(height: 10),
                    mainButton,
                    const SizedBox(height: 5),
                    smallButtons,
                  ],
                );
              },
            ),
            if (BerandaController.jadwalTigaHari.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    "Histori Absen Terbaru",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () {
                      final riwayat = [...BerandaController.jadwalTigaHari];
                      if (riwayat.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              "Belum ada data absen.",
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                        );
                      }

                      riwayat.sort((a, b) {
                        final aDate = a.absen?.tanggal ?? DateTime(1970);
                        final bDate = b.absen?.tanggal ?? DateTime(1970);
                        return bDate.compareTo(aDate);
                      });

                      return Column(
                        children: riwayat
                            .map((absen) => _buildRiwayatItem(context, absen))
                            .toList(),
                      );
                    },
                  ),
                  SizedBox(height: Platform.isAndroid ? 60 : 100),
                ],
              ),
          ],
        ),
      ),
    );
  }

  DateTime parseTimeSafe(String? time, DateTime now) {
    if (time == null || !time.contains(':')) {
      return DateTime(now.year, now.month, now.day, 0, 0);
    }

    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required bool active,
    required void Function()? onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: active ? onTap : null,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        elevation: active ? 2 : 0,
        backgroundColor: active ? Colors.blueAccent : Colors.grey[400],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildJadwalCard(BuildContext context) {
    return Obx(
      () {
        final colorScheme = Theme.of(context).colorScheme;
        final jadwal = BerandaController.jadwalHariIni.value;
        var isSpesial = (BerandaController.jadwalHariIni.value?.specialDay ??
                false) &&
            (BerandaController.jadwalHariIni.value?.specialDayName != null &&
                BerandaController.jadwalHariIni.value?.specialDayName != "");
        return Container(
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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isSpesial
                          ? Icons.celebration_outlined
                          : Icons.access_time_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(
                      () => Text(
                        "Jadwal Absen ${BerandaController.jadwalHariIni.value?.hari ?? ""} ${isSpesial ? "-${BerandaController.jadwalHariIni.value?.specialDayName}" : ""}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _fluentInfoRow(
                  "Hari",
                  jadwal?.hari ??
                      AllMaterial.ubahHari(DateTime.now().toIso8601String()),
                  context),
              _fluentInfoRow(
                  "Jam Masuk", jadwal?.batasJamMasuk ?? "Belum Ada", context),
              _fluentInfoRow(
                  "Jam Pulang", jadwal?.batasJamPulang ?? "Belum Ada", context),
              _fluentInfoRow("Dalam Radius",
                  HomeController.diluarRadius.value ? "Tidak" : "Ya", context),
              Obx(
                () => (HomeController.koordinatTerdekat.value?.namaTempat != "")
                    ? _fluentInfoRow(
                        "Titik Lokasi",
                        HomeController.koordinatTerdekat.value?.namaTempat ??
                            "",
                        context)
                    : SizedBox.shrink(),
              ),
              if (HomeController.jarakTerdekatMeter.value != 0.0)
                _fluentInfoRow(
                    "Jarak ke Lokasi",
                    GeoLocationService.formatDistance(
                        HomeController.jarakTerdekatMeter.value),
                    context),
              if (jadwal?.keterangan != null && jadwal?.keterangan != "")
                _fluentInfoRow(
                    "Keterangan", jadwal?.keterangan ?? "-", context),
            ],
          ),
        );
      },
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
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                height: 1.3,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
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
      padding: EdgeInsets.only(bottom: 8.0),
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
