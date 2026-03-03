import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../app/routes.dart';

// Reutilizamos la misma paleta del login
class AppColors {
  static const Color azulProfundo          = Color(0xFF2A3F5E);
  static const Color azulMedio             = Color(0xFF4F7EB3);
  static const Color amarilloAccion        = Color(0xFFF9A826);
  static const Color textoClaro            = Color(0xFFF4F7FB);
  static const Color textoSecundarioClaro  = Color(0xFFB8C7DE);
  static const Color inputFondo            = Color(0xFF1E3A5F);
}

class OlvidePasswordScreen extends StatefulWidget {
  const OlvidePasswordScreen({super.key});

  @override
  State<OlvidePasswordScreen> createState() => _OlvidePasswordScreenState();
}

class _OlvidePasswordScreenState extends State<OlvidePasswordScreen> {

  final TextEditingController _emailController       = TextEditingController();
  final TextEditingController _nuevaPasswordController     = TextEditingController();
  final TextEditingController _confirmarPasswordController = TextEditingController();

  bool _cargando         = false;
  bool _emailVerificado  = false;   // true cuando el email existe en la BD
  bool _verPassword      = false;
  bool _verConfirmar     = false;

  final String baseUrl = Config.baseUrl;

  // =========================================================
  // BUILD
  // =========================================================

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

              // ── BOTÓN VOLVER ──────────────────────────────
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),

              const SizedBox(height: 10),

              // ── ÍCONO ─────────────────────────────────────
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.amarilloAccion.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _emailVerificado ? Icons.lock_reset : Icons.lock_outline,
                    size: 44,
                    color: AppColors.amarilloAccion,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── TÍTULO ────────────────────────────────────
              Center(
                child: Text(
                  _emailVerificado
                      ? "Nueva contraseña"
                      : "¿Olvidaste tu contraseña?",
                  style: const TextStyle(
                    color: AppColors.textoClaro,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  _emailVerificado
                      ? "Ingresa y confirma tu nueva contraseña"
                      : "Ingresa tu correo y verificaremos\nsi existe una cuenta asociada",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textoSecundarioClaro,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── PASO 1: EMAIL ─────────────────────────────
              if (!_emailVerificado) ...[
                _buildLabel("Correo electrónico"),
                const SizedBox(height: 8),
                _buildInput(
                  controller: _emailController,
                  hint: "ejemplo@correo.com",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 40),

                _buildBoton(
                  label: "VERIFICAR CORREO",
                  onTap: _verificarEmail,
                ),
              ],

              // ── PASO 2: NUEVA CONTRASEÑA ──────────────────
              if (_emailVerificado) ...[

                // Email (solo lectura, referencia visual)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inputFondo.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.amarilloAccion.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.amarilloAccion, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _emailController.text.trim(),
                          style: const TextStyle(
                            color: AppColors.textoClaro,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _buildLabel("Nueva contraseña"),
                const SizedBox(height: 8),
                _buildInput(
                  controller: _nuevaPasswordController,
                  hint: "Mínimo 6 caracteres",
                  icon: Icons.lock_outline,
                  obscure: !_verPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _verPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textoSecundarioClaro,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _verPassword = !_verPassword),
                  ),
                ),

                const SizedBox(height: 20),

                _buildLabel("Confirmar contraseña"),
                const SizedBox(height: 8),
                _buildInput(
                  controller: _confirmarPasswordController,
                  hint: "Repite la contraseña",
                  icon: Icons.lock_outline,
                  obscure: !_verConfirmar,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _verConfirmar ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textoSecundarioClaro,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _verConfirmar = !_verConfirmar),
                  ),
                ),

                const SizedBox(height: 40),

                _buildBoton(
                  label: "CAMBIAR CONTRASEÑA",
                  onTap: _cambiarPassword,
                ),

                const SizedBox(height: 16),

                // Volver al paso 1
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _emailVerificado = false),
                    child: const Text(
                      "Usar otro correo",
                      style: TextStyle(
                        color: AppColors.textoSecundarioClaro,
                        decoration: TextDecoration.underline,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],

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
    IconData? icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
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
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.textoSecundarioClaro, size: 20)
              : null,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildBoton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
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
        onPressed: _cargando ? null : onTap,
        child: _cargando
            ? const CircularProgressIndicator(
          color: AppColors.azulProfundo,
          strokeWidth: 3,
        )
            : Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // LÓGICA
  // =========================================================

  /// Paso 1 — verifica si el email existe en la BD
  Future<void> _verificarEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _mostrarMensaje("Ingresa tu correo electrónico");
      return;
    }

    setState(() => _cargando = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/verify-email"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        setState(() => _emailVerificado = true);
      } else {
        _mostrarMensaje("No existe una cuenta con ese correo");
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión con el servidor");
    }

    if (mounted) setState(() => _cargando = false);
  }

  /// Paso 2 — cambia la contraseña
  Future<void> _cambiarPassword() async {
    final nueva    = _nuevaPasswordController.text.trim();
    final confirmar = _confirmarPasswordController.text.trim();

    if (nueva.isEmpty || confirmar.isEmpty) {
      _mostrarMensaje("Completa ambos campos");
      return;
    }

    if (nueva.length < 6) {
      _mostrarMensaje("La contraseña debe tener al menos 6 caracteres");
      return;
    }

    if (nueva != confirmar) {
      _mostrarMensaje("Las contraseñas no coinciden");
      return;
    }

    setState(() => _cargando = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email":        _emailController.text.trim(),
          "new_password": nueva,
        }),
      );

      if (response.statusCode == 200) {
        _mostrarMensaje("¡Contraseña actualizada correctamente!");
        if (mounted) {
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushReplacementNamed(context, Routes.login);
        }
      } else {
        _mostrarMensaje("Error al actualizar la contraseña");
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
          style: const TextStyle(
            color: AppColors.azulProfundo,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}