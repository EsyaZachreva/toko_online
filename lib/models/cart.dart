class Cart {
  late final int? id;
  final String? id_barang;
  final String? nama_barang;
  final double? harga;
  final String? deskripsi;
  int? quantity;
  final String? gambar_url;

  Cart({
    required this.id,
    required this.id_barang,
    required this.nama_barang,
    required this.harga,
    required this.deskripsi,
    required this.quantity,
    required this.gambar_url,
  });

  factory Cart.fromMap(Map<dynamic, dynamic> data) {
    return Cart(
      id: data['id'] is int ? data['id'] : int.tryParse(data['id'].toString()),
      id_barang: data['id_barang']?.toString(),
      nama_barang: data['nama_barang'],
      harga: double.tryParse(data['harga'].toString()) ?? 0.0,
      deskripsi: data['deskripsi'],
      quantity: data['quantity'] is int
          ? data['quantity']
          : int.tryParse(data['quantity'].toString()) ?? 0,
      gambar_url: data['gambar_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_barang': id_barang,
      'nama_barang': nama_barang,
      'harga': harga,
      'deskripsi': deskripsi,
      'quantity': quantity,
      'gambar_url': gambar_url,
    };
  }
}