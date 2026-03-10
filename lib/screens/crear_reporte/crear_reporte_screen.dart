import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../app/routes.dart';
import '../../models/app_colors.dart';

class CrearReporteScreen extends StatefulWidget {
  const CrearReporteScreen({super.key});

  @override
  State<CrearReporteScreen> createState() => _CrearReporteScreenState();
}

class _CrearReporteScreenState extends State<CrearReporteScreen> {
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _lugarController = TextEditingController();
  final TextEditingController _asignadoController = TextEditingController();

  bool _cargando = false;
  File? _imagenSeleccionada;
  String? _imagenBase64;

  final String baseUrl = Config.baseUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azulProfundo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── CABECERA CON VOLVER ───────────────
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
                  Text(
                    "Reportar objeto extraviado",
                    style: TextStyle(
                      color: AppColors.textoClaro,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── BADGE DE ESTADO FIJO ─────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.rojoAlerta.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.rojoAlerta.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.rojoAlerta,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.priority_high,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Reportando objeto EXTRAVIADO",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Este reporte ayudará a que otros estudiantes encuentren tu objeto",
                            style: TextStyle(
                              color: AppColors.textoSecundarioClaro,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ── LUGAR ─────────────────────────────────────
              _buildLabel("¿Dónde se perdió?"),
              const SizedBox(height: 10),
              _buildInput(
                controller: _lugarController,
                hint: "Ej: Biblioteca, Aula 203, Cafetería...",
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 24),

              // ── DESCRIPCIÓN ───────────────────────────────
              _buildLabel("Descripción del objeto"),
              const SizedBox(height: 10),
              _buildInput(
                controller: _descripcionController,
                hint: "Color, marca, características distintivas...",
                maxLines: 4,
                icon: Icons.description_outlined,
              ),

              const SizedBox(height: 24),

              // ── CONTACTO ──────────────────────────────────
              _buildLabel("Nombre de contacto"),
              const SizedBox(height: 10),
              _buildInput(
                controller: _asignadoController,
                hint: "Tu nombre o cómo contactarte",
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 30),

              // ── IMAGEN ─────────────────────────
              _buildLabel("Foto del objeto (opcional)"),
              const SizedBox(height: 12),
              _buildImagePicker(),

              const SizedBox(height: 40),

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
                  ),
                  onPressed: _cargando ? null : _registrarObjeto,
                  child: _cargando
                      ? CircularProgressIndicator(
                    color: AppColors.azulProfundo,
                    strokeWidth: 3,
                  )
                      : const Text(
                    "PUBLICAR REPORTE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  "Tu reporte ayudará a otros estudiantes",
                  style: TextStyle(
                    color: AppColors.textoSecundarioClaro,
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
  // WIDGETS
  // =========================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textoClaro,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
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
        maxLines: maxLines,
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
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _seleccionarImagen,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              gradient: _imagenSeleccionada == null
                  ? LinearGradient(
                colors: [
                  AppColors.inputFondo,
                  AppColors.inputFondo.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: _imagenSeleccionada != null ? null : AppColors.inputFondo,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _imagenSeleccionada == null
                    ? AppColors.textoSecundarioClaro.withOpacity(0.3)
                    : AppColors.amarilloAccion.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: _imagenSeleccionada != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    _imagenSeleccionada!,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.azulProfundo.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.amarilloAccion,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: AppColors.amarilloAccion,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.amarilloAccion.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.amarilloAccion,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Toca para agregar una foto",
                  style: TextStyle(
                    color: AppColors.textoSecundarioClaro,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_imagenSeleccionada != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => setState(() {
                  _imagenSeleccionada = null;
                  _imagenBase64 = null;
                }),
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.rojoAlerta,
                  size: 18,
                ),
                label: Text(
                  "Quitar imagen",
                  style: TextStyle(
                    color: AppColors.rojoAlerta,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.rojoAlerta.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // =========================================================
  // LÓGICA IMAGEN
  // =========================================================

  Future<void> _seleccionarImagen() async {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.inputFondo,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.amarilloAccion),
              title: const Text("Tomar foto"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.amarilloAccion),
              title: const Text("Elegir de galería"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    },
  );
}

    Future<void> _pickImage(ImageSource source) async {
  try {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() => _cargando = true);

    final List<int>? compressed = await FlutterImageCompress.compressWithFile(
      picked.path,
      minWidth: 800,
      minHeight: 800,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    if (compressed == null) {
      _mostrarMensaje("Error al comprimir la imagen");
      setState(() => _cargando = false);
      return;
    }

    setState(() {
      _imagenSeleccionada = File(picked.path);
      _imagenBase64 = base64Encode(compressed);
      _cargando = false;
    });

    _mostrarMensaje("✅ Imagen agregada correctamente");
  } catch (e) {
    setState(() => _cargando = false);
    _mostrarMensaje("Error al seleccionar la imagen");
  }
}

  // =========================================================
  // API
  // =========================================================

  Future<void> _registrarObjeto() async {
    final descripcion = _descripcionController.text.trim();
    final lugar = _lugarController.text.trim();
    final asignado = _asignadoController.text.trim();

    if (descripcion.isEmpty || lugar.isEmpty || asignado.isEmpty) {
      _mostrarMensaje("Completa todos los campos obligatorios");
      return;
    }

    setState(() => _cargando = true);

    try {
      final Map<String, dynamic> body = {
        "description": descripcion,
        "location": lugar,
        "assigned_to": asignado,
        "is_found": false, // 👈 SIEMPRE FALSE (extraviado)
        if (_imagenBase64 != null) "image_base64": _imagenBase64,
      };

      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _mostrarMensaje("✅ ¡Reporte creado correctamente!");
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context, true);
      } else {
        _mostrarMensaje("Error al crear reporte");
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión");
    }

    if (mounted) setState(() => _cargando = false);
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: mensaje.contains("✅")
            ? AppColors.verdeExito
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
      ),
    );
  }
}