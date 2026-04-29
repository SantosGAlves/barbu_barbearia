import 'dart:async';
import 'package:flutter/material.dart';
// Importe o Firebase Auth para verificar o usuário
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Timer de 3 segundos
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Verifica se já existe um usuário logado no Firebase
        if (FirebaseAuth.instance.currentUser != null) {
          // Se sim, pula direto pra Home
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Se não, vai pro Login pedir a senha
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Cor de fundo do app
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.content_cut,
              size: 100,
              color: Color(0xFFD32F2F), // Vermelho Barbú
            ),
            const SizedBox(height: 24),
            const Text(
              'BARBÚ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8.0,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Color(0xFFD32F2F),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}