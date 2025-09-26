import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



const fondo = Color(0xFFF8FAFC);
const colorPrimario = Color(0xFF86B6F6); 
const colorSecundario = Color(0xFFEEF5FF); 
const colorAcento = Color(0xFF2C6E7B);
const colorFondo = Color(0xFFF8FAFC);
const colorAcento2 = Color(0xFF3A8FA0);

class RecuperarContrasenaScreen extends StatefulWidget {
  final String? initialEmail;
  const RecuperarContrasenaScreen({super.key, this.initialEmail});

  @override
  State<RecuperarContrasenaScreen> createState() => _RecuperarContrasenaScreenState();
}

class _RecuperarContrasenaScreenState extends State<RecuperarContrasenaScreen> {
  late final TextEditingController _emailController;
  final _repetirEmailController = TextEditingController();

  bool _loading = false; // <-- estaba faltando

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _repetirEmailController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final email = _emailController.text.trim();
    final repetirEmail = _repetirEmailController.text.trim();

    if (email.isEmpty || repetirEmail.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Completá ambos campos')));
      return;
    }
    if (email != repetirEmail) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Los emails no coinciden')));
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te enviamos un email para restablecer tu contraseña')),
      );
      Navigator.of(context).pop(); // volver al login
    } on FirebaseAuthException catch (e) {
      String msg = 'Error al enviar el email';
      if (e.code == 'user-not-found') msg = 'No existe un usuario con ese email';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png',
                    height: 140, fit: BoxFit.contain),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorSecundario,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Recuperar contraseña',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: colorAcento,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                            border: const OutlineInputBorder(                      // CAMBIO
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            enabledBorder: const OutlineInputBorder(               // CAMBIO
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Colors.black26, width: 1.2),
                            ),
                            focusedBorder: const OutlineInputBorder(               // CAMBIO
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: colorPrimario, width: 1.2),
                            ),
                            floatingLabelStyle: const TextStyle(color: colorPrimario), // CAMBIO
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _repetirEmailController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: colorAcento,
                        decoration: const InputDecoration(
                          labelText: 'Repetir email',
                          border: const OutlineInputBorder(                      // CAMBIO
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          enabledBorder: const OutlineInputBorder(               // CAMBIO
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.black26, width: 1.2),
                          ),
                          focusedBorder: const OutlineInputBorder(               // CAMBIO
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: colorPrimario, width: 1.2),
                          ),
                          floatingLabelStyle: const TextStyle(color: colorPrimario), // CAMBIO
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _loading ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: colorAcento, width: 2),
                          foregroundColor: colorAcento,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Anterior'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _confirmar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorAcento,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(_loading ? 'Enviando…' : 'Confirmar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
