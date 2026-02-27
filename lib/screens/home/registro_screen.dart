import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app/routes.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {

  final TextEditingController _usernameController  = TextEditingController();
  final TextEditingController _emailController     = TextEditingController();
  final TextEditingController _passwordController  = TextEditingController();
  final TextEditingController _adminCodeController = TextEditingController();

  bool _cargando    = false;
  bool _verPassword = false;
  bool _isAdmin     = false;   // false = ESTUDIANTE, true = ADMIN

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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── BOTÓN VOLVER ──────────────────────────────
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),

              const SizedBox(height: 10),

              const Text(
                "CREAR CUENTA",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Completa los datos para registrarte",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),

              const SizedBox(height: 40),

              // ── TIPO DE USUARIO ───────────────────────────
              _buildLabel("Tipo de usuario"),
              const SizedBox(height: 12),
              _buildRoleToggle(azulBoton),

              const SizedBox(height: 30),

              // ── CÓDIGO ADMIN (solo si es admin) ───────────
              if (_isAdmin) ...[
                _buildLabel("Código de administrador"),
                const SizedBox(height: 10),
                _buildInput(
                  controller: _adminCodeController,
                  hint: "Ingresa el código secreto",
                  obscure: true,
                ),
                const SizedBox(height: 30),
              ],

              // ── NOMBRE ────────────────────────────────────
              _buildLabel("Nombre de usuario"),
              const SizedBox(height: 10),
              _buildInput(
                controller: _usernameController,
                hint: "Tu nombre o apodo",
              ),

              const SizedBox(height: 25),

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

              // ── BOTÓN REGISTRAR ───────────────────────────
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
                  onPressed: _cargando ? null : _registrar,
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "CREAR CUENTA",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
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

  /// Botones ESTUDIANTE / ADMIN
  Widget _buildRoleToggle(Color azulBoton) {
    return Row(
      children: [

        // ESTUDIANTE
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isAdmin = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: !_isAdmin ? Colors.white : azulBoton,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: !_isAdmin ? Colors.white : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    color: !_isAdmin ? const Color(0xFF0D1B2A) : Colors.white54,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "ESTUDIANTE",
                    style: TextStyle(
                      color: !_isAdmin
                          ? const Color(0xFF0D1B2A)
                          : Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // ADMIN
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isAdmin = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _isAdmin ? Colors.white : azulBoton,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isAdmin ? Colors.white : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings_outlined,
                    color: _isAdmin ? const Color(0xFF0D1B2A) : Colors.white54,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "ADMIN",
                    style: TextStyle(
                      color: _isAdmin
                          ? const Color(0xFF0D1B2A)
                          : Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // API /auth/register
  // =========================================================

  Future<void> _registrar() async {

    final username = _usernameController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _mostrarMensaje("Completa todos los campos");
      return;
    }

    if (_isAdmin && _adminCodeController.text.trim().isEmpty) {
      _mostrarMensaje("Ingresa el código de administrador");
      return;
    }

    setState(() => _cargando = true);

    try {

      final Map<String, dynamic> body = {
        "username": username,
        "email":    email,
        "password": password,
        "role":     _isAdmin ? "admin" : "estudiante",
        if (_isAdmin) "admin_code": _adminCodeController.text.trim(),
      };

      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _mostrarMensaje("Cuenta creada correctamente");
        if (mounted) Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body);
        _mostrarMensaje(error["detail"] ?? "Error al registrarse");
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