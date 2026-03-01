import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../app/routes.dart';

class CrearReporteScreen extends StatefulWidget {
  const CrearReporteScreen({super.key});

  @override
  State<CrearReporteScreen> createState() => _CrearReporteScreenState();
}

class _CrearReporteScreenState extends State<CrearReporteScreen> {

  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _lugarController       = TextEditingController();
  final TextEditingController _asignadoController    = TextEditingController();

  bool    _cargando  = false;
  bool    _isFound   = false;   // false = extraviado, true = encontrado
  File?   _imagenSeleccionada;
  String? _imagenBase64;

  final String baseUrl = Config.baseUrl;
  final ImagePicker   _picker     = ImagePicker();

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
                "REGISTRAR OBJETO",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // ── LUGAR ─────────────────────────────────────
              _buildLabel("¿Dónde encontraste el objeto?"),
              const SizedBox(height: 10),
              _buildInput(
                controller: _lugarController,
                hint: "Ej: Biblioteca, Aula 203, Cafetería...",
              ),

              const SizedBox(height: 30),

              // ── DESCRIPCIÓN ───────────────────────────────
              _buildLabel("Explique su reporte"),
              const SizedBox(height: 10),
              _buildInput(
                controller: _descripcionController,
                hint: "Describa el objeto, color, marca...",
                maxLines: 4,
              ),

              const SizedBox(height: 30),

              // ── ASIGNADO ──────────────────────────────────
              _buildLabel("¿A quién se lo asignaste?"),
              const SizedBox(height: 10),
              _buildInput(
                controller: _asignadoController,
                hint: "Nombre de la persona responsable...",
              ),

              const SizedBox(height: 30),

              // ── ESTADO DEL OBJETO ─────────────────────────
              _buildLabel("Estado del objeto"),
              const SizedBox(height: 12),
              _buildStatusToggle(azulBoton),

              const SizedBox(height: 30),

              // ── IMAGEN (OPCIONAL) ─────────────────────────
              _buildLabel("Foto del objeto (opcional)"),
              const SizedBox(height: 12),
              _buildImagePicker(azulBoton),

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
                  onPressed: _cargando ? null : _registrarObjeto,
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "REGISTRAR OBJETO",
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
  // WIDGETS PERSONALIZADOS
  // =========================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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
      ),
    );
  }

  /// Toggle: EXTRAVIADO / ENCONTRADO
  Widget _buildStatusToggle(Color azulBoton) {
    return Container(
      decoration: BoxDecoration(
        color: azulBoton,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.search,
                color: Colors.orangeAccent,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Text(
                "Extraviado",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          // Switch eliminado - ya no es necesario
        ],
      ),
    );
  }
  /// Selector de imagen con preview
  Widget _buildImagePicker(Color azulBoton) {
    return Column(
      children: [
        // Preview o placeholder
        GestureDetector(
          onTap: _seleccionarImagen,
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: azulBoton,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white24,
                width: 1.5,
              ),
            ),
            child: _imagenSeleccionada != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.file(
                _imagenSeleccionada!,
                fit: BoxFit.cover,
              ),
            )
                : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined,
                    color: Colors.white38, size: 40),
                SizedBox(height: 8),
                Text(
                  "Toca para agregar una foto",
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
        ),

        // Botón quitar imagen (solo si hay una seleccionada)
        if (_imagenSeleccionada != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => setState(() {
              _imagenSeleccionada = null;
              _imagenBase64 = null;
            }),
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 18),
            label: const Text(
              "Quitar imagen",
              style: TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }

  // =========================================================
  // LÓGICA IMAGEN
  // =========================================================

  Future<void> _seleccionarImagen() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,   // pre-compresión antes de enviar
    );

    if (picked == null) return;

    // Comprimir aún más con flutter_image_compress
    final List<int>? compressed = await FlutterImageCompress.compressWithFile(
      picked.path,
      minWidth: 800,
      minHeight: 800,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    if (compressed == null) return;

    setState(() {
      _imagenSeleccionada = File(picked.path);
      _imagenBase64 = base64Encode(compressed);
    });
  }

  // =========================================================
  // API FASTAPI
  // =========================================================

  Future<void> _registrarObjeto() async {

    final descripcion = _descripcionController.text.trim();
    final lugar       = _lugarController.text.trim();
    final asignado    = _asignadoController.text.trim();

    if (descripcion.isEmpty || lugar.isEmpty || asignado.isEmpty) {
      _mostrarMensaje("Todos los campos son obligatorios");
      return;
    }

    setState(() => _cargando = true);

    try {

      // Construir body — imagen solo si fue seleccionada
      final Map<String, dynamic> body = {
        "description": descripcion,
        "location":    lugar,
        "assigned_to": asignado,
        "is_found":    _isFound,
        if (_imagenBase64 != null) "image_base64": _imagenBase64,
      };

      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _mostrarMensaje("Objeto registrado correctamente");
        if (mounted) Navigator.pop(context);
      } else {
        _mostrarMensaje("Error al registrar objeto");
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