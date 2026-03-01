import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../app/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _cargando        = false;
  bool _verPassword     = false;

  final String baseUrl = Config.baseUrl;

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {

    const Color azulMarino = Color(0xFF0D1B2A);
    const Color azulBoton  = Color(0xFF1B263B);

    return Scaffold(
      backgroundColor: azulMarino,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 30),

              // ── TÍTULO ────────────────────────────────────
              const Text(
                "BIENVENIDO",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Inicia sesión para continuar",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 50),

              // ── EMAIL ─────────────────────────────────────
              _buildLabel("Correo electrónico"),
              const SizedBox(height: 10),
              _buildInput(
                controller: _emailController,
                hint: "ejemplo@correo.com",
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 25),

              // ── CONTRASEÑA ────────────────────────────────
              _buildLabel("Contraseña"),
              const SizedBox(height: 10),
              _buildInput(
                controller: _passwordController,
                hint: "••••••••",
                obscure: !_verPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _verPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white38,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _verPassword = !_verPassword),
                ),
              ),

              const SizedBox(height: 50),

              // ── BOTÓN LOGIN ───────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azulBoton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                  ),
                  onPressed: _cargando ? null : _login,
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "INICIAR SESIÓN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ── IR A REGISTRO ─────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/registro'),
                  child: RichText(
                    text: const TextSpan(
                      text: "¿No tienes cuenta? ",
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Regístrate",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // WIDGETS
  // =========================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1B263B),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  // =========================================================
  // API /auth/login
  // =========================================================

  Future<void> _login() async {

    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostrarMensaje("Completa todos los campos");
      return;
    }

    setState(() => _cargando = true);

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email":    email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();

        await prefs.setInt("user_id", data["user_id"]);
        await prefs.setString("username", data["username"]);
        await prefs.setString("role", data["role"]);

        if (mounted) {
          if (data["role"] == "admin") {
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } else {
        _mostrarMensaje("Correo o contraseña incorrectos");
      }

    } catch (e) {
      _mostrarMensaje("Error de conexión con el servidor");
    }

    if (mounted) setState(() => _cargando = false);
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          mensaje,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}