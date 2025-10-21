abstract class ApiUrl {
  // PUBLIC
  static var baseUrl = "43.133.148.170";
  static var url = "http://$baseUrl:3002";

  // AUTH
  static var loginUrl = "$url/api/auth/login";
  static var logoutUrl = "$url/api/auth/logout";

  // SISWA
  static var dataSiswaUrl = "$url/api/siswa/profile";
  static var dataTahunAjaranSiswaUrl = "$url/api/siswa/tahun-ajaran";
  static var dataKelasSiswaUrl = "$url/api/siswa/kelas";
  static var dataAbsenSiswaUrl = "$url/api/siswa/absen";
  static var dataKoordinatLokasiUrl = "$url/api/siswa/koordinat";
  static var dataPostAbsenSiswaUrl = "$url/api/siswa/absen/action";
  static var dataTahunAjaranUrl = "$url/api/siswa/tahun-ajaran";
  static var dataJadwalHariIniUrl = "$url/api/siswa/jadwal/get/today";
  static var dataJadwalAbsenUrl = "$url/api/siswa/jadwal";
  static var dataCekAbsenJadwalHariIniUrl = "$url/api/siswa/jadwal/cek";
  static var dataCekRadiusKoordinatUrl = "$url/api/siswa/koordinat/cek";
}
