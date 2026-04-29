import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Mantenha o seu import de tema se estiver usando
import '../../core/theme/app_theme.dart'; 

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _registerUser() async {
    setState(() => _isLoading = true);
    try {
      // 1. Cria o usuário na Autenticação do Firebase (E-mail e Senha)
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Salva os dados extras (Nome e Telefone) no banco de dados Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Se tudo deu certo, vai para a Home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Erro ao criar conta.';
      if (e.code == 'weak-password') {
        message = 'A senha é muito fraca (mínimo 6 caracteres).';
      } else if (e.code == 'email-already-in-use') {
        message = 'Este e-mail já está em uso.';
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
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFD32F2F)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Criar Conta",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text(
              "Preencha os dados para começar",
              style: TextStyle(color: Colors.white38),
            ),
            const SizedBox(height: 40),
            
            _buildInputField(label: "Nome Completo", icon: Icons.person_outline, controller: _nameController),
            const SizedBox(height: 20),
            _buildInputField(label: "Telefone", icon: Icons.phone_android_outlined, controller: _phoneController, isNumber: true),
            const SizedBox(height: 20),
            _buildInputField(label: "E-mail", icon: Icons.email_outlined, controller: _emailController, isEmail: true),
            const SizedBox(height: 20),
            _buildInputField(label: "Senha", icon: Icons.lock_outline, isObscure: true, controller: _passwordController),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("CADASTRAR", style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label, 
    required IconData icon, 
    bool isObscure = false, 
    required TextEditingController controller,
    bool isEmail = false,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: isEmail ? TextInputType.emailAddress : (isNumber ? TextInputType.phone : TextInputType.text),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFFD32F2F)),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}