import '../models/user_login.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BottomNav extends StatefulWidget {
  int activePage;
  BottomNav(this.activePage, {super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  UserLogin userLogin = UserLogin();
  String? role;

  Future<void> getDataLogin() async {
    var user = await userLogin.getUserLogin();
    if (user!.status != false) {
      setState(() {
        role = user.role;
      });
    } else {
      Navigator.popAndPushNamed(context, '/login');
    }
  }

  @override
  void initState() {
    super.initState();
    getDataLogin();
  }

  void getlink(int index) {
    if (role == "admin") {
      if (index == 0) Navigator.pushNamed(context, '/dashboard');
      else if (index == 1) Navigator.pushNamed(context, '/barang');
    } else if (role == "user") {
      if (index == 0) Navigator.pushNamed(context, '/dashboard');
      else if (index == 1) Navigator.pushNamed(context, '/pesan');
      else if (index == 2) Navigator.pushNamed(context, '/history'); // FIX: tambah history
    }
  }

  @override
  Widget build(BuildContext context) {
    if (role == "admin") {
      return BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: widget.activePage,
        onTap: getlink,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.file_copy), label: 'Barang'),
        ],
      );
    } else if (role == "user") {
      // FIX: clamp index supaya tidak crash kalau activePage out of range
      final safeIndex = widget.activePage.clamp(0, 2);
      return BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: safeIndex,
        onTap: getlink,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Pesan'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Riwayat'), // FIX: item baru
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}