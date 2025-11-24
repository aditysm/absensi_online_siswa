import 'package:absensi_smamahardhika/app/data/models/list_data_absen_siswa_model.dart';
import 'package:absensi_smamahardhika/app/utils/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/histori_absen_controller.dart';

class HistoriAbsenView extends GetView<HistoriAbsenController> {
  const HistoriAbsenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // ignore: unused_local_variable
    final controller = Get.put(HistoriAbsenController());
    final AbsenSiswaModel absen = Get.arguments["absen"];
    final bool isMasuk = Get.arguments["isMasuk"] ?? true;

    final status = isMasuk
        ? absen.absen?.status ?? ""
        : absen.absen?.statusAbsenPulang ?? "";
    final jam = isMasuk ? absen.absen?.absenMasuk : absen.absen?.absenPulang;
    final foto = isMasuk
        ? absen.absen?.fotoAbsenMasuk ?? ""
        : absen.absen?.fotoAbsenPulang ?? "";
    final note =
        isMasuk ? absen.absen?.noteMasuk ?? "" : absen.absen?.notePulang ?? "";
    final dokumen = isMasuk
        ? absen.absen?.dokumenMasuk ?? ""
        : absen.absen?.dokumenPulang ?? "";

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Detail Absensi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),  
        iconTheme: const IconThemeData(color: Colors.white),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       // TOD Share absensi
        //     },
        //     icon: const Icon(Icons.share),
        //     tooltip: "Bagikan Absen",
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                child: ListView(
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.task_alt_rounded,
                              size: 42,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isMasuk ? 'Absen Masuk' : 'Absen Pulang',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${AllMaterial.ubahHari(absen.absen?.tanggal?.toIso8601String() ?? "-")} • ${AllMaterial.ubahJamMenitDetik(jam ?? "-")}',
                            style: TextStyle(
                              color:
                                  colorScheme.onSurfaceVariant.withOpacity(0.7),
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          status.isNotEmpty == true
                              ? Icons.verified_rounded
                              : Icons.cancel_rounded,
                          color: status.isNotEmpty == true
                              ? Colors.green
                              : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status.isNotEmpty == true
                              ? "Absensi berhasil dicatat"
                              : "Absensi tidak dicatat",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: status.isNotEmpty == true
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _infoSection(
                      context,
                      title: "Informasi Absensi",
                      items: [
                        _infoRow(
                          "Status",
                          status,
                          colorScheme,
                          valueColor: _statusColor(status),
                        ),
                        if (isMasuk)
                          _infoRow(
                            "Jam Masuk",
                            AllMaterial.ubahJamMenitDetik(
                                absen.absen?.absenMasuk ?? "-"),
                            colorScheme,
                          ),
                        if (!isMasuk)
                          _infoRow(
                            "Jam Pulang",
                            AllMaterial.ubahJamMenitDetik(
                                absen.absen?.absenPulang ?? "-"),
                            colorScheme,
                          ),
                        if (foto.isNotEmpty)
                          _infoRow(
                            "Bukti",
                            foto,
                            colorScheme,
                            url: foto,
                            isImage: true,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (note.isNotEmpty && dokumen.isNotEmpty)
                      _infoSection(
                        context,
                        title: "Detail Tambahan",
                        items: [
                          if (note.isNotEmpty)
                            _infoRow(
                              "Catatan",
                              note,
                              colorScheme,
                            ),
                          if (dokumen.isNotEmpty)
                            _infoRow(
                              "Dokumen",
                              dokumen,
                              colorScheme,
                              url: dokumen,
                              isImage: false,
                            ),
                        ],
                      ),
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        "SMAS Mahardhika Surabaya",
                        style: TextStyle(
                          color: colorScheme.outline.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection(BuildContext context,
      {required String title, required List<Widget> items}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }

  Widget _infoRow(
    String title,
    String? value,
    ColorScheme colorScheme, {
    Color? valueColor,
    String? url,
    bool isImage = false,
  }) {
    final bool isClickable = url != null && url.isNotEmpty;

    Widget leading;
    if (isImage && isClickable) {
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.broken_image,
            size: 40,
            color: colorScheme.primary,
          ),
        ),
      );
    } else if (isClickable) {
      leading = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.insert_drive_file_rounded,
          color: colorScheme.primary,
          size: 28,
        ),
      );
    } else {
      leading = const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.8),
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: isClickable && isImage
                ? () async {
                    AllMaterial.showImagePopup(url);
                  }
                : isClickable && !isImage
                    ? () => AllMaterial.openFileOrUrl(url)
                    : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal:
                      (isImage && isClickable) || (!isImage && isClickable)
                          ? 10
                          : 0),
              decoration: BoxDecoration(
                color: isClickable
                    ? colorScheme.primary.withOpacity(0.08)
                    : colorScheme.surfaceContainerHighest.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: isClickable
                    ? Border.all(color: colorScheme.primary.withOpacity(0.3))
                    : null,
              ),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value?.isNotEmpty == true ? value! : "-",
                      style: TextStyle(
                        color: valueColor ??
                            (isClickable
                                ? colorScheme.primary
                                : colorScheme.onSurface),
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                        decoration:
                            isClickable ? TextDecoration.underline : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isClickable)
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Colors.green;
      case 'izin':
        return Colors.orange;
      case 'telat':
        return Colors.amber;
      case 'alpa':
        return Colors.redAccent;
      case 'sakit':
        return Colors.blue;
      case 'dispensasi':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
