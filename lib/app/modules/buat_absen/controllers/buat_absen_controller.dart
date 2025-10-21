import 'dart:io';
import 'package:absensi_smamahardhika/app/data/apis/api_url.dart';
import 'package:absensi_smamahardhika/app/modules/beranda/controllers/beranda_controller.dart';
import 'package:absensi_smamahardhika/app/modules/home/controllers/home_controller.dart';
import 'package:absensi_smamahardhika/app/services/http_service.dart';
import 'package:absensi_smamahardhika/app/utils/toast_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../views/buat_absen_view.dart';

enum JenisAbsenEnum {
  masuk,
  pulang,
  telat,
  izinOrSakitOrDispensasi,
  izinOrSakitOrDispensasiOrTelat,
}

class BuatAbsenController extends GetxController {
  static final selectedJenisAbsen = JenisAbsenEnum.masuk.obs;
  static final isLoading = false.obs;
  static final selectedStatusMasukKeluar =
      Rx<StatusAbsenMasukKeluarEnum?>(null);

  final noteC = TextEditingController();
  final noteF = FocusNode();
  final noteText = ''.obs;

  final selectedFileImage = Rx<File?>(null);
  final selectedFileDocument = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();

  Future<void> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        selectedFileDocument.value = File(result.files.single.path!);
        ToastService.show('Dokumen dipilih: ${result.files.single.name}');
      }
    } catch (e) {
      ToastService.show('Gagal memilih dokumen: $e');
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final dir = await getTemporaryDirectory();
        final targetPath =
            '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          image.path,
          targetPath,
          quality: 70,
        );

        if (compressedFile != null) {
          selectedFileImage.value = File(compressedFile.path);
          ToastService.show('Foto berhasil diambil');
        } else {
          ToastService.show('Gagal mengambil foto');
        }
      }
    } catch (e) {
      ToastService.show('Gagal mengambil foto: $e');
    }
  }

  Future<void> postDataAbsenSiswa() async {
    noteF.unfocus();
    isLoading.value = true;

    try {
      final jenis = HomeController.jenisAbsen.value;
      final jenisAbsenGeneral = HomeController.jenisAbsenGeneral.value;
      final jenisStr = jenis.toLowerCase();
      final bool isDiluarRadius = HomeController.diluarRadius.value;

      String url = _resolveAbsenUrl(jenis, jenisAbsenGeneral, isDiluarRadius);
      print(
          "🟢 Jenis absen: $jenis | General: $jenisAbsenGeneral | Radius: $isDiluarRadius");
      print("🌐 URL: $url");

      bool fromSmall = Get.arguments["fromSmall"] ?? false;
      final isDokumenAbsen = [
            StatusAbsenMasukKeluarEnum.dispensasi,
            StatusAbsenMasukKeluarEnum.izin,
            StatusAbsenMasukKeluarEnum.sakit,
          ].contains(selectedStatusMasukKeluar.value) &&
          fromSmall;

      final Map<String, String> fields = {
        "latitude": HomeController.latitude.value.toString(),
        "longitude": HomeController.longitude.value.toString(),
        if (noteC.text.isNotEmpty) "note": noteC.text,
        if (isDokumenAbsen && !_isJenisMasukAtauPulang(jenisStr))
          "jenis_absen":
              parseJenisAbsen(selectedStatusMasukKeluar.value?.name ?? ""),
        if (isDiluarRadius)
          "jenis_absen":
              parseJenisAbsen(selectedStatusMasukKeluar.value?.name ?? ""),
      };

      print("Fields: $fields");
      final bool isMasukAtauPulang = _isJenisMasukAtauPulang(jenisStr);
      final Map<String, File> files = {};

      if (!fromSmall &&
          !isDokumenAbsen &&
          isMasukAtauPulang &&
          !isDiluarRadius) {
        final fotoFile = selectedFileImage.value;
        if (fotoFile == null) {
          ToastService.show("Silahkan ambil foto terlebih dahulu.");
          isLoading.value = false;
          return;
        }
        files["foto"] = fotoFile;
        print("📸 Foto terdeteksi: ${fotoFile.path}");
      } else if (isDokumenAbsen) {
        final docFile = selectedFileDocument.value;
        if (docFile == null) {
          ToastService.show("Silahkan pilih dokumen terlebih dahulu.");
          isLoading.value = false;
          return;
        }

        if (!await docFile.exists()) {
          final newPath =
              "${(await getApplicationDocumentsDirectory()).path}/${docFile.path.split('/').last}";
          final newFile = await docFile.copy(newPath);
          files["dokumen"] = newFile;
          print("📄 Dokumen disalin ke path permanen: $newPath");
        } else {
          files["dokumen"] = docFile;
        }

        print("📄 Dokumen terdeteksi: ${files["dokumen"]!.path}");
      } else if (isDiluarRadius) {
        final docFile = selectedFileDocument.value;
        if (docFile == null) {
          ToastService.show("Silahkan pilih dokumen terlebih dahulu.");
          isLoading.value = false;
          return;
        }
        files["dokumen"] = docFile;
        print("📍 Absen luar radius: ${docFile.path}");
      } else {
        ToastService.show(
            "Kondisi absen tidak valid. Periksa kembali status Anda.");
        isLoading.value = false;
        return;
      }

      print("files: $files");

      final response = await HttpService.requestMultipart(
        url: url,
        type: RequestType.post,
        fields: fields,
        files: files,
        showLoading: true,
        onError: (error) {
          ToastService.show("Gagal mengirim absen: $error");
        },
        onStatus: (statusCode) {
          if (statusCode == 422) {
            ToastService.show(HttpService.getErrorMessage(statusCode));
          }
        },
      );

      if (response != null && response['data'] != null) {
        HomeController.isLoading.value = true;
        Get.back();

        await BerandaController.getAbsenSiswa();
        await HomeController.getLocation();
        ToastService.show("Absensi berhasil dikirim!");
        HomeController.isLoading.value = false;

        selectedFileDocument.value = null;
        selectedFileImage.value = null;
        noteC.clear();
      }

      update();
    } catch (e) {
      ToastService.show("Terjadi kesalahan: $e");
      print("❌ Error absen: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _resolveAbsenUrl(String jenis, String general, bool isDiluarRadius) {
    if (isDiluarRadius) {
      return "${ApiUrl.dataPostAbsenSiswaUrl}/izin-sakit-dispensasi";
    }

    if (jenis == "Masuk" || (general == "Masuk" && jenis == "TepatWaktu")) {
      return "${ApiUrl.dataPostAbsenSiswaUrl}/masuk";
    }
    if (jenis == "Pulang" || (general == "Pulang" && jenis == "TepatWaktu")) {
      return "${ApiUrl.dataPostAbsenSiswaUrl}/pulang";
    }
    if (jenis == "Telat") {
      return "${ApiUrl.dataPostAbsenSiswaUrl}/masuk-telat";
    }
    if (jenis == "IzinOrSakitOrDispensasi" ||
        jenis == "IzinOrSakitOrDispensasiOrTelat") {
      return "${ApiUrl.dataPostAbsenSiswaUrl}/izin-sakit-dispensasi";
    }

    return ApiUrl.dataPostAbsenSiswaUrl;
  }

  String parseJenisAbsen(String jenis) {
    switch (jenis.toLowerCase()) {
      case "hadir":
        return "Hadir";
      case "telat":
        return "Telat";
      case "izin":
        return "Izin";
      case "tidak_hadir":
        return "Alpa";
      case "sakit":
        return "Sakit";
      case "tepatwaktu":
        return "Tepat Waktu";
      case "dispensasi":
        return "Dispensasi";
      default:
        return "";
    }
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

  @override
  void onInit() {
    super.onInit();
    noteC.addListener(() {
      noteText.value = noteC.text;
    });
  }
}
