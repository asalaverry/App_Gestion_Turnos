import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Home/home_screen.dart';
import '../Registro/registro_1.dart';
import '../RecuperarContraseña/recuperarContrasena_1.dart'; 
import 'package:flutter_application_1/config/paleta_colores.dart' as pal;

const fondo = Color(0xFFF8FAFC);
const colorPrimario = Color(0xFF86B6F6); 
const colorSecundario = Color(0xFFEEF5FF); 
const colorAcento = Color(0xFF2C6E7B);
const colorFondo = Color(0xFFF8FAFC);
const colorAcento2 = Color(0xFF3A8FA0);
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
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.black54),
          floatingLabelStyle: const TextStyle(color: pal.colorPrimario),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.black26, width: 1.2),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: pal.colorPrimario, width: 1.2),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        ),
      ),
      child: Scaffold(
        backgroundColor: pal.fondo,
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

                  // Email
                  TextField(
                    controller: _email,
                    cursorColor: pal.colorAcento,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),

                  // Contraseña
                  TextField(
                    controller: _password,
                    cursorColor: pal.colorAcento,
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecuperarContrasena1(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.black54),
                      child: const Text('¿Olvidó su contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Botón Iniciar sesión
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pal.colorAcento,
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

                  // Botón Registrarse
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: pal.colorAcento,
                      side: const BorderSide(color: pal.colorAcento, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
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
