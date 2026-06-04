// lib/widgets/gambar_barang.dart
//
// Widget ini otomatis handle perbedaan Flutter Web vs Mobile:
// - Flutter Web  : pakai HtmlElementView (<img> tag) → bypass CORS
// - Mobile/Desktop: pakai Image.network biasa

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Import khusus web — tidak akan error di mobile karena ada stub
import 'gambar_barang_web.dart' if (dart.library.io) 'gambar_barang_stub.dart';

class GambarBarang extends StatelessWidget {
  final String? url;
  final double width;
  final double height;

  const GambarBarang({
    super.key,
    this.url,
    this.width = 95,
    this.height = 95,
  });

  static const Color _primaryLight   = Color(0xFF7E57C2);
  static const Color _primarySurface = Color(0xFFEDE7F6);

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.trim().isNotEmpty;

    if (!hasUrl) return _placeholder(hasError: false);

    if (kIsWeb) {
      // Flutter Web: pakai HtmlElementView agar bypass CORS browser
      return buildWebImage(url!, width, height, () => _placeholder(hasError: true));
    }

    // Mobile / Desktop: Image.network biasa
    return Image.network(
      url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: _primarySurface,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _primaryLight,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (_, error, __) {
        debugPrint('Image load error: $url\n$error');
        return _placeholder(hasError: true);
      },
    );
  }

  Widget _placeholder({required bool hasError}) => Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(color: _primarySurface),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasError ? Icons.broken_image_rounded : Icons.image_rounded,
              color: _primaryLight.withOpacity(0.5),
              size: 30,
            ),
            if (hasError) ...[
              const SizedBox(height: 4),
              Text(
                'Gagal',
                style: TextStyle(
                  fontSize: 10,
                  color: _primaryLight.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      );
}
