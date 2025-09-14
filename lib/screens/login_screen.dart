import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;


  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FlutterLogo(size: 96),
                const SizedBox(height: 24),

                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _loading ? null : () async {
                    final email = _email.text.trim();
                    final pass  = _password.text;

                    if (email.isEmpty || pass.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Completá email y contraseña')),
                      );
                      return;
                    }

                    setState(() => _loading = true);
                    try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email,
                        password: pass,
                    );
                    if (!mounted) return;
                      Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                    } on FirebaseAuthException catch (e) {
                      var msg = 'No se pudo iniciar sesión';
                      switch (e.code) {
                        case 'user-not-found': msg = 'Usuario no encontrado'; break;
                        case 'wrong-password': msg = 'Contraseña incorrecta'; break;
                        case 'invalid-email': msg = 'Email inválido'; break;
                        case 'invalid-credential': msg = 'Credenciales inválidas'; break;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                },
                child: Text(_loading ? 'Ingresando...' : 'Login'),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: () {}, // lo dejamos vacío por ahora
                  child: const Text('Registrarse'),
              ),

                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
