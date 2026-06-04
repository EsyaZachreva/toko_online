import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toko_online/models/cart.dart';

class DBHelper {
  static const String _cartKey = 'cart_data';

  Future<List<Cart>> getCartList() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_cartKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => Cart.fromMap(e)).toList();
  }

  Future<void> _saveCartList(List<Cart> cartList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartKey, jsonEncode(cartList.map((c) => c.toMap()).toList()));
  }

  Future<Cart> insert(Cart cart) async {
    final list = await getCartList();
    final idx = list.indexWhere((c) => c.id_barang == cart.id_barang);
    if (idx != -1) {
      // Sudah ada → update quantity
      final existing = list[idx];
      list[idx] = Cart(
        id: existing.id,
        id_barang: existing.id_barang,
        nama_barang: existing.nama_barang,
        harga: existing.harga,
        deskripsi: existing.deskripsi,
        gambar_url: existing.gambar_url,
        quantity: (existing.quantity ?? 0) + 1,
      );
    } else {
      // Belum ada → insert baru
      list.add(Cart(
        id: DateTime.now().millisecondsSinceEpoch,
        id_barang: cart.id_barang,
        nama_barang: cart.nama_barang,
        harga: cart.harga,
        deskripsi: cart.deskripsi,
        gambar_url: cart.gambar_url,
        quantity: cart.quantity ?? 1,
      ));
    }
    await _saveCartList(list);
    return cart;
  }

  // Cari cart berdasarkan id_barang (id produk dari API)
  Future<List<Cart>?> getCartListDetail(dynamic id) async {
    try {
      final list = await getCartList();
      return list.where((c) => c.id_barang == id.toString()).toList();
    } catch (e) {
      return null;
    }
  }

  Future<int> updateQuantity(dynamic id, int qty) async {
    final list = await getCartList();
    final idx = list.indexWhere((c) => c.id == id);
    if (idx == -1) return 0;
    list[idx] = Cart(
      id: list[idx].id,
      id_barang: list[idx].id_barang,
      nama_barang: list[idx].nama_barang,
      harga: list[idx].harga,
      deskripsi: list[idx].deskripsi,
      gambar_url: list[idx].gambar_url,
      quantity: qty,
    );
    await _saveCartList(list);
    return 1;
  }

  Future<int> deleteCartItem(int id) async {
    final list = await getCartList();
    final before = list.length;
    list.removeWhere((c) => c.id == id);
    await _saveCartList(list);
    return before - list.length;
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}