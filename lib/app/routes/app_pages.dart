import 'package:get/get.dart';

import '../modules/beranda/bindings/beranda_binding.dart';
import '../modules/beranda/views/beranda_view.dart';
import '../modules/buat_absen/bindings/buat_absen_binding.dart';
import '../modules/buat_absen/views/buat_absen_view.dart';
import '../modules/histori_absen/bindings/histori_absen_binding.dart';
import '../modules/histori_absen/views/histori_absen_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/jadwal_absen/bindings/jadwal_absen_binding.dart';
import '../modules/jadwal_absen/views/jadwal_absen_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/lokasi_absen/bindings/lokasi_absen_binding.dart';
import '../modules/lokasi_absen/views/lokasi_absen_view.dart';
import '../modules/notifikasi/bindings/notifikasi_binding.dart';
import '../modules/notifikasi/views/notifikasi_view.dart';
import '../modules/pengaturan/bindings/pengaturan_binding.dart';
import '../modules/pengaturan/views/pengaturan_view.dart';
import '../modules/profil/bindings/profil_binding.dart';
import '../modules/profil/views/profil_view.dart';
import '../modules/riwayat_absen/bindings/riwayat_absen_binding.dart';
import '../modules/riwayat_absen/views/riwayat_absen_view.dart';
import '../modules/tentang_aplikasi/bindings/tentang_aplikasi_binding.dart';
import '../modules/tentang_aplikasi/views/tentang_aplikasi_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // ignore: constant_identifier_names
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.BERANDA,
      page: () => const BerandaView(),
      binding: BerandaBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFIKASI,
      page: () => const NotifikasiView(),
      binding: NotifikasiBinding(),
    ),
    GetPage(
      name: _Paths.PROFIL,
      page: () => const ProfilView(),
      binding: ProfilBinding(),
    ),
    GetPage(
      name: _Paths.PENGATURAN,
      page: () => const PengaturanView(),
      binding: PengaturanBinding(),
    ),
    GetPage(
      name: _Paths.HISTORI_ABSEN,
      page: () => const HistoriAbsenView(),
      binding: HistoriAbsenBinding(),
    ),
    GetPage(
      name: _Paths.BUAT_ABSEN,
      page: () => const BuatAbsenView(),
      binding: BuatAbsenBinding(),
    ),
    GetPage(
      name: _Paths.RIWAYAT_ABSEN,
      page: () => const RiwayatAbsenView(),
      binding: RiwayatAbsenBinding(),
    ),
    GetPage(
      name: _Paths.TENTANG_APLIKASI,
      page: () => const TentangAplikasiView(),
      binding: TentangAplikasiBinding(),
    ),
    GetPage(
      name: _Paths.JADWAL_ABSEN,
      page: () => const JadwalAbsenView(),
      binding: JadwalAbsenBinding(),
    ),
    GetPage(
      name: _Paths.LOKASI_ABSEN,
      page: () => const LokasiAbsenView(),
      binding: LokasiAbsenBinding(),
    ),
  ];
}
