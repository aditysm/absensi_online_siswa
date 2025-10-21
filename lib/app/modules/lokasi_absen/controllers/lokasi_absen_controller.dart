import 'package:absensi_smamahardhika/app/data/apis/api_url.dart';
import 'package:absensi_smamahardhika/app/data/models/list_koordinat_lokasi.dart';
import 'package:absensi_smamahardhika/app/modules/home/controllers/home_controller.dart';
import 'package:absensi_smamahardhika/app/services/http_service.dart';
import 'package:absensi_smamahardhika/app/services/location_service.dart';
import 'package:get/get.dart';

class LokasiAbsenController extends GetxController {
  static final RxBool isLoading = false.obs;
  static final RxBool isLoadingFirst = true.obs;
  static var dataKoordinatLokasi = <KoordinatLokasi>[].obs;

  static Future<void> getKoordinatLokasi() async {
    isLoading.value = true;
    try {
      final response = await HttpService.request(
        url: ApiUrl.dataKoordinatLokasiUrl,
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
            .map((e) => KoordinatLokasi.fromJson(e))
            .toList();

        dataKoordinatLokasi.assignAll(list);

        GeoLocationService.handleLocationCheck(
          userLat: HomeController.latitude.value ?? 0,
          userLon: HomeController.longitude.value ?? 0,
          placesFromServer: dataKoordinatLokasi,
        );

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

  Future<void> onRefreshData() async {
    try {
      await getKoordinatLokasi();
    } catch (e) {
      print(e);
    }
  }
}
