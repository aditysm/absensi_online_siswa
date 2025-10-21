// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:absensi_smamahardhika/app/data/apis/api_url.dart';
import 'package:absensi_smamahardhika/app/data/models/data_siswa_model.dart';
import 'package:absensi_smamahardhika/app/data/models/list_kelas_siswa_model.dart';
import 'package:absensi_smamahardhika/app/data/models/list_koordinat_lokasi.dart';
import 'package:absensi_smamahardhika/app/modules/beranda/controllers/beranda_controller.dart';
import 'package:absensi_smamahardhika/app/modules/jadwal_absen/controllers/jadwal_absen_controller.dart';
import 'package:absensi_smamahardhika/app/modules/lokasi_absen/controllers/lokasi_absen_controller.dart';
import 'package:absensi_smamahardhika/app/modules/riwayat_absen/controllers/riwayat_absen_controller.dart';
import 'package:absensi_smamahardhika/app/services/http_service.dart';
import 'package:absensi_smamahardhika/app/services/location_service.dart';
import 'package:absensi_smamahardhika/app/utils/app_colors.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:absensi_smamahardhika/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

class HomeController extends GetxController {
  final List<String> tahunAjarList = [];
  static var ta = "".obs;
  static var selectedIndex = 0.obs;
  static var idTahun = 0.obs;
  static var latitude = Rx<double?>(null);
  static var longitude = Rx<double?>(null);
  static var isLoading = false.obs;
  static var isLoadingRefresh = false.obs;
  static var isLoadingFirst = true.obs;
  static var dataSiswa = Rx<DataSiswaModel?>(null);

  static var jarakTerdekatMeter = 0.0.obs;
  static var dataKelasSiswa = <KelasSiswaModel>[].obs;
  static var koordinatTerdekat = Rx<KoordinatLokasi?>(null);

  static var locationService = Location();
  var hariIni = AllMaterial.ubahHari(DateTime.now().toIso8601String());
  static var jenisAbsen = "".obs;
  static var jenisAbsenGeneral = "".obs;
  static var diluarRadius = true.obs;
  static var diluarRadiusMsg = "".obs;
  static var absenSelesai = false.obs;
  static var canAbsen = false.obs;
  static var catatanAbsen = "".obs;

  static bool _isAnimating = false;

  static PageController pageController = PageController();

  @override
  void onInit() async {
    await getAllTahunSekolahSiswa();
    await LokasiAbsenController.getKoordinatLokasi();
    await getLocation();
    await getDataSiswa();
    await BerandaController.getAbsenSiswa();
    await BerandaController.getDataJadwalHariIni();
    super.onInit();
  }

  static final Map<String, Map<String, dynamic>> dataTahun = {};
  static Future<void> fetchData({int? d}) async {
    final int usedIndex = d ?? HomeController.selectedIndex.value;

    if (AllMaterial.role.value == "admin") {
      if (ta.value != AllMaterial.selectedTahun.value) {
        print("Tahun ajaran berubah. Reset semua data...");

        HomeController.dataKelasSiswa.clear();
        HomeController.dataSiswa.value = null;
        BerandaController.jadwalHariIni.value = null;
        BerandaController.jadwalTigaHari.clear();
        JadwalAbsenController.dataJadwal.clear();
        RiwayatAbsenController.dataAbsenSiswa.clear();

        ta.value = AllMaterial.selectedTahun.value;
      }
    }

    switch (usedIndex) {
      case 0:
        if (HomeController.dataKelasSiswa.isEmpty) {
          await HomeController.getKelasSiswa();
        }
        if (HomeController.dataSiswa.value == null) {
          await HomeController.getDataSiswa();
        }

        if (BerandaController.jadwalHariIni.value == null) {
          await BerandaController.getDataJadwalHariIni();
        }

        if (BerandaController.jadwalTigaHari.isEmpty) {
          await BerandaController.getAbsenSiswa();
        }

        break;

      case 1:
        if (JadwalAbsenController.dataJadwal.isEmpty) {
          await JadwalAbsenController.getDataJadwalAbsen();
        }

        break;

      case 2:
        if (RiwayatAbsenController.dataAbsenSiswa.isEmpty) {
          await RiwayatAbsenController.getAbsenSiswa();
        }
        break;
      case 3:
        if (HomeController.dataSiswa.value == null) {
          await HomeController.getDataSiswa();
        }
        break;

      default:
        print("Index tidak dikenali: $usedIndex");
    }

    print("Tahun ajaran aktif: ${ta.value}");

    Get.find<HomeController>().update();
  }

