import 'package:flutter/material.dart';
import 'package:toko_online/services/user.dart';
import 'package:toko_online/views/login_view.dart';
import 'package:toko_online/widgets/alert.dart';

class RegisterUserView extends StatefulWidget {
  const RegisterUserView({super.key});

  @override
  State<RegisterUserView> createState() => _RegisterUserViewState();
}

class _RegisterUserViewState extends State<RegisterUserView> {
  UserService user = UserService();
  final formKey = GlobalKey<FormState>();

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController birthday = TextEditingController();

  List roleChoice = ["Admin", "User"];
  String? role;

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Form Register User",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: name,
                      decoration: _inputDecoration("Name", Icons.person),
                      validator: (value) =>
                          value!.isEmpty ? "Nama wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: email,
                      decoration: _inputDecoration("Email", Icons.email),
                      validator: (value) =>
                          value!.isEmpty ? "Email wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: password,
                      decoration: _inputDecoration("Password", Icons.lock),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? "Password wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: address,
                      decoration: _inputDecoration("Address", Icons.home),
                      validator: (value) =>
                          value!.isEmpty ? "Alamat wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: birthday,
                      decoration: _inputDecoration(
                        "Birthday",
                        Icons.calendar_today,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Tanggal lahir wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField(
                      value: role,
                      items: roleChoice.map((r) {
                        return DropdownMenuItem(value: r, child: Text(r));
                      }).toList(),
                      decoration: _inputDecoration("Role", Icons.work_outline),
                      onChanged: (value) {
                        setState(() {
                          role = value.toString();
                        });
                      },
                      validator: (value) =>
                          value == null ? "Role harus dipilih" : null,
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF372AED),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            var data = {
                              "name": name.text,
                              "email": email.text,
                              "role": role,
                              "password": password.text,
                              "address": address.text,
                              "birthday": birthday.text,
                            };

                            var result = await user.registerUser(data);

                            if (result.status == true) {
                              name.clear();
                              email.clear();
                              password.clear();
                              address.clear();
                              birthday.clear();
                              setState(() => role = null);

                              AlertMessage().showAlert(
                                context,
                                result.message,
                                true,
                              );
                            } else {
                              AlertMessage().showAlert(
                                context,
                                result.message,
                                false,
                              );
                            }
                          }
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginView(),
                          ),
                        );
                      },
                      child: const Text("Login", style: TextStyle(color: Colors.black),),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
