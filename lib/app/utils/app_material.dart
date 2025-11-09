import 'dart:io';

import 'package:absensi_smamahardhika/app/data/models/list_data_absen_siswa_model.dart';
import 'package:absensi_smamahardhika/app/modules/histori_absen/views/histori_absen_view.dart';
import 'package:absensi_smamahardhika/app/utils/app_colors.dart';
import 'package:absensi_smamahardhika/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class AllMaterial {
  static var box = GetStorage();

  static var selectedTahun = "".obs;
  static var role = "".obs;
  static var token = "".obs;
  static var idSiswa = 0.obs;
  static var refreshToken = "".obs;
  static Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  static var isDarkMode = false.obs;

  static bool isEmailValid(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  static final _confirmEnabled = false.obs;

  static void showImagePopup(String imageUrl, {String? title}) {
    if (imageUrl.isEmpty) {
      ToastService.show("Gagal, URL gambar tidak valid");
      return;
    }

    Get.dialog(
      GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 300) {
            Get.back();
          }
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  PhotoView(
                    imageProvider: NetworkImage(imageUrl),
                    backgroundDecoration:
                        const BoxDecoration(color: Colors.black),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3.5,
                    heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
                    loadingBuilder: (context, event) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image_rounded,
                          color: Colors.white54, size: 64),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  if (title != null && title.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        color: Colors.black45,
                        child: Text(
                          title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black87.withOpacity(0.9),
    );
  }

  static String ubahHari(String isoDate) {
    DateTime parsedDate = DateTime.parse(isoDate);
    String formattedDate =
        DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(parsedDate);
    return formattedDate;
  }

  static String ubahJam(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    String formattedDate = DateFormat('HH:mm').format(dateTime);
    return formattedDate;
  }

  static String ubahJamMenitDetik(String? timeString) {
    if (timeString == null || timeString.isEmpty) return "-";

    try {
      final parsedTime = DateFormat("HH:mm:ss.S").parse(timeString);
      return DateFormat('HH:mm').format(parsedTime);
    } catch (e) {
      print("Gagal parse waktu: $e");
      return "-";
    }
  }

  static String ubahTanggaldanJam(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate =
        DateFormat('d MMMM yyyy - HH.mm', 'id_ID').format(dateTime);
    return formattedDate;
  }

  static Future<void> showAbsenDialog(
      BuildContext context, AbsenSiswaModel absen) async {
    final colorScheme = Theme.of(context).colorScheme;

    final isChoice = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Pilih Absensi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Apakah Anda ingin melihat absen Masuk atau Pulang?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildChoiceCard(
                    context,
                    icon: Icons.login_rounded,
                    label: "Masuk",
                    color: colorScheme.primary,
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                  _buildChoiceCard(
                    context,
                    icon: Icons.logout_rounded,
                    label: "Pulang",
                    color: colorScheme.primary,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (isChoice != null) {
      Get.to(
        () => const HistoriAbsenView(),
        arguments: {
          "absen": absen,
          "isMasuk": isChoice,
        },
      );
    }
  }

  static Widget _buildChoiceCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 120,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void cusDialogValidasi({
    required VoidCallback? onConfirm,
    String? title,
    String? subtitle,
    VoidCallback? onCancel,
    bool showCancel = true,
    bool activeConfirm = true,
    IconData icon = Icons.info_outline,
    String confirmText = "LANJUT",
    String cancelText = "BATAL",
    Widget? customContent,
    Color iconColor = Colors.red,
  }) {
    _confirmEnabled.value = activeConfirm;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: KeyboardListener(
            focusNode: FocusNode()..requestFocus(),
            autofocus: true,
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.enter &&
                  _confirmEnabled.value) {
                onConfirm?.call();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 32, color: iconColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (customContent != null)
                    customContent
                  else if (subtitle != null && subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 15),
                    ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (showCancel)
                        TextButton(
                          onPressed: onCancel ?? () => Get.back(),
                          child: Text(
                            cancelText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      if (showCancel) const SizedBox(width: 12),
                      Obx(
                        () => ElevatedButton(
                          onPressed: _confirmEnabled.value ? onConfirm : null,
                          autofocus: true,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            confirmText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: showCancel,
    );
  }

  static void umpanPengguna(BuildContext context) {
    final TextEditingController umpanController = TextEditingController();
    final RxDouble rating = 0.0.obs;
    var umpanError = "".obs;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              isDarkMode.value ? Theme.of(context).cardColor : Colors.white,
          title: const Text("Umpan Pengguna"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Berikan penilaian & saran untuk aplikasi ini."),
              const SizedBox(height: 12),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        rating.value = index + 1.0;
                      },
                      icon: Icon(
                        Icons.star,
                        color: (index < rating.value)
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => AllMaterial.textField(
                  controller: umpanController,
                  maxLines: 3,
                  hintText: "Masukkan umpan balik Anda...",
                  errorText: umpanError.isEmpty ? null : umpanError.value,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(elevation: 0),
              onPressed: () => Get.back(),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                    isDarkMode.value ? null : AppColors.lightPrimary,
              ),
              onPressed: () {
                String umpan = umpanController.text.trim();
                double nilaiRating = rating.value;

                if (umpan.isNotEmpty && nilaiRating > 0) {
                  Get.back();
                  ToastService.show("Umpan Balik Anda telah dikirim.");
                } else {
                  umpanError.value =
                      "Isi umpan atau beri rating terlebih dahulu";
                }
              },
              child: Text(
                "Kirim",
                style: TextStyle(
                  color: isDarkMode.value ? null : Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget textField({
    FocusNode? focusNode,
    String? hintText,
    TextEditingController? controller,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onToggleObscureText,
    Widget? suffix,
    Widget? prefix,
    bool enabled = false,
    void Function()? onTap,
    Color? color,
    TextInputType textInputType = TextInputType.text,
    int? maxLines = 1,
    String? prefixText,
    int? limit,
    String? errorText,
    TextInputAction? textInputAction = TextInputAction.next,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    String? labelText,
    bool isVerif = false,
  }) {
    return TextField(
      maxLines: maxLines,
      keyboardType: textInputType,
      controller: controller,
      focusNode: focusNode,
      onTap: onTap,
      onSubmitted: onSubmitted,
      cursorColor: AppColors.lightPrimary,
      textInputAction: textInputAction,
      obscureText: isPassword ? (obscureText ?? true) : false,
      style: TextStyle(color: color),
      onChanged: onChanged,
      onTapOutside: (_) {
        focusNode?.unfocus();
      },
      readOnly: enabled,
      inputFormatters: textInputType == TextInputType.numberWithOptions()
          ? [
              LengthLimitingTextInputFormatter(limit),
              FilteringTextInputFormatter.digitsOnly,
            ]
          : null,
      decoration: InputDecoration(
        errorText: errorText,
        labelText: labelText,
        labelStyle: isVerif
            ? null
            : TextStyle(
                color: AllMaterial.isDarkMode.isTrue
                    ? Colors.white
                    : AppColors.lightPrimary,
              ),
        enabledBorder: isVerif
            ? OutlineInputBorder(borderSide: BorderSide.none)
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.lightPrimary,
          ),
          borderRadius: BorderRadius.circular(isVerif ? 4 : 10),
        ),
        hintText: hintText,
        prefixText: prefixText,
        prefixStyle: TextStyle(
          color: AllMaterial.isDarkMode.isTrue
              ? Colors.white
              : AppColors.lightPrimary,
        ),
        hintStyle: TextStyle(
          fontWeight: FontWeight.normal,
        ),
        hoverColor: AppColors.lightPrimary,
        focusColor: AppColors.lightPrimary,
        border: OutlineInputBorder(
          borderSide: BorderSide(),
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: prefix,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (obscureText ?? true)
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: onToggleObscureText,
              )
            : suffix,
      ),
    );
  }

  static String parseGender(String? gender) {
    var genderParse = "";
    if (gender == null || gender == "") {
      genderParse = "-";
    } else {
      if (gender.toLowerCase().contains("l")) {
        genderParse = "Laki-Laki";
      } else if (gender.toLowerCase().contains("p")) {
        genderParse = "Perempuan";
      } else if (gender.toLowerCase() == "l/p") {
        genderParse = "Laki-Laki & Perempuan";
      }
    }
    return genderParse;
  }

  static String parseJenisAbsen(String? jenis) {
    var jenisParse = "";

    if (jenis == null || jenis.trim().isEmpty) {
      jenisParse = "-";
    } else {
      final lower = jenis.toLowerCase();

      if (lower.contains("masuk")) {
        jenisParse = "Masuk";
      } else if (lower.contains("pulang")) {
        jenisParse = "Pulang";
      } else if (lower.contains("telat")) {
        jenisParse = "Telat";
      } else if (lower.contains("izin") ||
          lower.contains("sakit") ||
          lower.contains("dispensasi")) {
        jenisParse = "Izin / Sakit / Dispensasi";
      } else if (lower.contains("izin") ||
          lower.contains("sakit") ||
          lower.contains("dispensasi") ||
          lower.contains("telat")) {
        jenisParse = "Izin / Sakit / Dispensasi / Telat";
      } else {
        jenisParse = "Tidak Diketahui";
      }
    }

    return jenisParse;
  }

  static Future<void> openFileOrUrl(String url) async {
    if (url.isEmpty) {
      ToastService.show("URL tidak valid");
      return;
    }

    try {
      if (url.startsWith('http')) {
        final uri = Uri.parse(url);
        final fileExt = url.split('.').last.toLowerCase();

        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExt)) {
          showImagePopup(url);
          return;
        }

        if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx']
            .contains(fileExt)) {
          final result = await OpenFilex.open(url);
          if (result.type == ResultType.done) return;

          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ToastService.show("Gagal membuka dokumen eksternal");
          }
          return;
        }

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ToastService.show("Tidak dapat membuka link ini");
        }
      } else {
        final file = File(url);
        if (await file.exists()) {
          final result = await OpenFilex.open(file.path);
          if (result.type != ResultType.done) {
            ToastService.show("Tidak dapat membuka file lokal");
          }
        } else {
          ToastService.show("File lokal tidak ditemukan");
        }
      }
    } catch (e) {
      print("⚠️ Error membuka file: $e");
      ToastService.show("Gagal membuka file");
    }
  }

  static void openFilterDialog({
    required BuildContext context,
    required List<Widget> items,
    void Function()? onApply,
    void Function()? onReset,
    String? title,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Filter $title",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        child: Text("Reset"),
                        onPressed: () {
                          Navigator.pop(context);
                          onReset?.call();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  ...items,
                  SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize:
                          Size(Get.width, context.theme.buttonTheme.height + 5),
                    ),
                    onPressed: onApply == null
                        ? null
                        : () {
                            Navigator.pop(context);
                            onApply.call();
                          },
                    child: const Text('Terapkan Filter'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
