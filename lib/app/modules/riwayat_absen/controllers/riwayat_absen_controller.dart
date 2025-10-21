import 'package:absensi_smamahardhika/app/data/apis/api_url.dart';
import 'package:absensi_smamahardhika/app/data/models/list_data_absen_siswa_model.dart';
import 'package:absensi_smamahardhika/app/modules/home/controllers/home_controller.dart';
import 'package:absensi_smamahardhika/app/services/http_service.dart';
import 'package:get/get.dart';

class RiwayatAbsenController extends GetxController {
  static final RxList<AbsenSiswaModel> dataAbsenSiswa = <AbsenSiswaModel>[].obs;

  static final RxBool isLoading = false.obs;
  static final RxBool isLoadingFirst = true.obs;

  Future<void> onRefreshData() async {
    try {
      await getAbsenSiswa();
    } catch (e) {
      print(e);
    }
  }

  static Future<void> getAbsenSiswa() async {
    isLoading.value = true;
    try {
      final response = await HttpService.request(
        url:
            "${ApiUrl.dataAbsenSiswaUrl}?id_tahun=${HomeController.idTahun.value}&today=false",
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
              .map((e) => AbsenSiswaModel.fromJson(e))
              .toList();

          dataAbsenSiswa.assignAll(list);

          if (isLoadingFirst.value) {
            isLoadingFirst.value = false;
          }
        }
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() async {
    await getAbsenSiswa();
    super.onInit();
  }
}
