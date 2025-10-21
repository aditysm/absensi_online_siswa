// To parse this JSON data, do
//
//     final listKelasSiswaModel = listKelasSiswaModelFromJson(jsonString);

import 'dart:convert';

ListKelasSiswaModel listKelasSiswaModelFromJson(String str) =>
    ListKelasSiswaModel.fromJson(json.decode(str));

String listKelasSiswaModelToJson(ListKelasSiswaModel data) =>
    json.encode(data.toJson());

class ListKelasSiswaModel {
  String? message;
  List<KelasSiswaModel>? data;

  ListKelasSiswaModel({
    this.message,
    this.data,
  });

  factory ListKelasSiswaModel.fromJson(Map<String, dynamic> json) =>
      ListKelasSiswaModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<KelasSiswaModel>.from(
                json["data"]!.map((x) => KelasSiswaModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class KelasSiswaModel {
  int? id;
  int? idJurusan;
  String? nama;
  Jurusan? jurusan;
  Jurusan? tahunAjaran;

  KelasSiswaModel({
    this.id,
    this.idJurusan,
    this.nama,
    this.jurusan,
    this.tahunAjaran,
  });

  factory KelasSiswaModel.fromJson(Map<String, dynamic> json) =>
      KelasSiswaModel(
        id: json["id"],
        idJurusan: json["id_jurusan"],
        nama: json["nama"],
        jurusan:
            json["jurusan"] == null ? null : Jurusan.fromJson(json["jurusan"]),
        tahunAjaran: json["tahun_ajaran"] == null
            ? null
            : Jurusan.fromJson(json["tahun_ajaran"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_jurusan": idJurusan,
        "nama": nama,
        "jurusan": jurusan?.toJson(),
        "tahun_ajaran": tahunAjaran?.toJson(),
      };
}

class Jurusan {
  int? id;
  String? nama;

  Jurusan({
    this.id,
    this.nama,
  });

  factory Jurusan.fromJson(Map<String, dynamic> json) => Jurusan(
        id: json["id"],
        nama: json["nama"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
      };
}
