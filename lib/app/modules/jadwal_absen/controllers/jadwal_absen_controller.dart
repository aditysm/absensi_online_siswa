import 'package:absensi_smamahardhika/app/data/apis/api_url.dart';
import 'package:absensi_smamahardhika/app/data/models/list_data_jadwal_model.dart';
import 'package:absensi_smamahardhika/app/services/http_service.dart';
import 'package:get/get.dart';

class JadwalAbsenController extends GetxController {
  static final RxList<JadwalModel> dataJadwal = <JadwalModel>[].obs;
  static final RxBool isLoading = false.obs;
  static final RxBool isLoadingFirst = true.obs;

  Future<void> onRefreshData() async {
    await getDataJadwalAbsen();
  }

  static Future<void> getDataJadwalAbsen() async {
    isLoading.value = true;
    try {
      final response = await HttpService.request(
        url: ApiUrl.dataJadwalAbsenUrl,
        type: RequestType.get,
        showLoading: false,
      );

      if (response != null && response['data'] is List) {
        final list = (response['data'] as List)
            .map((e) => JadwalModel.fromJson(e))
            .toList();
        dataJadwal.assignAll(list);
      }
    } catch (e) {
      print("Error getDataJadwalAbsen: $e");
    } finally {
      isLoading.value = false;
      isLoadingFirst.value = false;
    }
  }

  @override
  void onInit() {
    getDataJadwalAbsen();
    super.onInit();
  }
}
