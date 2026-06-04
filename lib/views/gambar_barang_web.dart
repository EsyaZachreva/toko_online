// lib/widgets/gambar_barang_web.dart
// File ini HANYA dicompile di Flutter Web

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget buildWebImage(String url, double width, double height, Widget Function() placeholder) {
  // Buat ID unik untuk setiap gambar
  final viewId = 'img-${url.hashCode}';

  // Register hanya sekali (cek dengan try-catch)
  try {
    ui_web.platformViewRegistry.registerViewFactory(viewId, (_) {
      final img = html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.display = 'block';
      return img;
    });
  } catch (_) {
    // Sudah terdaftar sebelumnya — tidak apa-apa
  }

  return SizedBox(
    width: width,
    height: height,
    child: HtmlElementView(viewType: viewId),
  );
}
