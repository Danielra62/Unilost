import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../app/routes.dart';
import '../../models/app_colors.dart'; // 👈 IMPORTAMOS LA PALETA COMPARTIDA

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adminCodeController = TextEditingController();

  bool _cargando = false;
  bool _verPassword = false;
  bool _isAdmin = false; // false = ESTUDIANTE, true = ADMIN

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
              // ── CABECERA CON VOLVER ────────────────────────
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputFondo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.textoClaro,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Crear cuenta",
                        style: TextStyle(
                          color: AppColors.textoClaro,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        "Únete a la comunidad UNILOST",
                        style: TextStyle(
                          color: AppColors.textoSecundarioClaro,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── TIPO DE USUARIO ───────────────────────────
              _buildLabel("Tipo de usuario"),
              const SizedBox(height: 12),
              _buildRoleToggle(),

              const SizedBox(height: 30),

              // ── CÓDIGO ADMIN (solo si es admin) ───────────
              if (_isAdmin) ...[
                _buildLabel("Código de administrador"),
                const SizedBox(height: 10),
                _buildInput(
                  controller: _adminCodeController,
                  hint: "Ingresa el código secreto",
                  obscure: true,
                  icon: Icons.admin_panel_settings_outlined,
                ),
                const SizedBox(height: 30),
              ],

              // ── NOMBRE DE USUARIO ─────────────────────────
              _buildLabel("Nombre de usuario"),
              const SizedBox(height: 10),
              _buildInput(
                controller: _usernameController,
                hint: "¿Cómo quieres que te llamen?",
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 20),

              // ── EMAIL ─────────────────────────────────────
              _buildLabel("Correo electrónico"),
              const SizedBox(height: 10),
              _buildInput(
                controller: _emailController,
                hint: "ejemplo@correo.com",
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 20),

              // ── CONTRASEÑA ────────────────────────────────
              _buildLabel("Contraseña"),
              const SizedBox(height: 10),
              _buildInput(
                controller: _passwordController,
                hint: "Mínimo 6 caracteres",
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

              const SizedBox(height: 30),

              // ── TÉRMINOS Y CONDICIONES ────────────────────
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.inputFondo,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: AppColors.textoSecundarioClaro.withOpacity(0.3),
                      ),
                    ),
                    child: Checkbox(
                      value: true, // TODO: Implementar estado real
                      onChanged: (value) {},
                      fillColor: MaterialStateProperty.all(AppColors.amarilloAccion),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Acepto los Términos y Condiciones y la Política de Privacidad",
                      style: TextStyle(
                        color: AppColors.textoSecundarioClaro,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ── BOTÓN REGISTRAR ───────────────────────────
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
                  onPressed: _cargando ? null : _registrar,
                  child: _cargando
                      ? CircularProgressIndicator(
                    color: AppColors.azulProfundo,
                    strokeWidth: 3,
                  )
                      : const Text(
                    "CREAR CUENTA",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── ENLACE A LOGIN ────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Vuelve al login
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "¿Ya tienes cuenta? ",
                      style: TextStyle(
                        color: AppColors.textoSecundarioClaro,
                        fontSize: 15,
                      ),
                      children: [
                        TextSpan(
                          text: "Inicia sesión",
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

  /// Botones ESTUDIANTE / ADMIN (MEJORADOS)
  Widget _buildRoleToggle() {
    return Row(
      children: [
        // ESTUDIANTE
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isAdmin = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: !_isAdmin
                    ? LinearGradient(
                  colors: [
                    AppColors.amarilloAccion,
                    AppColors.amarilloAccion.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: !_isAdmin ? null : AppColors.inputFondo,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: !_isAdmin
                      ? Colors.transparent
                      : AppColors.textoSecundarioClaro.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: !_isAdmin
                    ? [
                  BoxShadow(
                    color: AppColors.amarilloAccion.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    color: !_isAdmin
                        ? AppColors.azulProfundo
                        : AppColors.textoSecundarioClaro,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "ESTUDIANTE",
                    style: TextStyle(
                      color: !_isAdmin
                          ? AppColors.azulProfundo
                          : AppColors.textoSecundarioClaro,
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _isAdmin
                    ? LinearGradient(
                  colors: [
                    AppColors.amarilloAccion,
                    AppColors.amarilloAccion.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: _isAdmin ? null : AppColors.inputFondo,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isAdmin
                      ? Colors.transparent
                      : AppColors.textoSecundarioClaro.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: _isAdmin
                    ? [
                  BoxShadow(
                    color: AppColors.amarilloAccion.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings_outlined,
                    color: _isAdmin
                        ? AppColors.azulProfundo
                        : AppColors.textoSecundarioClaro,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "ADMIN",
                    style: TextStyle(
                      color: _isAdmin
                          ? AppColors.azulProfundo
                          : AppColors.textoSecundarioClaro,
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
  // API /auth/register (SnackBar mejorado)
  // =========================================================

  Future<void> _registrar() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
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
        "email": email,
        "password": password,
        "role": _isAdmin ? "admin" : "estudiante",
        if (_isAdmin) "admin_code": _adminCodeController.text.trim(),
      };

      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _mostrarMensaje("✅ ¡Cuenta creada correctamente!");
        if (mounted) {
          // Pequeña pausa para que el usuario vea el mensaje de éxito
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pop(context);
        }
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
        backgroundColor: mensaje.contains("✅")
            ? AppColors.verdeExito ?? Colors.green
            : AppColors.amarilloAccion,
        content: Text(
          mensaje,
          style: TextStyle(
            color: mensaje.contains("✅")
                ? Colors.white
                : AppColors.azulProfundo,
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