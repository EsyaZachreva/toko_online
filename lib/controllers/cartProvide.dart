import 'package:flutter/material.dart';
import 'package:toko_online/models/cart.dart';
import 'package:toko_online/services/DBHelper.dart';

class CartProvider extends ChangeNotifier {
  int counter = 0;
  var dBHelper = DBHelper();
  List<Cart> cart = [];

  Future<List<Cart>> getData() async {
    cart = await DBHelper().getCartList();
    counter = cart.length;
    notifyListeners();
    return cart;
  }

  void addQuantity(int id) async {
    final index = cart.indexWhere((e) => e.id == id);
    if (index != -1) {
      cart[index].quantity = (cart[index].quantity ?? 0) + 1;
      await dBHelper.updateQuantity(cart[index].id, cart[index].quantity!);
      notifyListeners();
    }
  }

  void deleteQuantity(int id) async {
    final index = cart.indexWhere((e) => e.id == id);
    if (index != -1 && (cart[index].quantity ?? 0) > 1) {
      cart[index].quantity = cart[index].quantity! - 1;
      await dBHelper.updateQuantity(cart[index].id, cart[index].quantity!);
      notifyListeners();
    }
  }

  void removeItem(int id) async {
    final index = cart.indexWhere((e) => e.id == id);
    if (index != -1) {
      cart.removeAt(index);
      await dBHelper.deleteCartItem(id);
      counter = cart.length;
      notifyListeners();
    }
  }
}