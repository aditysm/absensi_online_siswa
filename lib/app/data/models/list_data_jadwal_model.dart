// To parse this JSON data, do
//
//     final listJadwalModel = listJadwalModelFromJson(jsonString);

import 'dart:convert';

ListJadwalModel listJadwalModelFromJson(String str) => ListJadwalModel.fromJson(json.decode(str));

String listJadwalModelToJson(ListJadwalModel data) => json.encode(data.toJson());

class ListJadwalModel {
    String? message;
    List<JadwalModel>? data;

    ListJadwalModel({
        this.message,
        this.data,
    });

    factory ListJadwalModel.fromJson(Map<String, dynamic> json) => ListJadwalModel(
        message: json["message"],
        data: json["data"] == null ? [] : List<JadwalModel>.from(json["data"]!.map((x) => JadwalModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class JadwalModel {
    int? id;
    String? hari;
    String? batasJamMasuk;
    String? minJamMasuk;
    String? maxJamMasuk;
    String? batasJamPulang;
    bool? specialDay;
    String? specialDayName;
    bool? isActive;
    int? idTahunAjaran;
    dynamic keterangan;

    JadwalModel({
        this.id,
        this.hari,
        this.batasJamMasuk,
        this.minJamMasuk,
        this.maxJamMasuk,
        this.batasJamPulang,
        this.specialDay,
        this.specialDayName,
        this.isActive,
        this.idTahunAjaran,
        this.keterangan,
    });

    factory JadwalModel.fromJson(Map<String, dynamic> json) => JadwalModel(
        id: json["id"],
        hari: json["hari"],
        batasJamMasuk: json["batas_jam_masuk"],
        minJamMasuk: json["min_jam_masuk"],
        maxJamMasuk: json["max_jam_masuk"],
        batasJamPulang: json["batas_jam_pulang"],
        specialDay: json["special_day"],
        specialDayName: json["special_day_name"],
        isActive: json["is_active"],
        idTahunAjaran: json["id_tahun_ajaran"],
        keterangan: json["keterangan"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "hari": hari,
        "batas_jam_masuk": batasJamMasuk,
        "min_jam_masuk": minJamMasuk,
        "max_jam_masuk": maxJamMasuk,
        "batas_jam_pulang": batasJamPulang,
        "special_day": specialDay,
        "special_day_name": specialDayName,
        "is_active": isActive,
        "id_tahun_ajaran": idTahunAjaran,
        "keterangan": keterangan,
    };
}
