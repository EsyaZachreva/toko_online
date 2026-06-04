import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toko_online/controllers/cartProvide.dart';
import 'package:toko_online/services/pesan.dart';
import 'package:toko_online/widgets/alert.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  CartProvider cartProvider = CartProvider();

  static const Color _primary        = Color(0xFF5E35B1);
  static const Color _primaryDark    = Color(0xFF4527A0);
  static const Color _primaryLight   = Color(0xFF7E57C2);
  static const Color _primarySurface = Color(0xFFEDE7F6);
  static const Color _bg             = Color(0xFFF5F3FB);

  @override
  void initState() {
    super.initState();
    cartProvider.getData();
  }

  String _formatHarga(double? harga) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(harga ?? 0);
  }

  double get _totalHarga {
    return cartProvider.cart.fold(
        0, (sum, item) => sum + ((item.harga ?? 0) * (item.quantity ?? 0)));
  }

  void checkout() async {
    if (cartProvider.cart.isEmpty) return;

    // FIX: pakai id_barang (id produk dari API), bukan id (row id lokal)
    var detailList = cartProvider.cart.map((i) {
      return {"barang_id": i.id_barang, "qty": i.quantity};
    }).toList();

    var result = await Pesan().saveToDB({"pesan": detailList});

    if (!mounted) return;

    if (result.status == true) {
      AlertMessage().showAlert(context, "Berhasil checkout!", true);

      // Kosongkan cart
      final ids = cartProvider.cart.map((e) => e.id!).toList();
      for (var id in ids) {
        cartProvider.removeItem(id);
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/history',
        (route) => false,
      );
    } else {
      AlertMessage().showAlert(
          context, "Gagal Checkout: ${result.message}", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primarySurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: _primaryDark),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_cart_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Keranjang Belanja',
              style: TextStyle(
                color: _primaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _primary.withOpacity(0.08)),
        ),
      ),
      body: ListenableBuilder(
        listenable: cartProvider,
        builder: (context, child) {
          if (cartProvider.cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shopping_cart_outlined,
                        size: 48, color: _primaryLight),
                  ),
                  const SizedBox(height: 16),
                  Text('Keranjang Kosong',
                      style: TextStyle(
                          color: _primaryDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Tambahkan produk dari halaman pesan',
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13)),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Info jumlah item
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  children: [
                    Text(
                      '${cartProvider.cart.length} item di keranjang',
                      style: TextStyle(
                        fontSize: 12,
                        color: _primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // List item
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  itemCount: cartProvider.cart.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.cart[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: _primary.withOpacity(0.08), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Gambar
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              bottomLeft: Radius.circular(18),
                            ),
                            child: _buildImage(item.gambar_url),
                          ),

                          // Info
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nama_barang ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Color(0xFF1A1035),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatHarga(item.harga),
                                    style: const TextStyle(
                                      color: _primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Tombol +/-
                                  Row(
                                    children: [
                                      _QtyBtn(
                                        icon: Icons.remove_rounded,
                                        onTap: () => cartProvider
                                            .deleteQuantity(item.id!),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _primarySurface,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${item.quantity ?? 0}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: _primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      _QtyBtn(
                                        icon: Icons.add_rounded,
                                        onTap: () =>
                                            cartProvider.addQuantity(item.id!),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Tombol hapus
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Material(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () =>
                                    cartProvider.removeItem(item.id!),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(Icons.delete_rounded,
                                      size: 20, color: Colors.red.shade600),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Total + Checkout
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.10),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Pembayaran',
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        Text(
                          _formatHarga(_totalHarga),
                          style: const TextStyle(
                            color: _primaryDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: checkout,
                        icon: const Icon(
                            Icons.shopping_cart_checkout_rounded,
                            size: 20),
                        label: const Text(
                          'Checkout Sekarang',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImage(String? url) {
    final hasUrl = url != null && url.trim().isNotEmpty;
    if (!hasUrl) {
      return Container(
        width: 95,
        height: 95,
        color: _primarySurface,
        child: Icon(Icons.image_rounded,
            color: _primaryLight.withOpacity(0.5), size: 30),
      );
    }
    return Image.network(
      url,
      width: 95,
      height: 95,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 95,
        height: 95,
        color: _primarySurface,
        child: Icon(Icons.broken_image_rounded,
            color: _primaryLight.withOpacity(0.5), size: 30),
      ),
    );
  }
}

// Tombol + / -
class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  static const Color _primary        = Color(0xFF5E35B1);
  static const Color _primarySurface = Color(0xFFEDE7F6);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _primarySurface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: _primary),
        ),
      ),
    );
  }
}