  Future<void> getAllTahunSekolahSiswa() async {
    if (HomeController.isLoading.isFalse) {
      HomeController.isLoading.value = true;
    }
    try {
      final response = await HttpService.request(
        url: ApiUrl.dataTahunAjaranSiswaUrl,
        type: RequestType.get,
        showLoading: false,
      );

      if (response != null && response["data"] != null) {
        final List list = response["data"];
        dataTahun.clear();

        for (var item in list) {
          final String tahun = item["nama"] ?? "";
          final id = item["id"];
          if (id != null && tahun.isNotEmpty) {
            dataTahun[tahun] = {
              "id": id,
              "nama": tahun,
            };
          }
        }

        AllMaterial.box.write("tahunAjar", dataTahun);

        if (AllMaterial.selectedTahun.value.isEmpty &&
            HomeController.dataTahun.isNotEmpty) {
          final lastTahunKey = HomeController.dataTahun.keys.last;
          AllMaterial.selectedTahun.value = lastTahunKey;
          HomeController.ta.value = lastTahunKey;

          final tahunData = HomeController.dataTahun[lastTahunKey];
          if (tahunData != null && tahunData['id'] != null) {
            idTahun.value = tahunData['id'];
          }

          print("idTahun.value: ${idTahun.value}");
        }
      }

      update();
    } catch (e) {
      isLoading.value = false;
    }
  }

  static void setYear(String year) {
    AllMaterial.selectedTahun.value = year;
  }

