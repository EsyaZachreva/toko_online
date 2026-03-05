class TokoModel {
  String? nama_barang;
  String? deskripsi;
  int? stok;
  double? harga;
  String? gambar_url;
  TokoModel({
    this.nama_barang,
    this.deskripsi,
    this.stok,
    this.harga,
    this.gambar_url,
  });
  TokoModel.fromJson(Map<String, dynamic> parsedJson) {
    nama_barang = parsedJson['nama_barang'];
    deskripsi = parsedJson['deskripsi'];
    stok = int.parse(parsedJson['stok'].toString());
    harga = double.parse(parsedJson['harga'].toString());
    gambar_url = parsedJson['gambar_url'];
  }
  final String baseUrlTanpaApi = "https://learn.smktelkom-mlg.sch.id/toko/api";
}
