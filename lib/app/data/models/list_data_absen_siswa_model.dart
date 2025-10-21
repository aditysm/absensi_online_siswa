// To parse this JSON data, do
//
//     final listAbsenSiswaModel = listAbsenSiswaModelFromJson(jsonString);

import 'dart:convert';

ListAbsenSiswaModel listAbsenSiswaModelFromJson(String str) => ListAbsenSiswaModel.fromJson(json.decode(str));

String listAbsenSiswaModelToJson(ListAbsenSiswaModel data) => json.encode(data.toJson());

class ListAbsenSiswaModel {
    String? message;
    List<AbsenSiswaModel>? data;

    ListAbsenSiswaModel({
        this.message,
        this.data,
    });

    factory ListAbsenSiswaModel.fromJson(Map<String, dynamic> json) => ListAbsenSiswaModel(
        message: json["message"],
        data: json["data"] == null ? [] : List<AbsenSiswaModel>.from(json["data"]!.map((x) => AbsenSiswaModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class AbsenSiswaModel {
    int? id;
    int? idOrangtua;
    String? nis;
    String? nama;
    String? nisn;
    String? jenisKelamin;
    Absen? absen;

    AbsenSiswaModel({
        this.id,
        this.idOrangtua,
        this.nis,
        this.nama,
        this.nisn,
        this.jenisKelamin,
        this.absen,
    });

    factory AbsenSiswaModel.fromJson(Map<String, dynamic> json) => AbsenSiswaModel(
        id: json["id"],
        idOrangtua: json["id_orangtua"],
        nis: json["nis"],
        nama: json["nama"],
        nisn: json["nisn"],
        jenisKelamin: json["jenis_kelamin"],
        absen: json["absen"] == null ? null : Absen.fromJson(json["absen"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "id_orangtua": idOrangtua,
        "nis": nis,
        "nama": nama,
        "nisn": nisn,
        "jenis_kelamin": jenisKelamin,
        "absen": absen?.toJson(),
    };
}

class Absen {
    int? id;
    int? idSiswa;
    DateTime? tanggal;
    String? absenMasuk;
    String? absenPulang;
    String? statusAbsenMasuk;
    String? statusAbsenPulang;
    String? fotoAbsenMasuk;
    String? fotoAbsenPulang;
    String? noteMasuk;
    String? dokumenMasuk;
    String? notePulang;
    String? dokumenPulang;
    String? status;

    Absen({
        this.id,
        this.idSiswa,
        this.tanggal,
        this.absenMasuk,
        this.absenPulang,
        this.statusAbsenMasuk,
        this.statusAbsenPulang,
        this.fotoAbsenMasuk,
        this.fotoAbsenPulang,
        this.noteMasuk,
        this.dokumenMasuk,
        this.notePulang,
        this.dokumenPulang,
        this.status,
    });

    factory Absen.fromJson(Map<String, dynamic> json) => Absen(
        id: json["id"],
        idSiswa: json["id_siswa"],
        tanggal: json["tanggal"] == null ? null : DateTime.parse(json["tanggal"]),
        absenMasuk: json["absen_masuk"],
        absenPulang: json["absen_pulang"],
        statusAbsenMasuk: json["status_absen_masuk"],
        statusAbsenPulang: json["status_absen_pulang"],
        fotoAbsenMasuk: json["foto_absen_masuk"],
        fotoAbsenPulang: json["foto_absen_pulang"],
        noteMasuk: json["note_masuk"],
        dokumenMasuk: json["dokumen_masuk"],
        notePulang: json["note_pulang"],
        dokumenPulang: json["dokumen_pulang"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "id_siswa": idSiswa,
        "tanggal": "${tanggal!.year.toString().padLeft(4, '0')}-${tanggal!.month.toString().padLeft(2, '0')}-${tanggal!.day.toString().padLeft(2, '0')}",
        "absen_masuk": absenMasuk,
        "absen_pulang": absenPulang,
        "status_absen_masuk": statusAbsenMasuk,
        "status_absen_pulang": statusAbsenPulang,
        "foto_absen_masuk": fotoAbsenMasuk,
        "foto_absen_pulang": fotoAbsenPulang,
        "note_masuk": noteMasuk,
        "dokumen_masuk": dokumenMasuk,
        "note_pulang": notePulang,
        "dokumen_pulang": dokumenPulang,
        "status": status,
    };
}
