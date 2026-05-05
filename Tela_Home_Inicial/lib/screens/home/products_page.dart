import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("Loja", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFFD32F2F)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text("Nossos produtos em breve...", style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}