import 'package:flutter/material.dart';
import 'package:optigas/views/ConfiguracionInicial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Configuración',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false, // Desactiva el banner de depuración
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToConfigScreen();
  }

  // Método para navegar a la pantalla de configuración después de un retraso
  Future<void> _navigateToConfigScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // Espera 10 segundos
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ConfiguracionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      body: Center(
        child: Transform.scale(
          scale: 0.5, // Escala al 80% del tamaño original
          child: Image.asset('lib/assets/logo.jpeg'), // Logo centrado
        ),
      ),
    );
  }
}
