import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPressed = false;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _loginUser() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Erro ao fazer login.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'E-mail ou senha incorretos.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Icon(Icons.content_cut, color: Color(0xFFD32F2F), size: 80),
              const SizedBox(height: 10),
              const Text(
                "BARBÚ",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 12,
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              const Text(
                "PREMIUM EXPERIENCE",
                style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 2),
              ),
              const SizedBox(height: 60),

              _buildTextField(label: "E-mail", icon: Icons.email_outlined, controller: _emailController),
              const SizedBox(height: 20),
              _buildTextField(label: "Senha", icon: Icons.lock_outline, isObscure: true, controller: _passwordController),
              
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Esqueceu a senha?", style: TextStyle(color: Colors.white54)),
                ),
              ),
              const SizedBox(height: 30),

              GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                onTap: _isLoading ? null : _loginUser,
                child: AnimatedScale(
                  scale: _isPressed ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD32F2F).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("ENTRAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Não tem uma conta?", style: TextStyle(color: Colors.white54)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text("Cadastre-se", style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required IconData icon, bool isObscure = false, required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: const Color(0xFFD32F2F)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}