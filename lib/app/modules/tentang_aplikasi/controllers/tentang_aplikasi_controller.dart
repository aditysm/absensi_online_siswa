import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class TentangAplikasiController extends GetxController {
  final box = GetStorage();

  var appName = ''.obs;
  var version = ''.obs;
  var buildNumber = ''.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAppInfo();
  }

  void loadAppInfo() async {
    final hasSaved = box.hasData('app_info');
    if (hasSaved) {
      final info = box.read('app_info');
      appName.value = info['appName'];
      version.value = info['version'];
      buildNumber.value = info['buildNumber'];
    } else {
      final info = await PackageInfo.fromPlatform();
      final savedData = {
        'appName': info.appName,
        'version': info.version,
        'buildNumber': info.buildNumber,
      };
      box.write('app_info', savedData);
      appName.value = info.appName;
      version.value = info.version;
      buildNumber.value = info.buildNumber;
    }
    isLoading.value = false;
  }
}
