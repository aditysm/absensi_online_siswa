// To parse this JSON data, do
//
//     final listKoordinatModel = listKoordinatModelFromJson(jsonString);

import 'dart:convert';

ListKoordinatModel listKoordinatModelFromJson(String str) =>
    ListKoordinatModel.fromJson(json.decode(str));

String listKoordinatModelToJson(ListKoordinatModel data) =>
    json.encode(data.toJson());

class ListKoordinatModel {
  String? message;
  List<KoordinatLokasi>? data;

  ListKoordinatModel({
    this.message,
    this.data,
  });

  factory ListKoordinatModel.fromJson(Map<String, dynamic> json) =>
      ListKoordinatModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<KoordinatLokasi>.from(
                json["data"]!.map((x) => KoordinatLokasi.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class KoordinatLokasi {
  int? id;
  String? namaTempat;
  double? latitude;
  double? longitude;
  double? radiusAbsenMeter;
  bool? isActive;

  KoordinatLokasi({
    this.id,
    this.namaTempat,
    this.latitude,
    this.longitude,
    this.radiusAbsenMeter,
    this.isActive,
  });

  factory KoordinatLokasi.fromJson(Map<String, dynamic> json) =>
      KoordinatLokasi(
        id: json["id"],
        namaTempat: json["nama_tempat"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        radiusAbsenMeter: json["radius_absen_meter"],
        isActive: json["is_active"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama_tempat": namaTempat,
        "latitude": latitude,
        "longitude": longitude,
        "radius_absen_meter": radiusAbsenMeter,
        "is_active": isActive,
      };
}
