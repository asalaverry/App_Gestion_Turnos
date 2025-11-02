import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/paleta_colores.dart' as pal;
import 'recuperarContrasena_4.dart';

class RecuperarContrasena3 extends StatefulWidget {
  const RecuperarContrasena3({super.key});

  @override
  State<RecuperarContrasena3> createState() => _RecuperarContrasena3State();
}

class _RecuperarContrasena3State extends State<RecuperarContrasena3> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pal.fondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo.png",
                  height: 120,
                ),
                const SizedBox(height: 32),

                // ================== CARD ==================
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: pal.colorSecundario,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Nueva contraseña",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ================== CAMPO CONTRASEÑA ==================
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          cursorColor: pal.colorAcento,
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(
                                  color: Colors.black26, width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: pal.colorPrimario,
                                width: 1.5,
                              ),
                            ),
                            floatingLabelStyle:
                                TextStyle(color: pal.colorPrimario),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black54,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Ingrese la contraseña";
                            }
                            if (value.length < 6) {
                              return "Debe tener al menos 6 caracteres";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ================== CONFIRMAR CONTRASEÑA ==================
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          cursorColor: pal.colorAcento,
                          decoration: InputDecoration(
                            labelText: "Confirmar contraseña",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(
                                  color: Colors.black26, width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: pal.colorPrimario,
                                width: 1.5,
                              ),
                            ),
                            floatingLabelStyle:
                                TextStyle(color: pal.colorPrimario),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black54,
                              ),
                              onPressed: () =>
                                  setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return "Las contraseñas no coinciden";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 26),

                        // ================== BOTÓN ACEPTAR ==================
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pal.colorAcento,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50), // PILLS
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const RecuperarContrasena4(),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              "Aceptar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
