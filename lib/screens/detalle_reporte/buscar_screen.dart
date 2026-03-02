import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../app/routes.dart';
import '../../models/app_colors.dart'; // 👈 IMPORTAMOS LA PALETA COMPARTIDA

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

  // Controlador para el foco del teclado
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Dar foco automáticamente al campo de búsqueda cuando se abre la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
              // ── CABECERA CON VOLVER Y TÍTULO ───────────────
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
                    "Buscar objetos",
                    style: TextStyle(
                      color: AppColors.textoClaro,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── CAMPO DE BÚSQUEDA MEJORADO ─────────────────
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amarilloAccion.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _busquedaController,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "¿Qué estás buscando?",
                    hintStyle: TextStyle(
                      color: AppColors.textoSecundarioClaro.withOpacity(0.7),
                    ),
                    filled: true,
                    fillColor: AppColors.inputFondo,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textoSecundarioClaro,
                    ),
                    suffixIcon: _busquedaController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.textoSecundarioClaro,
                      ),
                      onPressed: () {
                        _busquedaController.clear();
                        setState(() {
                          _resultados = [];
                        });
                      },
                    )
                        : null,
                  ),
                  onSubmitted: (_) => _buscar(),
                ),
              ),

              const SizedBox(height: 16),

              // ── SUGERENCIAS / TENDENCIAS ───────────────────
              if (_resultados.isEmpty && !_cargando)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: AppColors.amarilloAccion,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Búsquedas frecuentes:",
                        style: TextStyle(
                          color: AppColors.textoSecundarioClaro,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              if (_resultados.isEmpty && !_cargando)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildSuggestionChip("Cartera"),
                      _buildSuggestionChip("Celular"),
                      _buildSuggestionChip("Llaves"),
                      _buildSuggestionChip("Mochila"),
                      _buildSuggestionChip("Laptop"),
                      _buildSuggestionChip("Tarjeta"),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // ── CONTADOR DE RESULTADOS ────────────────────
              if (_resultados.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "${_resultados.length} ${_resultados.length == 1 ? 'resultado encontrado' : 'resultados encontrados'}",
                    style: TextStyle(
                      color: AppColors.textoSecundarioClaro,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              // ── RESULTADOS ─────────────────────────────────
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
                        "Buscando...",
                        style: TextStyle(
                          color: AppColors.textoSecundarioClaro,
                        ),
                      ),
                    ],
                  ),
                )
                    : _resultados.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  itemCount: _resultados.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = _resultados[index];
                    return _buildResultCard(item);
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

  Widget _buildSuggestionChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: AppColors.textoClaro,
            fontSize: 13,
          ),
        ),
        onSelected: (selected) {
          _busquedaController.text = label;
          _buscar();
        },
        backgroundColor: AppColors.inputFondo,
        selectedColor: AppColors.amarilloAccion,
        checkmarkColor: AppColors.azulProfundo,
        labelStyle: TextStyle(
          color: AppColors.textoClaro,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.textoSecundarioClaro.withOpacity(0.2),
          ),
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
              Icons.search_off,
              size: 60,
              color: AppColors.textoSecundarioClaro.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No hay resultados",
            style: TextStyle(
              color: AppColors.textoClaro,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Intenta con otras palabras o revisa la ortografía",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textoSecundarioClaro,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _busquedaController.clear();
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Limpiar búsqueda"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.inputFondo,
              foregroundColor: AppColors.textoClaro,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(
                  color: AppColors.textoSecundarioClaro.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CARD DE RESULTADO MEJORADA
  // =========================================================

  Widget _buildResultCard(Map<String, dynamic> item) {
    final bool isFound = item["is_found"] ?? false;
    final String? imageBase64 = item["image_base64"];
    final double score = (item["score"] as num?)?.toDouble() ?? 0.0;

    // Determinar color basado en el score (relevancia)
    Color scoreColor = AppColors.amarilloAccion;
    if (score >= 0.7) {
      scoreColor = Colors.greenAccent;
    } else if (score >= 0.4) {
      scoreColor = AppColors.amarilloAccion;
    } else {
      scoreColor = Colors.orangeAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.inputFondo,
        borderRadius: BorderRadius.circular(20),
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
          // ── IMAGEN CON BADGE SUPERPUESTO ─────────────────
          if (imageBase64 != null && imageBase64.isNotEmpty)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.memory(
                    base64Decode(imageBase64),
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                // Badge de relevancia
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.azulProfundo.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: scoreColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: scoreColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${(score * 100).toInt()}%",
                          style: TextStyle(
                            color: scoreColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          // ── CONTENIDO ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descripción y badge de estado
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item["description"] ?? "Sin descripción",
                        style: TextStyle(
                          color: AppColors.textoClaro,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildStatusBadge(isFound),
                  ],
                ),

                const SizedBox(height: 12),

                // Ubicación con ícono
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.azulMedio,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item["location"] ?? "Ubicación no especificada",
                        style: TextStyle(
                          color: AppColors.textoSecundarioClaro,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Encargado con ícono
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.azulMedio,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item["assigned_to"] ?? "Sin asignar",
                      style: TextStyle(
                        color: AppColors.textoSecundarioClaro,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Barra de relevancia (opcional)
                LinearProgressIndicator(
                  value: score,
                  backgroundColor: AppColors.textoSecundarioClaro.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isFound) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isFound
            ? AppColors.verdeExito?.withOpacity(0.15) ?? Colors.green.withOpacity(0.15)
            : AppColors.amarilloAccion.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFound
              ? AppColors.verdeExito ?? Colors.green
              : AppColors.amarilloAccion,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFound ? Icons.check_circle_outline : Icons.search,
            color: isFound
                ? AppColors.verdeExito ?? Colors.green
                : AppColors.amarilloAccion,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isFound ? "Encontrado" : "Extraviado",
            style: TextStyle(
              color: isFound
                  ? AppColors.verdeExito ?? Colors.green
                  : AppColors.amarilloAccion,
              fontSize: 12,
              fontWeight: FontWeight.bold,
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
    if (query.isEmpty) {
      _mostrarMensaje("Ingresa un término de búsqueda");
      return;
    }

    // Quitar foco del teclado
    FocusScope.of(context).unfocus();

    setState(() {
      _cargando = true;
      _resultados = [];
    });

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/search"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": query}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> resultados = jsonDecode(response.body);
        setState(() => _resultados = resultados);

        if (resultados.isEmpty) {
          _mostrarMensaje("No se encontraron resultados para '$query'");
        }
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