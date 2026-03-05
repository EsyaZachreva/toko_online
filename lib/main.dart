import 'package:flutter/material.dart';
import 'package:toko_online/views/dashboard.dart';
import 'package:toko_online/views/login_view.dart';
import '../views/register_user_view.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/register',
      routes: {
        '/dashboard': (context) => const DashboardView(),
        '/register': (context) => RegisterUserView(),
        '/login': (BuildContext context) => LoginView(),
        },
    ),
  );
}
