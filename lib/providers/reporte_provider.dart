import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app/routes.dart';
import '../models/reporte.dart';

class ReporteProvider extends ChangeNotifier {
  final String baseUrl = Config.baseUrl;

  List<Reporte> _reportes = [];

  List<Reporte> get todosLosReportes => _reportes;



  Future<void> cargarReportesDesdeApi() async {
    final response = await http.get(Uri.parse('$baseUrl/reportes'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      _reportes = data.map((e) => Reporte.fromJson(e)).toList();
      notifyListeners();
    } else {
      throw Exception('Error al cargar reportes');
    }
  }

  void agregarReporteLocal(Reporte reporte) {
    _reportes.insert(0, reporte);
    notifyListeners();
  }
}