  static Future<void> getDataSiswa() async {
    isLoading.value = true;
    try {
      final response = await HttpService.request(
        url: ApiUrl.dataSiswaUrl,
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
        dataSiswa.value = DataSiswaModel.fromJson(response);
        await getKelasSiswa();
        if (isLoadingFirst.value) {
          isLoadingFirst.value = false;
        }
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  static Future<void> getKelasSiswa() async {
    try {
      final response = await HttpService.request(
        url: "${ApiUrl.dataKelasSiswaUrl}?id_tahun=${idTahun.value}",
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
        if (response != null && response['data'] != null) {
          final list = (response['data'] as List)
              .map((e) => KelasSiswaModel.fromJson(e))
              .toList();

          dataKelasSiswa.assignAll(list);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> cekJenisAbsen(double? latitude, double? longitude) async {
    if (HomeController.isLoading.isFalse) {
      HomeController.isLoading.value = true;
    }
    try {
      final response = await HttpService.request(
        url: ApiUrl.dataCekAbsenJadwalHariIniUrl,
        type: RequestType.post,
        onError: (error) {
          print(error);
        },
        onStuck: (error) {
          print(error);
        },
        showLoading: false,
        body: {
          "latitude": latitude ?? 0.0,
          "longitude": longitude ?? 0.0,
        },
      );

      print("cekJenisAbsen: $response");
      if (response != null && response['data'] != null) {
        canAbsen.value = response['data']['can_absen'] ?? false;
        jenisAbsen.value = response['data']['status_absen'] ?? "";
        jenisAbsenGeneral.value = response['data']['jenis_absen'] ?? "";
        catatanAbsen.value = response['data']['note'] ?? "";
      }
    } catch (e) {
      print(e);
      isLoading.value = false;
    }
  }

  static Future<void> cekRadiusKoordinat(
    double? latitude,
    double? longitude,
  ) async {
    try {
      if (HomeController.isLoading.isFalse) {
        HomeController.isLoading.value = true;
      }

      final response = await HttpService.request(
        url: ApiUrl.dataCekRadiusKoordinatUrl,
        type: RequestType.post,
        showLoading: false,
        body: {
          "latitude": latitude ?? 0.0,
          "longitude": longitude ?? 0.0,
        },
        onError: (error) => print("Error: $error"),
        onStuck: (error) => print("Stuck: $error"),
      );

      if (response != null && response['data'] != null) {
        final inside = response['data']['inside_radius'] ?? false;
        String note = response['data']['note'] ?? "";
        jarakTerdekatMeter.value =
            double.tryParse(response['data']['distance'] ?? "0.0") ?? 0.0;

        diluarRadius.value = !inside;
        diluarRadiusMsg.value = note;

        final bool dark = AllMaterial.isDarkMode.value;
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: dark
                        ? AppColors.darkBackground
                        : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: inside
                          ? (dark
                              ? Colors.greenAccent.withOpacity(0.4)
                              : Colors.green.withOpacity(0.4))
                          : (dark
                              ? Colors.redAccent.withOpacity(0.4)
                              : Colors.red.withOpacity(0.4)),
                      width: 1.2,
                    ),
                    boxShadow: dark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        inside
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        size: 50,
                        color: inside
                            ? (dark
                                ? Colors.greenAccent.shade200
                                : Colors.greenAccent.shade400)
                            : (dark
                                ? Colors.redAccent.shade200
                                : Colors.redAccent.shade400),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        inside ? "Dalam Radius" : "Di Luar Radius",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: inside
                              ? (dark
                                  ? Colors.greenAccent.shade100
                                  : Colors.green.shade700)
                              : (dark
                                  ? Colors.redAccent.shade100
                                  : Colors.red.shade700),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        note.isNotEmpty
                            ? note
                            : (inside
                                ? "Anda berada di dalam area absensi."
                                : "Anda berada di luar area absensi."),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.5,
                          color: dark
                              ? Colors.grey.shade300
                              : Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 3,
                        width: 60,
                        decoration: BoxDecoration(
                          color: inside
                              ? (dark
                                  ? Colors.greenAccent.shade100.withOpacity(0.3)
                                  : Colors.greenAccent.shade100)
                              : (dark
                                  ? Colors.redAccent.shade100.withOpacity(0.3)
                                  : Colors.redAccent.shade100),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          barrierDismissible: false,
          transitionCurve: Curves.easeOutCubic,
          transitionDuration: const Duration(milliseconds: 300),
        );

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (Get.isDialogOpen ?? false) Get.back();
        });
      }
    } catch (e) {
      print("Exception: $e");
      ToastService.show("Gagal mengecek radius lokasi.");
    } finally {
      isLoading.value = false;
    }
  }

  static void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  static void onNavTapped(int index) async {
    if (index == selectedIndex.value) return;
    if (!pageController.hasClients) {
      selectedIndex.value = index;
      return;
    }

    if (_isAnimating) return;
    _isAnimating = true;

    try {
      await pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      pageController.jumpToPage(index);
      selectedIndex.value = index;
    } finally {
      await Future.delayed(const Duration(milliseconds: 50));
      _isAnimating = false;
    }
  }

  static Future<void> refreshData() async {
    isLoadingRefresh.value = true;
    try {
      await BerandaController.getDataJadwalHariIni();
      await BerandaController.getAbsenSiswa();
      await getLocation();
      GeoLocationService.handleLocationCheck(
        userLat: latitude.value ?? 0,
        userLon: longitude.value ?? 0,
        placesFromServer: LokasiAbsenController.dataKoordinatLokasi,
      );
    } catch (e) {
      print(e);
    } finally {
      isLoadingRefresh.value = false;
    }
  }

  static String get jenisAbsenLabel {
    final jenis = jenisAbsen.value;
    switch (jenis) {
      case "Masuk":
        return "Absen Masuk";
      case "Pulang":
        return "Absen Pulang";
      case "IzinOrSakitOrDispensasi":
      case "IzinOrSakitOrDispensasiOrTelat":
        return "Ajukan Izin / Sakit";
      default:
        return "Tidak Dapat Absen";
    }
  }

  static Future<void> getLocation() async {
    isLoading.value = true;
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await locationService.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await locationService.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await locationService.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await locationService.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    var userLocation = await locationService.getLocation();

    latitude.value = userLocation.latitude;
    longitude.value = userLocation.longitude;
    if (userLocation.latitude != null || userLocation.longitude != null) {
      isLoading.value = false;
      print("${userLocation.latitude} : ${userLocation.longitude}");
      await cekJenisAbsen(userLocation.latitude, userLocation.longitude);

      await cekRadiusKoordinat(userLocation.latitude, userLocation.longitude);
    }
  }
}
