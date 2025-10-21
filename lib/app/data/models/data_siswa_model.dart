// To parse this JSON data, do
//
//     final dataSiswaModel = dataSiswaModelFromJson(jsonString);

import 'dart:convert';

DataSiswaModel dataSiswaModelFromJson(String str) =>
    DataSiswaModel.fromJson(json.decode(str));

String dataSiswaModelToJson(DataSiswaModel data) => json.encode(data.toJson());

class DataSiswaModel {
  String? message;
  Data? data;

  DataSiswaModel({
    this.message,
    this.data,
  });

  factory DataSiswaModel.fromJson(Map<String, dynamic> json) => DataSiswaModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  int? id;
  int? idOrangtua;
  String? nis;
  String? nama;
  String? nisn;
  String? jenisKelamin;
  String? fotoUrl;
  Orangtua? orangtua;

  Data({
    this.id,
    this.idOrangtua,
    this.nis,
    this.nama,
    this.nisn,
    this.jenisKelamin,
    this.fotoUrl,
    this.orangtua,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        idOrangtua: json["id_orangtua"],
        nis: json["nis"],
        nama: json["nama"],
        nisn: json["nisn"],
        fotoUrl: json["foto_url"],
        jenisKelamin: json["jenis_kelamin"],
        orangtua: json["orangtua"] == null
            ? null
            : Orangtua.fromJson(json["orangtua"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_orangtua": idOrangtua,
        "nis": nis,
        "nama": nama,
        "foto_url": fotoUrl,
        "nisn": nisn,
        "jenis_kelamin": jenisKelamin,
        "orangtua": orangtua?.toJson(),
      };
}

class Orangtua {
  int? id;
  String? nama;
  String? alamat;
  String? jenisKelamin;
  String? noTelepon;

  Orangtua({
    this.id,
    this.nama,
    this.alamat,
    this.jenisKelamin,
    this.noTelepon,
  });

  factory Orangtua.fromJson(Map<String, dynamic> json) => Orangtua(
        id: json["id"],
        nama: json["nama"],
        alamat: json["alamat"],
        jenisKelamin: json["jenis_kelamin"],
        noTelepon: json["no_telepon"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "alamat": alamat,
        "jenis_kelamin": jenisKelamin,
        "no_telepon": noTelepon,
      };
}
