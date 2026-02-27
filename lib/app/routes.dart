import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import '../screens/crear_reporte/crear_reporte_screen.dart';
import '../screens/detalle_reporte/buscar_screen.dart';
import '../screens/home/login_screen.dart';
import '../screens/home/registro_screen.dart';
import '../screens/detalle_reporte/admin_screen.dart';

class Routes {
  static const String login        = '/';
  static const String registro     = '/registro';
  static const String home         = '/home';
  static const String crearReporte = '/crear-reporte';
  static const String buscar       = '/buscar';
  static const String admin        = '/admin';
}

final Map<String, WidgetBuilder> appRoutes = {
  Routes.login:        (context) => const LoginScreen(),
  Routes.registro:     (context) => const RegistroScreen(),
  Routes.home:         (context) => const HomeScreen(),
  Routes.crearReporte: (context) => const CrearReporteScreen(),
  Routes.buscar:       (context) => const BuscarScreen(),
  Routes.admin:        (context) => const AdminScreen(),
};

class Config {
  static const String baseUrl =
  String.fromEnvironment('BASE_URL', defaultValue: '');
}