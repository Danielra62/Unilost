import 'package:flutter/material.dart';
import 'routes.dart';

class UniLostApp extends StatelessWidget {
  const UniLostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniLost',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      initialRoute: Routes.login,
      routes: appRoutes,
    );
  }
}
