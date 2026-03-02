import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../app/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🎨 PALETA DE COLORES (mantenemos la misma)
class AppColors {
  static const Color azulProfundo = Color(0xFF2A3F5E);
  static const Color azulMedio = Color(0xFF4F7EB3);
  static const Color amarilloAccion = Color(0xFFF9A826);
  static const Color verdeExito = Color(0xFF2E7D32);
  static const Color rojoAlerta = Color(0xFFC62828);
  static const Color naranjaVisibilidad = Color(0xFFF57C00);
  static const Color rojoFavorito = Color(0xFFE91E63);
  static const Color fondoGlobal = Color(0xFFF4F7FB);
  static const Color fondoBlanco = Color(0xFFFFFFFF);
  static const Color textoPrincipal = Color(0xFF1E2B3C);
  static const Color textoSecundario = Color(0xFF5E6F88);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? userId;
  List objetos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  Future<void> inicializar() async {
    await cargarUsuario();
    await obtenerObjetos();
  }

  Future<void> obtenerObjetos() async {
    try {
      final response = await http.get(
        Uri.parse("${Config.baseUrl}/objects"),
      );

      if (response.statusCode == 200) {
        setState(() {
          objetos = jsonDecode(response.body);
          objetos.sort((a, b) {
            if (a["is_found"] != b["is_found"]) {
              return a["is_found"] ? 1 : -1;
            }
            int likesA = a["likes_count"] ?? 0;
            int likesB = b["likes_count"] ?? 0;
            if (likesA != likesB) {
              return likesB.compareTo(likesA);
            }
            return (b["id"] as int).compareTo(a["id"] as int);
          });
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("user_id");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoGlobal,

      appBar: AppBar(
        backgroundColor: AppColors.fondoGlobal,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.amarilloAccion,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.search,
                color: AppColors.azulProfundo,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "UNILOST",
              style: TextStyle(
                color: AppColors.azulProfundo,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.azulProfundo.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.search, color: AppColors.azulProfundo),
              onPressed: () async {
                await Navigator.pushNamed(context, Routes.buscar);
                obtenerObjetos();
              },
            ),
          ),
        ],
      ),

      body: cargando
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.amarilloAccion),
        ),
      )
          : objetos.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: obtenerObjetos,
        color: AppColors.amarilloAccion,
        backgroundColor: AppColors.azulProfundo,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: objetos.length,
          itemBuilder: (context, index) {
            final obj = objetos[index];
            return _buildObjectCard(obj);
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.amarilloAccion,
        foregroundColor: AppColors.azulProfundo,
        elevation: 8,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            Routes.crearReporte,
          );
          if (result == true) {
            obtenerObjetos();
          }
        },
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
              color: AppColors.azulProfundo.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox,
              size: 50,
              color: AppColors.azulProfundo.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No hay objetos reportados",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textoPrincipal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Sé el primero en ayudar",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectCard(Map<String, dynamic> obj) {
    final bool isFound = obj["is_found"] ?? false;
    final int likes = obj["likes_count"] ?? 0;
    final bool altaVisibilidad = likes >= 5 && !isFound;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          if (obj["image_base64"] != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.memory(
                    base64Decode(obj["image_base64"]),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Badge de estado en la imagen
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildStatusBadge(isFound),
                ),
                // Badge de alta visibilidad
                if (altaVisibilidad)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildHighVisibilityBadge(),
                  ),
              ],
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descripción
                Text(
                  obj["description"] ?? "Sin descripción",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoPrincipal,
                  ),
                ),

                const SizedBox(height: 12),

                // Ubicación
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.azulMedio,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        obj["location"] ?? "Ubicación no especificada",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textoSecundario,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Encargado
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.azulMedio,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      obj["assigned_to"] ?? "Sin asignar",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textoSecundario,
                      ),
                    ),
                  ],
                ),

                // Si no hay imagen, mostrar badge de estado aquí
                if (obj["image_base64"] == null) ...[
                  const SizedBox(height: 12),
                  _buildStatusBadge(isFound),
                  if (altaVisibilidad) ...[
                    const SizedBox(height: 8),
                    _buildHighVisibilityBadge(),
                  ],
                ],

                const SizedBox(height: 16),

                // Likes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Contador
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 18,
                          color: AppColors.rojoFavorito,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$likes",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.rojoFavorito,
                          ),
                        ),
                      ],
                    ),

                    // Botón like
                    GestureDetector(
                      onTap: () async {
                        if (userId == null) {
                          _showSnackBar("Inicia sesión para dar like");
                          return;
                        }
                        await http.post(
                          Uri.parse(
                              "${Config.baseUrl}/objects/${obj["id"]}/like?user_id=$userId"),
                        );
                        await obtenerObjetos();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.rojoFavorito.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 16,
                              color: AppColors.rojoFavorito,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Me gusta",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.rojoFavorito,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildStatusBadge(bool isFound) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isFound
            ? AppColors.verdeExito.withOpacity(0.9)
            : AppColors.rojoAlerta.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFound ? Icons.check_circle : Icons.priority_high,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isFound ? "Encontrado" : "Extraviado",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighVisibilityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.naranjaVisibilidad.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.whatshot,
            size: 14,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            "Alta Visibilidad",
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.azulProfundo,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}