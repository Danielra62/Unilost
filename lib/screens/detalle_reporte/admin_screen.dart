import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../app/routes.dart';
import '../../models/app_colors.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final String baseUrl = Config.baseUrl;

  bool _cargando = false;
  List<dynamic> _objetos = [];

  @override
  void initState() {
    super.initState();
    _cargarObjetos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azulProfundo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER CON VOLVER ─────────────────────────
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Panel Admin",
                          style: TextStyle(
                            color: AppColors.textoClaro,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${_objetos.length} objetos registrados",
                          style: TextStyle(
                            color: AppColors.textoSecundarioClaro,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón refrescar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputFondo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _cargarObjetos,
                      icon: Icon(
                        Icons.refresh,
                        color: AppColors.amarilloAccion,
                      ),
                      tooltip: "Actualizar",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── ESTADÍSTICAS RÁPIDAS ─────────────────────
              Row(
                children: [
                  _buildStatCard(
                    icon: Icons.search,
                    label: "Extraviados",
                    count: _objetos.where((o) => o["is_found"] == false).length,
                    color: AppColors.rojoAlerta,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.check_circle,
                    label: "Encontrados",
                    count: _objetos.where((o) => o["is_found"] == true).length,
                    color: AppColors.verdeExito,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── LISTA ─────────────────────────────────────
              Expanded(
                child: _cargando
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.amarilloAccion,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Cargando objetos...",
                        style: TextStyle(
                          color: AppColors.textoSecundarioClaro,
                        ),
                      ),
                    ],
                  ),
                )
                    : _objetos.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  itemCount: _objetos.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildCard(_objetos[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // WIDGETS AUXILIARES
  // =========================================================

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.inputFondo,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textoSecundarioClaro,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "$count",
                    style: TextStyle(
                      color: AppColors.textoClaro,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.inputFondo,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox,
              size: 50,
              color: AppColors.textoSecundarioClaro.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No hay objetos registrados",
            style: TextStyle(
              color: AppColors.textoClaro,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Los objetos reportados aparecerán aquí",
            style: TextStyle(
              color: AppColors.textoSecundarioClaro,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CARD MEJORADA
  // =========================================================

  Widget _buildCard(Map<String, dynamic> obj) {
    final int id = obj["id"];
    final bool isFound = obj["is_found"] ?? false;
    final String? imageB64 = obj["image_base64"];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.inputFondo,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.azulProfundo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── IMAGEN CON BADGE ─────────────────────────────
          if (imageB64 != null && imageB64.isNotEmpty)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.memory(
                    base64Decode(imageB64),
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildBadge(isFound),
                ),
                // ID del objeto
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.azulProfundo.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "ID: $id",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descripción
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        obj["description"] ?? "Sin descripción",
                        style: TextStyle(
                          color: AppColors.textoClaro,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (imageB64 == null) _buildBadge(isFound),
                  ],
                ),

                const SizedBox(height: 12),

                // Ubicación
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.azulMedio,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        obj["location"] ?? "Ubicación no especificada",
                        style: TextStyle(
                          color: AppColors.textoSecundarioClaro,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Asignado
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: AppColors.azulMedio,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        obj["assigned_to"] ?? "Sin asignar",
                        style: TextStyle(
                          color: AppColors.textoSecundarioClaro,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── BOTONES DE ACCIÓN ──────────────────────
                Row(
                  children: [
                    // Cambiar estado
                    Expanded(
                      child: _buildActionButton(
                        label: isFound ? "Marcar extraviado" : "Marcar encontrado",
                        icon: isFound ? Icons.search : Icons.check_circle_outline,
                        color: isFound ? AppColors.rojoAlerta : AppColors.verdeExito,
                        onTap: () => _cambiarEstado(id, !isFound),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Eliminar
                    Expanded(
                      child: _buildActionButton(
                        label: "Eliminar",
                        icon: Icons.delete_outline,
                        color: AppColors.rojoAlerta,
                        onTap: () => _confirmarEliminar(id),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(bool isFound) {
    final Color color = isFound ? AppColors.verdeExito : AppColors.rojoAlerta;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFound ? Icons.check_circle : Icons.priority_high,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isFound ? "Encontrado" : "Extraviado",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // API
  // =========================================================

  Future<void> _cargarObjetos() async {
    setState(() => _cargando = true);

    try {
      final response = await http.get(Uri.parse("$baseUrl/objects"));

      if (response.statusCode == 200) {
        setState(() => _objetos = jsonDecode(response.body));
      } else {
        _mostrarMensaje("Error al cargar objetos");
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión");
    }

    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _cambiarEstado(int id, bool nuevoEstado) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/objects/$id/status?is_found=$nuevoEstado"),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = _objetos.indexWhere((o) => o["id"] == id);
          if (index != -1) {
            _objetos[index]["is_found"] = nuevoEstado;
          }
        });
        _mostrarMensaje(
          "✅ Objeto marcado como ${nuevoEstado ? 'encontrado' : 'extraviado'}",
        );
      } else {
        _mostrarMensaje("Error al cambiar estado");
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión");
    }
  }

  Future<void> _eliminarObjeto(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/objects/$id"));

      if (response.statusCode == 200) {
        setState(() => _objetos.removeWhere((o) => o["id"] == id));
        _mostrarMensaje("✅ Objeto eliminado correctamente");
      } else {
        _mostrarMensaje("Error al eliminar");
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión");
    }
  }

  // =========================================================
  // DIÁLOGO DE CONFIRMACIÓN MEJORADO
  // =========================================================

  void _confirmarEliminar(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.inputFondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.rojoAlerta,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              "¿Eliminar objeto?",
              style: TextStyle(
                color: AppColors.textoClaro,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          "Esta acción no se puede deshacer. El objeto será eliminado permanentemente.",
          style: TextStyle(
            color: AppColors.textoSecundarioClaro,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textoSecundarioClaro,
            ),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarObjeto(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rojoAlerta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
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
        duration: const Duration(seconds: 2),
      ),
    );
  }
}