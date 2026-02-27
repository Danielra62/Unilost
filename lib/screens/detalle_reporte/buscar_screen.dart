import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app/routes.dart';

class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {

  final TextEditingController _busquedaController = TextEditingController();
  final String baseUrl = Config.baseUrl;

  bool _cargando = false;
  List<dynamic> _resultados = [];

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

              // 🔙 BOTÓN VOLVER
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),

              const SizedBox(height: 10),

              const Text(
                "BUSCAR OBJETO",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              // ── CAMPO DE BÚSQUEDA ──────────────────────────
              TextField(
                controller: _busquedaController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Escribe lo que estás buscando...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: azulCard,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: _buscar,
                  ),
                ),
                onSubmitted: (_) => _buscar(),
              ),

              const SizedBox(height: 30),

              // ── RESULTADOS ─────────────────────────────────
              Expanded(
                child: _cargando
                    ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : _resultados.isEmpty
                    ? const Center(
                  child: Text(
                    "No hay resultados",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: _resultados.length,
                  itemBuilder: (context, index) {
                    final item = _resultados[index];
                    return _buildCard(item, azulCard);
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
  // CARD DE RESULTADO
  // =========================================================

  Widget _buildCard(Map<String, dynamic> item, Color azulCard) {

    final bool   isFound      = item["is_found"] ?? false;
    final String? imageBase64 = item["image_base64"];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: azulCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── IMAGEN (si existe) ───────────────────────────
          if (imageBase64 != null && imageBase64.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.memory(
                base64Decode(imageBase64),
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),

          // ── CONTENIDO ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Descripción + badge de estado en la misma fila
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Expanded(
                      child: Text(
                        item["description"] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Badge estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isFound
                            ? Colors.greenAccent.withOpacity(0.15)
                            : Colors.orangeAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isFound
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFound
                                ? Icons.check_circle_outline
                                : Icons.search,
                            color: isFound
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isFound ? "Encontrado" : "Extraviado",
                            style: TextStyle(
                              color: isFound
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  "📍 ${item["location"]}",
                  style: const TextStyle(color: Colors.white70),
                ),

                Text(
                  "👤 ${item["assigned_to"]}",
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 6),

                Text(
                  "🎯 Score: ${(item["score"] as num).toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // API /search
  // =========================================================

  Future<void> _buscar() async {

    final query = _busquedaController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _cargando   = true;
      _resultados = [];
    });

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/search"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": query}),
      );

      if (response.statusCode == 200) {
        setState(() => _resultados = jsonDecode(response.body));
      } else {
        _mostrarMensaje("Error al buscar");
      }

    } catch (e) {
      _mostrarMensaje("Error de conexión con el servidor");
    }

    setState(() => _cargando = false);
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