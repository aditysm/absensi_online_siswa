import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tentang_aplikasi_controller.dart';

class TentangAplikasiView extends GetView<TentangAplikasiController> {
  const TentangAplikasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TentangAplikasiController());
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        title: const Text('Tentang Aplikasi'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                  size: 72,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                controller.appName.value,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                "Versi ${controller.version.value} (Build ${controller.buildNumber.value})",
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              _buildDividerTitle("Informasi Aplikasi", colorScheme),
              _infoTile(
                context,
                icon: Icons.developer_mode,
                title: "Pengembang",
                subtitle: "Tim Pengembang Global Vintage Numeration",
              ),
              _infoTile(
                context,
                icon: Icons.email_outlined,
                title: "Kontak",
                subtitle: "developer.gvinum@gmail.com",
              ),
              _infoTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: "Kebijakan Privasi",
                subtitle: "Data Anda aman dan terenkripsi",
              ),
              _infoTile(
                context,
                icon: Icons.description_outlined,
                title: "Lisensi",
                subtitle: "Aplikasi ini dilindungi oleh hukum hak cipta",
              ),
              const SizedBox(height: 15),
              Text(
                "© 2025 CV. Bale Kotak GVINUM",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(
          title,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildDividerTitle(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant.withOpacity(0.4),
              endIndent: 8,
              thickness: 0.7,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant.withOpacity(0.4),
              indent: 8,
              thickness: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}
