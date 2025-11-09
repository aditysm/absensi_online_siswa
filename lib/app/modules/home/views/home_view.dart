import 'package:absensi_smamahardhika/app/modules/jadwal_absen/views/jadwal_absen_view.dart';
import 'package:absensi_smamahardhika/app/modules/lokasi_absen/views/lokasi_absen_view.dart';
import 'package:absensi_smamahardhika/app/modules/riwayat_absen/controllers/riwayat_absen_controller.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:absensi_smamahardhika/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/home_controller.dart';
import 'package:absensi_smamahardhika/app/modules/beranda/views/beranda_view.dart';
import 'package:absensi_smamahardhika/app/modules/pengaturan/views/pengaturan_view.dart';
import 'package:absensi_smamahardhika/app/modules/profil/views/profil_view.dart';
import 'package:absensi_smamahardhika/app/modules/riwayat_absen/views/riwayat_absen_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final controller = Get.put(HomeController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (HomeController.dataSiswa.value == null) {
      HomeController.getDataSiswa();
    }

    final pages = const [
      BerandaView(),
      JadwalAbsenView(),
      LokasiAbsenView(),
      RiwayatAbsenView(),
      ProfilView(),
    ];
    // ignore: no_leading_underscores_for_local_identifiers
    DateTime? _lastBackPressed;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (HomeController.selectedIndex.value != 0) {
          HomeController.selectedIndex.value = 0;
          HomeController.onPageChanged(0);
          HomeController.pageController.jumpToPage(0);
          return false;
        } else {
          final now = DateTime.now();
          if (_lastBackPressed == null ||
              now.difference(_lastBackPressed!) > Duration(seconds: 2)) {
            _lastBackPressed = now;
            ToastService.show("Tekan sekali lagi untuk keluar");
            return false;
          }
          return true;
        }
      },
      child: Scaffold(
        extendBody: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 6),
          child: Obx(
            () => AppBar(
              backgroundColor: colorScheme.surface,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              centerTitle: false,
              titleSpacing: 16,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.primary.withOpacity(0.12),
                    child: Image.asset(
                      "assets/images/logo-mahardika.png",
                      scale: 2.2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(
                      () => Text(
                        HomeController.selectedIndex.value == 1
                            ? "Jadwal Absen"
                            : HomeController.selectedIndex.value == 2
                                ? "Lokasi Absen"
                                : HomeController.selectedIndex.value == 3
                                    ? "Histori Absen"
                                    : HomeController.selectedIndex.value == 4
                                        ? "Profil Saya"
                                        : "SMAS Mahardhika Surabaya",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                if (HomeController.selectedIndex.value == 3)
                  Obx(() => Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.filter_alt_outlined),
                            onPressed: () =>
                                RiwayatAbsenController.openFilterDialog(
                                    context),
                          ),
                          if (RiwayatAbsenController.activeFilterCount.value >
                              0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  RiwayatAbsenController.activeFilterCount.value
                                      .toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )),
                Obx(() {
                  final sortedKeys = HomeController.dataTahun.keys.toList()
                    ..sort((a, b) => b.compareTo(a));
                  final selectedTahun = AllMaterial.selectedTahun.value;

                  return PopupMenuButton<String>(
                    tooltip: "Tahun Ajar",
                    icon: Icon(Icons.event_note, size: 24),
                    onSelected: (value) async {
                      if (HomeController.ta.value == value) return;
                      HomeController.setYear(value);
                      AllMaterial.selectedTahun.value = value;
                      await HomeController.fetchData();
                      HomeController.ta.value = value;
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem<String>(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          enabled: false,
                          height: 0,
                          child: Row(
                            children: [
                              Icon(
                                Icons.event_note,
                                size: 20,
                                color: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.color,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Pilih Tahun Ajar",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.color,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...sortedKeys.map((tahun) {
                          final isSelected = selectedTahun == tahun;
                          return PopupMenuItem<String>(
                            value: tahun,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    tahun,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected ? Colors.blue : null,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                              ],
                            ),
                          );
                        }),
                      ];
                    },
                  );
                }),
                if (HomeController.selectedIndex.value == 4)
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      Get.to(() => const PengaturanView(),
                          transition: Transition.cupertino);
                    },
                    tooltip: 'Pengaturan',
                  ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
        body: Obx(
          () {
            if (HomeController.isLoadingFirst.value ||
                HomeController.isLoadingRefresh.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSkeletonLoading(context),
              );
            } else {
              return PageView(
                controller: HomeController.pageController,
                onPageChanged: HomeController.onPageChanged,
                children: pages,
              );
            }
          },
        ),
        bottomNavigationBar: Obx(
          () => IgnorePointer(
            ignoring: HomeController.isLoading.value,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.95),
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.05),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.transparent,
                  indicatorColor: colorScheme.primary.withOpacity(0.15),
                  labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                    (states) => TextStyle(
                      fontWeight: states.contains(WidgetState.selected)
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 12.5,
                      color: states.contains(WidgetState.selected)
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                child: NavigationBar(
                  height: 65,
                  animationDuration: const Duration(milliseconds: 450),
                  selectedIndex: HomeController.selectedIndex.value,
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,
                  onDestinationSelected: HomeController.onNavTapped,
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.home_outlined),
                      selectedIcon:
                          Icon(Icons.home_rounded, color: colorScheme.primary),
                      label: 'Beranda',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.watch_later_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      selectedIcon: Icon(
                        Icons.watch_later_rounded,
                        color: colorScheme.primary,
                      ),
                      label: 'Jadwal',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.location_on_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      selectedIcon: Icon(
                        Icons.location_on,
                        color: colorScheme.primary,
                      ),
                      label: 'Lokasi',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.assignment_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      selectedIcon: Icon(
                        Icons.assignment_rounded,
                        color: colorScheme.primary,
                      ),
                      label: 'Histori',
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person_rounded,
                          color: colorScheme.primary),
                      label: 'Profil',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading(BuildContext context) {
    return Obx(() {
      final isDark = AllMaterial.isDarkMode.value;

      final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
      final highlightColor = isDark ? Colors.grey[600]! : Colors.grey[100]!;
      final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

      return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: List.generate(
                          4,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            height: 80,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
