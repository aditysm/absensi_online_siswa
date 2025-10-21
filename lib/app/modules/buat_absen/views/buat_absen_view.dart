import 'dart:io';

import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:absensi_smamahardhika/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/buat_absen_controller.dart';
import '../../home/controllers/home_controller.dart';

enum StatusAbsenMasukKeluarEnum {
  hadir,
  telat,
  // ignore: constant_identifier_names
  tidak_hadir,
  izin,
  sakit,
  dispensasi,
}

class BuatAbsenView extends GetView<BuatAbsenController> {
  const BuatAbsenView({super.key});

  static String parseJenisAbsen(String? jenis) {
    if (jenis == null || jenis.isEmpty) return "-";

    final lower = jenis.toLowerCase();
    if (lower == ("masuk")) return "Masuk";
    if (lower == ("pulang")) return "Pulang";
    if (lower == ("telat")) return "Telat";
    if (lower == ("izin")) return "Izin";
    if (lower == ("sakit")) return "Sakit";
    if (lower == ("dispensasi")) return "Dispensasi";
    if (lower == ("tepatwaktu") && HomeController.diluarRadius.value) return "";
    if (lower == ("izinorsakitordispensasi")) {
      return "Izin / Sakit / Dispensasi";
    }
    if (lower == ("izinorsakitordispensasiortelat")) {
      return "Izin / Sakit / Dispensasi / Telat";
    }
    return "-";
  }

