import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../app/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🎨 IMPORTAMOS LA MISMA PALETA (puedes crear un archivo separado para compartir colores)
class AppColors {
  static const Color azulProfundo = Color(0xFF2A3F5E);     // Fondo principal
  static const Color azulMedio = Color(0xFF4F7EB3);        // Para bordes, detalles
  static const Color amarilloAccion = Color(0xFFF9A826);   // Botones importantes
  static const Color fondoBlanco = Color(0xFFFFFFFF);       // Textos claros
  static const Color textoClaro = Color(0xFFF4F7FB);        // Texto principal claro
  static const Color textoSecundarioClaro = Color(0xFFB8C7DE); // Texto secundario
  static const Color inputFondo = Color(0xFF1E3A5F);        // Fondo de inputs (versión más clara del azulProfundo)
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _cargando = false;
  bool _verPassword = false;

  final String baseUrl = Config.baseUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azulProfundo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── LOGO O ICONO (opcional) ─────────────────
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.amarilloAccion.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search,
                    size: 50,
                    color: AppColors.amarilloAccion,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ── TÍTULO ────────────────────────────────────
              Text(
                "¡Bienvenido!",
                style: TextStyle(
                  color: AppColors.textoClaro,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Inicia sesión para ayudar a otros\na encontrar lo que perdieron",
                style: TextStyle(
                  color: AppColors.textoSecundarioClaro,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              // ── EMAIL ─────────────────────────────────────
              _buildLabel("Correo electrónico"),
              const SizedBox(height: 8),
              _buildInput(
                controller: _emailController,
                hint: "ejemplo@correo.com",
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 20),

              // ── CONTRASEÑA ────────────────────────────────
              _buildLabel("Contraseña"),
              const SizedBox(height: 8),
              _buildInput(
                controller: _passwordController,
                hint: "••••••••",
                obscure: !_verPassword,
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _verPassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textoSecundarioClaro,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _verPassword = !_verPassword),
                ),
              ),

              // ── OLVIDÓ CONTRASEÑA? ────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implementar recuperación de contraseña
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textoSecundarioClaro,
                  ),
                  child: const Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ── BOTÓN LOGIN (MEJORADO) ───────────────────
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.amarilloAccion,
                    foregroundColor: AppColors.azulProfundo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.amarilloAccion.withOpacity(0.5),
                  ),
                  onPressed: _cargando ? null : _login,
                  child: _cargando
                      ? CircularProgressIndicator(
                    color: AppColors.azulProfundo,
                    strokeWidth: 3,
                  )
                      : const Text(
                    "INICIAR SESIÓN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── IR A REGISTRO (MEJORADO) ─────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, Routes.registro),
                  child: RichText(
                    text: TextSpan(
                      text: "¿No tienes cuenta? ",
                      style: TextStyle(
                        color: AppColors.textoSecundarioClaro,
                        fontSize: 15,
                      ),
                      children: [
                        TextSpan(
                          text: "Regístrate",
                          style: TextStyle(
                            color: AppColors.amarilloAccion,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.amarilloAccion,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── TÉRMINOS Y CONDICIONES ───────────────────
              Center(
                child: Text(
                  "Al iniciar sesión aceptas nuestros\nTérminos y Condiciones",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textoSecundarioClaro.withOpacity(0.7),
                    fontSize: 12,
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
  // WIDGETS MEJORADOS
  // =========================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textoClaro,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.azulProfundo.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textoSecundarioClaro.withOpacity(0.7),
          ),
          filled: true,
          fillColor: AppColors.inputFondo,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          prefixIcon: icon != null
              ? Icon(
            icon,
            color: AppColors.textoSecundarioClaro,
            size: 20,
          )
              : null,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  // =========================================================
  // API /auth/login (sin cambios, solo el SnackBar mejorado)
  // =========================================================

  Future<void> _login() async {
    final email = _emailController.text.trim();
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
          "email": email,
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
        backgroundColor: AppColors.amarilloAccion,
        content: Text(
          mensaje,
          style: TextStyle(
            color: AppColors.azulProfundo,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}