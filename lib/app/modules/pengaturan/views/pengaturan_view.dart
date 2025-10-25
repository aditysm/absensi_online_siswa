import 'package:absensi_smamahardhika/app/controllers/general_controller.dart';
import 'package:absensi_smamahardhika/app/modules/tentang_aplikasi/views/tentang_aplikasi_view.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:absensi_smamahardhika/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/pengaturan_controller.dart';

class PengaturanView extends GetView<PengaturanController> {
  const PengaturanView({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final controller = Get.put(PengaturanController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: colorScheme.surface,
        title: const Text('Pengaturan'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          children: [
            // _sectionHeader("Akun Pengguna"),
            // _settingTile(
            //   context,
            //   icon: Icons.person_outline,
            //   title: "Edit Profil",
            //   subtitle: "Ubah nama, foto, dan data siswa",
            //   onTap: () => Get.toNamed('/edit_profil'),
            // ),
            // _settingTile(
            //   context,
            //   icon: Icons.lock_reset_outlined,
            //   title: "Ganti Kata Sandi",
            //   subtitle: "Atur ulang kata sandi akun Anda",
            //   onTap: () => Get.toNamed('/ubah_password'),
            // ),
            // const SizedBox(height: 24),
            _sectionHeader("Tampilan"),
            Obx(
              () => _switchTile(
                context,
                icon: Icons.dark_mode_outlined,
                title: "Mode Gelap",
                value: AllMaterial.isDarkMode.value,
                onChanged: PengaturanController.toggleDarkMode,
              ),
            ),
            const SizedBox(height: 24),
            _sectionHeader("Preferensi Aplikasi"),
            _settingTile(
              context,
              icon: Icons.location_on_outlined,
              title: "Izin Lokasi & Kamera",
              subtitle: "Kelola izin GPS dan kamera untuk absensi",
              onTap: () async => openAppSettings(),
            ),
            _settingTile(context,
                icon: Icons.update_outlined,
                title: "Cek Pembaruan",
                subtitle: "Versi terbaru dari Esensi Online Siswa",
                onTap: () =>
                    ToastService.show("Belum ada pembaruan tersedia.")),
            _settingTile(
              context,
              icon: Icons.feedback_outlined,
              title: "Kirim Masukan",
              subtitle: "Laporkan bug atau berikan saran",
              onTap: () => AllMaterial.umpanPengguna(context),
            ),
            const SizedBox(height: 24),
            _sectionHeader("Tentang"),
            _settingTile(
              context,
              icon: Icons.info_outline,
              title: "Tentang Aplikasi",
              subtitle: "Versi, pengembang, dan informasi lainnya",
              onTap: () => Get.to(() => TentangAplikasiView()),
            ),
            _settingTile(
              context,
              icon: Icons.support_agent_outlined,
              title: "Hubungi Admin Sekolah",
              subtitle: "Bantuan dan dukungan teknis",
              onTap: () =>
                  ToastService.show("Mengarahkan ke WhatsApp admin sekolah..."),
            ),
            const SizedBox(height: 24),
            _sectionHeader("Aksi"),
            _settingTile(
              context,
              icon: Icons.logout,
              title: "Logout",
              subtitle: "Keluar dari akun ini",
              color: colorScheme.error,
              onTap: () => GeneralController.logout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15.5,
            letterSpacing: 0.2,
          ),
        ),
      );

  Widget _settingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: color ?? colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color ?? colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            (color ?? colorScheme.onSurface).withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () => PengaturanController.toggleDarkMode(!value),
      contentPadding: EdgeInsetsDirectional.zero,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
      leading: Icon(icon, color: colorScheme.primary, size: 24),
    );
  }
}