  @override
  Widget build(BuildContext context) {
    bool fromSmall = Get.arguments["fromSmall"] ?? false;
    String jenisAbsenFromSmall = Get.arguments["jenisAbsen"] ?? "";
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.put(BuatAbsenController());

    final jenisAbsen = HomeController.jenisAbsen.value;

    StatusAbsenMasukKeluarEnum parseAbsenEnumFromSmall() {
      var jenis = jenisAbsenFromSmall.toLowerCase();
      if (jenis == "sakit") {
        return StatusAbsenMasukKeluarEnum.sakit;
      } else if (jenis == "dispensasi") {
        return StatusAbsenMasukKeluarEnum.dispensasi;
      }
      return StatusAbsenMasukKeluarEnum.izin;
    }

    print("jenisAbsen= $jenisAbsen");

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Obx(
          () => Text(
            "Absen ${HomeController.jenisAbsenGeneral.isEmpty ? "Sekarang" : HomeController.jenisAbsenGeneral.value}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                child: ListView(
                  children: [
                    _infoSection(
                      context,
                      title: 'Status Absen',
                      items: [
                        Obx(() {
                          final jenis =
                              HomeController.jenisAbsen.value.toLowerCase();

                          List<StatusAbsenMasukKeluarEnum> options;

                          final isTepatWaktuMasuk = jenis == "tepatwaktu" &&
                              HomeController.jenisAbsenGeneral.value == "Masuk";
                          final isTepatWaktuPulang = jenis == "tepatwaktu" &&
                              HomeController.jenisAbsenGeneral.value ==
                                  "Pulang";
                          final isDiluarRadius =
                              HomeController.diluarRadius.value;

                          if ((isTepatWaktuMasuk || isTepatWaktuPulang) &&
                              !isDiluarRadius) {
                            options = [
                              StatusAbsenMasukKeluarEnum.hadir,
                            ];
                          } else {
                            switch (jenis.toLowerCase()) {
                              case "masuk":
                              case "pulang":
                                options = [
                                  StatusAbsenMasukKeluarEnum.hadir,
                                ];
                                break;

                              case "telat":
                              case "izin":
                              case "sakit":
                              case "dispensasi":
                              case "izinorsakitordispensasi":
                                options = [
                                  StatusAbsenMasukKeluarEnum.izin,
                                  StatusAbsenMasukKeluarEnum.sakit,
                                  StatusAbsenMasukKeluarEnum.dispensasi,
                                ];
                                break;

                              case "izinorsakitordispensasiortelat":
                                options = [
                                  StatusAbsenMasukKeluarEnum.izin,
                                  StatusAbsenMasukKeluarEnum.sakit,
                                  StatusAbsenMasukKeluarEnum.dispensasi,
                                  StatusAbsenMasukKeluarEnum.telat,
                                ];
                                break;

                              default:
                                options = [
                                  StatusAbsenMasukKeluarEnum.izin,
                                  StatusAbsenMasukKeluarEnum.sakit,
                                  StatusAbsenMasukKeluarEnum.dispensasi,
                                ];
                            }
                          }

                          StatusAbsenMasukKeluarEnum selectedValue;

                          if (fromSmall) {
                            final parsed = parseAbsenEnumFromSmall();
                            selectedValue = options.firstWhere(
                              (e) => e.name == parsed.name,
                              orElse: () => options.first,
                            );
                            BuatAbsenController.selectedStatusMasukKeluar
                                .value = selectedValue;
                          } else {
                            final current = BuatAbsenController
                                .selectedStatusMasukKeluar.value;
                            selectedValue = options.firstWhere(
                              (e) => e.name == current?.name,
                              orElse: () => options.first,
                            );
                            BuatAbsenController.selectedStatusMasukKeluar
                                .value = selectedValue;
                          }

                          return DropdownButtonFormField<
                              StatusAbsenMasukKeluarEnum>(
                            value: selectedValue,
                            items: options
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e.name
                                              .replaceAll('_', ' ')
                                              .capitalizeFirst ??
                                          e.name,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: fromSmall
                                ? null
                                : (val) {
                                    if (val != null) {
                                      BuatAbsenController
                                          .selectedStatusMasukKeluar
                                          .value = val;
                                    }
                                  },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.2),
                            ),
                          );
                        }),
                      ],
                    ),
                    Obx(
                      () {
                        final jenis = HomeController.jenisAbsen.value;

                        if (jenis == "IzinOrSakitOrDispensasi" ||
                            jenis == "IzinOrSakitOrDispensasiOrTelat" ||
                            jenis == "Telat") {
                          return _infoSection(
                            context,
                            title: 'Catatan',
                            items: [
                              TextField(
                                focusNode: controller.noteF,
                                controller: controller.noteC,
                                maxLines: 3,
                                onChanged: (value) =>
                                    controller.noteText.value = value,
                                onTapOutside: (_) {
                                  controller.noteF.unfocus();
                                },
                                decoration: InputDecoration(
                                  hintText: "Tulis catatan...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest
                                      .withOpacity(0.2),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                    if (_isJenisMasukAtauPulang(jenisAbsen)) ...[
                      _infoSection(
                        context,
                        title: 'Upload Gambar',
                        items: [
                          Obx(
                            () => (controller.selectedFileImage.value == null)
                                ? ElevatedButton.icon(
                                    onPressed: controller.pickImage,
                                    icon: const Icon(Icons.camera_alt_rounded),
                                    label: const Text('Ambil Gambar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ),
                          Obx(() {
                            final path =
                                controller.selectedFileImage.value?.path ?? "";
                            if (path.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: InkWell(
                                onTap: () async {
                                  final uri = Uri.file(path);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    ToastService.show(
                                        "Tidak bisa membuka file.");
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        colorScheme.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          colorScheme.primary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(path),
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image,
                                                  size: 40),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          path.split('/').last,
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.5,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          controller.selectedFileImage.value =
                                              null;
                                        },
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        tooltip: 'Hapus gambar',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ] else ...[
                      _infoSection(
                        context,
                        title: 'Upload Dokumen',
                        items: [
                          Obx(
                            () => (controller.selectedFileDocument.value ==
                                    null)
                                ? ElevatedButton.icon(
                                    onPressed: controller.pickDocument,
                                    icon: const Icon(Icons.attach_file),
                                    label: const Text('Pilih Dokumen'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ),
                          Obx(
                            () {
                              final path =
                                  controller.selectedFileDocument.value?.path ??
                                      "";
                              if (path.isEmpty) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: InkWell(
                                  onTap: () async {
                                    final uri = Uri.file(path);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri,
                                          mode: LaunchMode.externalApplication);
                                    } else {
                                      ToastService.show(
                                          "Tidak bisa membuka file.");
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          colorScheme.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: colorScheme.primary
                                              .withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.insert_drive_file_rounded,
                                          size: 32,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            path.split('/').last,
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.5,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            controller.selectedFileDocument
                                                .value = null;
                                          },
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          tooltip: 'Hapus file',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () {
            final isMasukPulang = _isJenisMasukAtauPulang(jenisAbsen);
            final hasFile = isMasukPulang
                ? controller.selectedFileImage.value != null
                : controller.selectedFileDocument.value != null;

            final jenis = HomeController.jenisAbsen.value;
            final needNote = jenis == "IzinOrSakitOrDispensasi" ||
                jenis == "IzinOrSakitOrDispensasiOrTelat" ||
                jenis == "Telat";

            final hasNote = !needNote || controller.noteText.value.isNotEmpty;

            final enabled =
                hasFile && hasNote && !BuatAbsenController.isLoading.value;

            return ElevatedButton.icon(
              onPressed: enabled
                  ? () {
                      AllMaterial.cusDialogValidasi(
                        title: "Simpan Absensi",
                        subtitle: "Orang tua Anda akan diberitahu. Lanjutkan?",
                        onConfirm: () async {
                          Get.back();
                          await controller.postDataAbsenSiswa();
                        },
                        onCancel: () => Get.back(),
                      );
                    }
                  : null,
              icon: BuatAbsenController.isLoading.value
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(
                BuatAbsenController.isLoading.value
                    ? 'Menyimpan...'
                    : 'Simpan Absensi',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _isJenisMasukAtauPulang(String jenis) {
    final j = jenis.toLowerCase();
    final jenisAbsenGeneral = HomeController.jenisAbsenGeneral.value;
    return j == "masuk" ||
        j == "pulang" ||
        j == "telat" ||
        (jenisAbsenGeneral == "Masuk" && j == "tepatwaktu") ||
        (jenisAbsenGeneral == "Pulang" && j == "tepatwaktu");
  }

  Widget _infoSection(BuildContext context,
      {required String title, required List<Widget> items}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }
}
