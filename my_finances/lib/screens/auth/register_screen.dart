import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      await user?.updateDisplayName(_nameController.text.trim());

      // Salvar dados adicionais no Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(user?.uid).set({
        'uid': user?.uid,
        'nome': _nameController.text.trim(),
        'telefone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'criadoEm': Timestamp.now(),
      });

      // Alerta de sucesso
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sucesso!'),
          content: const Text('Usuário cadastrado com sucesso!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha alerta
                Navigator.pop(context); // Volta para a tela de login
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Alerta de erro
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro!'),
          content: Text('Erro ao cadastrar: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E8B57), Color(0xFF66CDAA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', height: 120),
                  const SizedBox(height: 30),
                  _buildTextField(Icons.person, 'Nome', false, _nameController),
                  const SizedBox(height: 15),
                  _buildTextField(Icons.phone, 'Telefone', false, _phoneController),
                  const SizedBox(height: 15),
                  _buildTextField(Icons.email, 'Email', false, _emailController),
                  const SizedBox(height: 15),
                  _buildTextField(Icons.lock, 'Senha', true, _passwordController),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Text('Cadastrar', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                        ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Voltar para a tela de login
                    },
                    child: const Text('Já tem uma conta? Entrar', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label, bool isPassword, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: label == 'Telefone'
          ? TextInputType.phone
          : isPassword
              ? TextInputType.text
              : TextInputType.emailAddress,
    );
  }
}
