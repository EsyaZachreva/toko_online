// lib/widgets/gambar_barang_stub.dart
// File ini dicompile di Mobile & Desktop (bukan Web)
// Isinya hanya stub kosong — tidak akan pernah dipanggil karena ada pengecekan kIsWeb

import 'package:flutter/material.dart';

Widget buildWebImage(String url, double width, double height, Widget Function() placeholder) {
  // Tidak akan pernah dipanggil di mobile/desktop
  // karena GambarBarang sudah cek kIsWeb sebelumnya
  return placeholder();
}
