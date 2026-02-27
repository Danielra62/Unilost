import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app/routes.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

  final String baseUrl = Config.baseUrl;

  bool           _cargando  = false;
  List<dynamic>  _objetos   = [];

  @override
  void initState() {
    super.initState();
    _cargarObjetos();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {

    const Color azulMarino = Color(0xFF0D1B2A);
    const Color azulCard   = Color(0xFF1B263B);

    return Scaffold(
      backgroundColor: azulMarino,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── HEADER ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "PANEL ADMIN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${_objetos.length} objetos registrados",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  // Botón refrescar
                  IconButton(
                    onPressed: _cargarObjetos,
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    tooltip: "Actualizar",
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ── LISTA ─────────────────────────────────────
              Expanded(
                child: _cargando
                    ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : _objetos.isEmpty
                    ? const Center(
                  child: Text(
                    "No hay objetos registrados",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: _objetos.length,
                  itemBuilder: (context, index) {
                    return _buildCard(_objetos[index], azulCard);
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
  // CARD
  // =========================================================

  Widget _buildCard(Map<String, dynamic> obj, Color azulCard) {

    final int    id          = obj["id"];
    final bool   isFound     = obj["is_found"] ?? false;
    final String? imageB64   = obj["image_base64"];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: azulCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── IMAGEN (si existe) ───────────────────────────
          if (imageB64 != null && imageB64.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.memory(
                base64Decode(imageB64),
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Descripción + badge estado
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Expanded(
                      child: Text(
                        obj["description"] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    _buildBadge(isFound),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  "📍 ${obj["location"]}",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  "👤 ${obj["assigned_to"]}",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 16),

                // ── BOTONES ──────────────────────────────
                Row(
                  children: [

                    // Cambiar estado
                    Expanded(
                      child: _buildActionButton(
                        label: isFound ? "Marcar extraviado" : "Marcar encontrado",
                        icon:  isFound ? Icons.search : Icons.check_circle_outline,
                        color: isFound ? Colors.orangeAccent : Colors.greenAccent,
                        onTap: () => _cambiarEstado(id, !isFound),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Eliminar
                    Expanded(
                      child: _buildActionButton(
                        label: "Eliminar",
                        icon:  Icons.delete_outline,
                        color: Colors.redAccent,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isFound
            ? Colors.greenAccent.withOpacity(0.15)
            : Colors.orangeAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFound ? Colors.greenAccent : Colors.orangeAccent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFound ? Icons.check_circle_outline : Icons.search,
            color: isFound ? Colors.greenAccent : Colors.orangeAccent,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isFound ? "Encontrado" : "Extraviado",
            style: TextStyle(
              color: isFound ? Colors.greenAccent : Colors.orangeAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String   label,
    required IconData icon,
    required Color    color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
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
                fontWeight: FontWeight.bold,
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
      _mostrarMensaje("Error de conexión con el servidor");
    }

    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _cambiarEstado(int id, bool nuevoEstado) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/objects/$id/status?is_found=$nuevoEstado"),
      );

      if (response.statusCode == 200) {
        // Actualizar localmente sin recargar toda la lista
        setState(() {
          final index = _objetos.indexWhere((o) => o["id"] == id);
          if (index != -1) _objetos[index]["is_found"] = nuevoEstado;
        });
      } else {
        _mostrarMensaje("Error al cambiar estado");
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión con el servidor");
    }
  }

  Future<void> _eliminarObjeto(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/objects/$id"));

      if (response.statusCode == 200) {
        setState(() => _objetos.removeWhere((o) => o["id"] == id));
        _mostrarMensaje("Objeto eliminado");
      } else {
        _mostrarMensaje("Error al eliminar");
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión con el servidor");
    }
  }

  // =========================================================
  // DIÁLOGO CONFIRMACIÓN ELIMINAR
  // =========================================================

  void _confirmarEliminar(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "¿Eliminar objeto?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Esta acción no se puede deshacer.",
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarObjeto(id);
            },
            child: const Text(
              "Eliminar",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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