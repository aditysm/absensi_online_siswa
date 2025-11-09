import 'package:absensi_smamahardhika/app/data/apis/api_url.dart';
import 'package:absensi_smamahardhika/app/data/models/filter_item_model.dart';
import 'package:absensi_smamahardhika/app/data/models/list_data_absen_siswa_model.dart';
import 'package:absensi_smamahardhika/app/modules/home/controllers/home_controller.dart';
import 'package:absensi_smamahardhika/app/services/http_service.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RiwayatAbsenController extends GetxController {
  static final RxList<AbsenSiswaModel> paginatedData = <AbsenSiswaModel>[].obs;
  static final RxList<AbsenSiswaModel> filteredData = <AbsenSiswaModel>[].obs;

  static final RxInt currentPage = 1.obs;
  static final int limit = 10;
  static final RxBool hasMore = true.obs;

  static final RxBool isLoading = false.obs;
  static final RxBool isLoadingFirst = true.obs;
  static final RxBool isFiltering = false.obs;

  static final RxInt activeFilterCount = 0.obs;
  static final filterStatusMasuk = ''.obs;
  static final filterStatusPulang = ''.obs;
  static final Rxn<DateTime> filterTanggal = Rxn<DateTime>();
  static final filterBulan = 0.obs;
  static final filterTanggalController = TextEditingController();

  static Future<void> getAbsenSiswa({bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      hasMore.value = true;
      paginatedData.clear();
    }

    if (!hasMore.value || isLoading.value) return;

    isLoading.value = true;

    try {
      final url =
          "${ApiUrl.dataAbsenSiswaPaginatedUrl}?id_tahun=${HomeController.idTahun.value}&today=false&page=${currentPage.value}&limit=$limit";

      final response = await HttpService.request(
        url: url,
        type: RequestType.get,
        showLoading: false,
      );

      final data = response?['data'];
      if (data != null && data['data'] != null) {
        final List<dynamic> jsonList = data['data'];
        final list = jsonList.map((e) => AbsenSiswaModel.fromJson(e)).toList();

        if (list.isEmpty) {
          hasMore.value = false;
        } else {
          paginatedData.addAll(list);
          currentPage.value++;
        }

        final totalPage = data['total_page'] ?? 1;
        if (currentPage.value > totalPage) {
          hasMore.value = false;
        }
      }

      if (isLoadingFirst.value) isLoadingFirst.value = false;
    } catch (e) {
      print("❌ getAbsenSiswa error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefreshData() async {
    try {
      await getAbsenSiswa();
    } catch (e) {
      print(e);
    }
  }

  static void updateFilterCount() {
    int count = 0;
    if (filterStatusMasuk.value.isNotEmpty) count++;
    if (filterStatusPulang.value.isNotEmpty) count++;
    if (filterTanggal.value != null) count++;
    if (filterBulan.value > 0) count++;
    activeFilterCount.value = count;
  }

  static Future<void> filterData({
    String? statusMasuk,
    String? statusPulang,
    DateTime? tanggal,
    int? bulan,
  }) async {
    isLoading.value = true;
    isFiltering.value = true;

    filterStatusMasuk.value = statusMasuk ?? '';
    filterStatusPulang.value = statusPulang ?? '';
    filterTanggal.value = tanggal;
    filterBulan.value = bulan ?? 0;

    try {
      final queryParams = <String, String>{
        "id_tahun": HomeController.idTahun.value.toString(),
        "today": "false",
      };

      if (filterStatusMasuk.value.isNotEmpty) {
        queryParams["status_absen_masuk"] = filterStatusMasuk.value;
      }
      if (filterStatusPulang.value.isNotEmpty) {
        queryParams["status_absen_pulang"] = filterStatusPulang.value;
      }
      if (filterTanggal.value != null) {
        final formattedTanggal =
            DateFormat('yyyy-MM-dd').format(filterTanggal.value!);
        queryParams["tanggal"] = formattedTanggal;
      }
      if (filterBulan.value > 0) {
        queryParams["bulan"] = filterBulan.value.toString();
      }

      updateFilterCount();

      final uri = Uri.parse(ApiUrl.dataAbsenSiswaUrl)
          .replace(queryParameters: queryParams);

      final response = await HttpService.request(
        url: uri.toString(),
        type: RequestType.get,
        showLoading: false,
      );

      if (response != null && response['data'] != null) {
        final list = (response['data'] as List)
            .map((e) => AbsenSiswaModel.fromJson(e))
            .toList();
        filteredData.assignAll(list);
      } else {
        filteredData.clear();
      }
    } catch (e) {
      print("❌ filterData error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  static void resetFilter() {
    filterStatusMasuk.value = '';
    filterStatusPulang.value = '';
    filterTanggal.value = null;
    filterBulan.value = 0;
    filterTanggalController.clear();

    filteredData.clear();
    isFiltering.value = false;
    updateFilterCount();

    getAbsenSiswa(reset: true);
  }

  static void openFilterDialog(BuildContext context) {
    final data = paginatedData;

    final statusMasukSet = data
        .map((e) => e.absen?.statusAbsenMasuk ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    final statusPulangSet = data
        .map((e) => e.absen?.statusAbsenPulang ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    final bulanMap = {
      1: "Januari",
      2: "Februari",
      3: "Maret",
      4: "April",
      5: "Mei",
      6: "Juni",
      7: "Juli",
      8: "Agustus",
      9: "September",
      10: "Oktober",
      11: "November",
      12: "Desember",
    };

    final statusMasukFilter = FilterItem<String>(
      label: "Status Absen Masuk",
      type: FilterType.dropdown,
      menuItems: statusMasukSet
          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
          .toList(),
      value: filterStatusMasuk,
    );

    final statusPulangFilter = FilterItem<String>(
      label: "Status Absen Pulang",
      type: FilterType.dropdown,
      menuItems: statusPulangSet
          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
          .toList(),
      value: filterStatusPulang,
    );

    final tanggalFilterWidget = Obx(() {
      final text = filterTanggal.value == null
          ? 'Pilih Tanggal'
          : DateFormat('dd-MM-yyyy').format(filterTanggal.value!);
      var theme = Theme.of(context);
      return GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: filterTanggal.value ?? DateTime.now(),
            firstDate: DateTime(2024),
            lastDate: DateTime(2030),
          );

          if (picked != null) {
            DateTime adjustedDate = picked;

            if (filterBulan.value != 0 && picked.month != filterBulan.value) {
              final tahun = picked.year;
              final bulan = filterBulan.value;
              final hari = picked.day;

              final lastDayOfMonth = DateUtils.getDaysInMonth(tahun, bulan);
              final fixedDay = hari > lastDayOfMonth ? lastDayOfMonth : hari;

              adjustedDate = DateTime(tahun, bulan, fixedDay);
            }

            if (filterBulan.value == 0) {
              filterBulan.value = adjustedDate.month;
            }

            filterTanggal.value = adjustedDate;
            filterTanggalController.text =
                DateFormat('dd-MM-yyyy').format(adjustedDate);
            updateFilterCount();
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            hintStyle: const TextStyle(fontWeight: FontWeight.normal),
            filled: true,
            suffixIcon: Icon(
              Icons.event_note_outlined,
              color: theme.textTheme.bodyLarge?.color,
            ),
            fillColor: theme.cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.dividerColor.withOpacity(0.4),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 1.2),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    });

    final bulanFilter = FilterItem<int>(
      label: "Bulan",
      type: FilterType.dropdown,
      menuItems: bulanMap.entries
          .map((e) => DropdownMenuItem<int>(
                value: e.key,
                child: Text(e.value),
              ))
          .toList(),
      value: filterBulan,
    );

    AllMaterial.openFilterDialog(
      title: "Riwayat Absen",
      context: context,
      items: [
        statusMasukFilter.toWidget(context, (v) {
          filterStatusMasuk.value = v ?? '';
          updateFilterCount();
        }),
        const SizedBox(height: 15),
        statusPulangFilter.toWidget(context, (v) {
          filterStatusPulang.value = v ?? '';
          updateFilterCount();
        }),
        const SizedBox(height: 15),
        tanggalFilterWidget,
        const SizedBox(height: 15),
        bulanFilter.toWidget(context, (v) {
          filterBulan.value = v ?? 0;

          if (filterTanggal.value != null &&
              filterTanggal.value!.month != filterBulan.value &&
              filterBulan.value != 0) {
            final old = filterTanggal.value!;
            final tahun = old.year;
            final hari = old.day;

            final lastDayOfMonth =
                DateUtils.getDaysInMonth(tahun, filterBulan.value);
            final fixedDay = hari > lastDayOfMonth ? lastDayOfMonth : hari;

            final newDate = DateTime(tahun, filterBulan.value, fixedDay);
            filterTanggal.value = newDate;
            filterTanggalController.text =
                DateFormat('dd-MM-yyyy').format(newDate);
          }

          updateFilterCount();
        }),
      ],
      onReset: resetFilter,
      onApply: () => activeFilterCount.value == 0
          ? Get.back()
          : filterData(
              statusMasuk: filterStatusMasuk.value,
              statusPulang: filterStatusPulang.value,
              tanggal: filterTanggal.value,
              bulan: filterBulan.value,
            ),
    );
  }

  @override
  void onInit() async {
    await getAbsenSiswa();
    super.onInit();
  }
}
