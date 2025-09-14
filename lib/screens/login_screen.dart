import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

// Color marca (verde/teal)
const kBrand = Color(0x9C176B87);
const kFondo = Color(0xFFF8FAFC);



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
    return Theme(
      // Estilo local para los TextField de ESTA pantalla
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle: const TextStyle(color: kBrand),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: kBrand, width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kBrand.withOpacity(0.35)),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: kFondo, // fondo blanco suave
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Image.asset('assets/logo.png', height: 140, fit: BoxFit.contain),
                  const SizedBox(height: 16),

                  // Campos
                  TextField(
                    controller: _email,
                    cursorColor: kBrand,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    cursorColor: kBrand,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.black54),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {/* TODO: reset password */},
                      style: TextButton.styleFrom(foregroundColor: Colors.black54),
                      child: const Text('¿Olvidó su contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Botón Iniciar sesión (relleno)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrand,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _loading
                        ? null
                        : () async {
                            final email = _email.text.trim();
                            final pass = _password.text;
                            if (email.isEmpty || pass.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Completá email y contraseña'),
                                ),
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
                                case 'user-not-found':
                                  msg = 'Usuario no encontrado';
                                  break;
                                case 'wrong-password':
                                  msg = 'Contraseña incorrecta';
                                  break;
                                case 'invalid-email':
                                  msg = 'Email inválido';
                                  break;
                                case 'invalid-credential':
                                  msg = 'Credenciales inválidas';
                                  break;
                              }
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(msg)));
                            } finally {
                              if (mounted) setState(() => _loading = false);
                            }
                          },
                    child: Text(_loading ? 'Ingresando...' : 'Iniciar sesión'),
                  ),

                  const SizedBox(height: 12),

                  // Botón Registrarse (outlined)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kBrand,
                      side: const BorderSide(color: kBrand, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {/* TODO: ir a registro */},
                    child: const Text('Registrarse'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}