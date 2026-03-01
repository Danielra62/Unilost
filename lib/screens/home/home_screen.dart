import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../app/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// 🔥 ORDEN SOCIAL
          objetos.sort((a, b) {

            // 1️⃣ Encontrados siempre al fondo
            if (a["is_found"] != b["is_found"]) {
              return a["is_found"] ? 1 : -1;
            }

            // 2️⃣ Más likes arriba
            int likesA = a["likes_count"] ?? 0;
            int likesB = b["likes_count"] ?? 0;

            if (likesA != likesB) {
              return likesB.compareTo(likesA);
            }

            // 3️⃣ Si tienen mismos likes → más reciente arriba
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

    const Color azulMarino = Color(0xFF0D1B2A);
    const Color azulBoton = Color(0xFF1B263B);

    return Scaffold(
      backgroundColor: azulMarino,

      appBar: AppBar(
        backgroundColor: azulMarino,
        elevation: 0,
        title: const Text("UNILOST"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              Navigator.pushNamed(context, Routes.buscar);
              obtenerObjetos();
            },
          ),
        ],
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : objetos.isEmpty
          ? const Center(
        child: Text(
          "No hay objetos reportados aún",
          style: TextStyle(color: Colors.white),
        ),
      )
          : RefreshIndicator(
        onRefresh: obtenerObjetos,
        child: ListView.builder(
          itemCount: objetos.length,
          itemBuilder: (context, index) {
            final obj = objetos[index];

            return Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🖼 IMAGEN
                  if (obj["image_base64"] != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: Image.memory(
                        base64Decode(obj["image_base64"]),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        // 📝 DESCRIPCIÓN
                        Text(
                          obj["description"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // 📍 UBICACIÓN
                        Text("Ubicación: ${obj["location"]}"),

                        const SizedBox(height: 4),

                        // 👤 ENCARGADO
                        Text("Encargado: ${obj["assigned_to"]}"),

                        const SizedBox(height: 6),

                        // ESTADO
                        Row(

                          children: [
                            Icon(
                              obj["is_found"]
                                  ? Icons.check_circle
                                  : Icons.search,
                              color: obj["is_found"]
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              obj["is_found"]
                                  ? "Encontrado"
                                  : "Extraviado",
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

// 🔥 Badge Alta Visibilidad
                        if ((obj["likes_count"] ?? 0) >= 5 &&
                            obj["is_found"] == false)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "🔥 Alta Visibilidad",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        const SizedBox(height: 8),

// ❤️ Likes Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Row(
                              children: [
                                const Icon(Icons.favorite, color: Colors.red),
                                const SizedBox(width: 5),
                                Text(
                                  "${obj["likes_count"] ?? 0}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                            IconButton(
                              icon: const Icon(Icons.favorite_border),
                              color: Colors.red,
                              onPressed: () async {

                                if (userId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Sesión no válida")),
                                  );
                                  return;
                                }

                                await http.post(
                                  Uri.parse(
                                      "${Config.baseUrl}/objects/${obj["id"]}/like?user_id=$userId"
                                  ),
                                );

                                await obtenerObjetos(); // refresca correctamente
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      // ➕ BOTÓN REPORTAR
      floatingActionButton: FloatingActionButton(
        backgroundColor: azulBoton,
        onPressed: () async {

          final result = await Navigator.pushNamed(
            context,
            Routes.crearReporte,
          );

          if (result == true) {
            obtenerObjetos();
          }

        },
        child: const Icon(Icons.add),
      ),
    );
  }
}