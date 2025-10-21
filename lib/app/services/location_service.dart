import 'package:absensi_smamahardhika/app/data/models/list_koordinat_lokasi.dart';
import 'package:geolocator/geolocator.dart';
import 'package:absensi_smamahardhika/app/modules/home/controllers/home_controller.dart';
import 'package:intl/intl.dart';

class GeoLocationService {
  static String calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final distanceMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);

    if (distanceMeters >= 1000) {
      final distanceKm = distanceMeters / 1000;
      final formatted = NumberFormat("#,##0.00", "id_ID").format(distanceKm);
      return "$formatted km";
    } else {
      final formatted =
          NumberFormat("#,##0.##", "id_ID").format(distanceMeters);
      return "$formatted m";
    }
  }

  static String formatDistance(distanceMeters) {
    if (distanceMeters >= 1000) {
      final distanceKm = distanceMeters / 1000;
      final formatted = NumberFormat("#,##0.00", "id_ID").format(distanceKm);
      return "$formatted km";
    } else {
      final formatted =
          NumberFormat("#,##0.##", "id_ID").format(distanceMeters);
      return "$formatted m";
    }
  }

  static NearestResult findNearestPlace({
    required double userLat,
    required double userLon,
    required List<KoordinatLokasi> places,
    bool onlyActive = true,
  }) {
    if (places.isEmpty) {
      return NearestResult(
        place: null,
        distanceMeters: double.infinity,
        insideRadius: false,
      );
    }

    KoordinatLokasi? nearest;
    double minDist = double.infinity;

    for (var p in places) {
      if (onlyActive && (p.isActive == false)) continue;

      final lat = p.latitude ?? 0;
      final lon = p.longitude ?? 0;
      final dist = Geolocator.distanceBetween(userLat, userLon, lat, lon);

      if (dist < minDist) {
        minDist = dist;
        nearest = p;
      }
    }

    if (nearest == null) {
      return NearestResult(
        place: null,
        distanceMeters: double.infinity,
        insideRadius: false,
      );
    }

    final radius = (nearest.radiusAbsenMeter ?? 0).toDouble();
    final inside = minDist <= radius;

    return NearestResult(
      place: nearest,
      distanceMeters: minDist,
      insideRadius: inside,
    );
  }

  static void handleLocationCheck({
    required double userLat,
    required double userLon,
    required List<KoordinatLokasi> placesFromServer,
  }) {
    final result = findNearestPlace(
      userLat: userLat,
      userLon: userLon,
      places: placesFromServer,
    );

    if (result.place == null) {
      HomeController.diluarRadius.value = true;
      HomeController.koordinatTerdekat.value = null;
      HomeController.catatanAbsen.value = "Lokasi absensi tidak ditemukan.";
      return;
    }

    final lokasi = result.place!;

    HomeController.koordinatTerdekat.value = lokasi;

    print("koordinatTerdekat: ${lokasi.toJson()}");
  }
}

class NearestResult {
  final KoordinatLokasi? place;
  final double distanceMeters;
  final bool insideRadius;

  NearestResult({
    required this.place,
    required this.distanceMeters,
    required this.insideRadius,
  });
}
