import 'dart:async';

import 'package:absensi_smamahardhika/app/data/apis/api_url.dart';
import 'package:absensi_smamahardhika/app/data/models/list_data_absen_siswa_model.dart';
import 'package:absensi_smamahardhika/app/data/models/list_data_jadwal_model.dart';
import 'package:absensi_smamahardhika/app/modules/home/controllers/home_controller.dart';
import 'package:absensi_smamahardhika/app/services/http_service.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:get/get.dart';

class BerandaController extends GetxController {
  static final jadwalHariIni = Rx<JadwalModel?>(null);
  static final jadwalTigaHari = <AbsenSiswaModel>[].obs;

  static Future<void> getAbsenSiswa() async {
    if (HomeController.isLoading.isFalse) {
      HomeController.isLoading.value = true;
    }
    try {
      final response = await HttpService.request(
        url:
            "${ApiUrl.dataAbsenSiswaUrl}?id_tahun=${AllMaterial.idSelectedTahun}&today=true",
        type: RequestType.get,
        onError: (error) {
          print(error);
        },
        onStuck: (error) {
          print(error);
        },
        showLoading: false,
      );

      if (response != null && response['data'] != null) {
        final list = (response['data'] as List)
            .map((e) => AbsenSiswaModel.fromJson(e))
            .toList();

        jadwalTigaHari.assignAll(list);
      }
    } catch (e) {
      print(e);
      HomeController.isLoading.value = false;
    }
  }

  static Future<void> getDataJadwalHariIni() async {
    if (HomeController.isLoading.isFalse) {
      HomeController.isLoading.value = true;
    }
    try {
      final response = await HttpService.request(
        url:
            "${ApiUrl.dataJadwalHariIniUrl}?id_tahun_ajaran=${AllMaterial.idSelectedTahun.value}",
        type: RequestType.get,
        onError: (error) {
          print(error);
        },
        onStuck: (error) {
          print(error);
        },
        showLoading: false,
      );

      if (response != null && response['data'] != null) {
        jadwalHariIni.value = JadwalModel.fromJson(response["data"]);
        print(
            'Jadwal berhasil di-set: ${BerandaController.jadwalHariIni.value?.toJson()}');

        // var jamPulangStr = jadwalHariIni.value?.batasJamPulang;
        // bool sudahJadwalDibuat = false;

        // if (jamPulangStr != null && jamPulangStr.isNotEmpty) {
        //   final now = DateTime.now();
        //   final formatter = DateFormat("HH:mm");

        //   try {
        //     final parsedJam = formatter.parse(jamPulangStr);
        //     final jamPulang = DateTime(
        //         now.year, now.month, now.day, parsedJam.hour, parsedJam.minute);

        //     final waktuTarget = jamPulang.add(const Duration(minutes: 1));
        //     final sisaWaktu = waktuTarget.difference(now);

        //     _jadwalRefreshTimer?.cancel();

        //     if (sisaWaktu.isNegative) {
        //       print(
        //           "⏰ Jam pulang sudah lewat, langsung refresh data sekarang.");
        //       HomeController.refreshData();
        //       sudahJadwalDibuat = true;
        //     } else {
        //       print(
        //           "⏰ Menjadwalkan refresh otomatis pada: ${waktuTarget.toLocal()} (dalam ${sisaWaktu.inMinutes} menit)");
        //       _jadwalRefreshTimer = Timer(sisaWaktu, () {
        //         print("🔄 Waktu refresh otomatis tercapai!");
        //         HomeController.refreshData();
        //       });
        //       sudahJadwalDibuat = true;
        //     }
        //   } catch (e) {
        //     print("⚠️ Gagal parsing jam pulang: $e");
        //   }
        // }

        // if (!sudahJadwalDibuat) {
        //   HomeController.refreshData();
        // }
      }
    } catch (e) {
      print(e);
    } finally {
      HomeController.isLoading.value = false;
    }
  }
}
