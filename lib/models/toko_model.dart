import 'package:toko_online/services/url.dart' as url;

class TokoModel {
  int? id;
  String? nama_barang;
  String? deskripsi;
  int? stok;
  double? harga;
  String? gambar_url;

  TokoModel({
    this.id,
    this.nama_barang,
    this.deskripsi,
    this.stok,
    this.harga,
    this.gambar_url,
  });

  TokoModel.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    nama_barang = parsedJson['nama_barang'];
    deskripsi = parsedJson['deskripsi'];
    stok = int.tryParse(parsedJson['stok'].toString()) ?? 0;
    harga = double.tryParse(parsedJson['harga'].toString()) ?? 0.0;

    // Simpel seperti punya teman — langsung gabung saja
    final rawImage = parsedJson['image'];
    if (rawImage != null && rawImage.toString().isNotEmpty && rawImage.toString() != 'null') {
      gambar_url = "${url.BaseUrlImage}/${rawImage.toString()}";
    } else {
      gambar_url = null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_barang': nama_barang,
      'deskripsi': deskripsi,
      'stok': stok,
      'harga': harga,
    };
  }
}