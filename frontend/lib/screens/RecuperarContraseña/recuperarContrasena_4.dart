import 'package:flutter/material.dart';
import '../Login/login_screen.dart';
import 'package:flutter_application_1/config/paleta_colores.dart' as pal;

class RecuperarContrasena4 extends StatelessWidget {
  const RecuperarContrasena4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pal.fondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono
                Icon(
                  Icons.check_circle_outline,
                  size: 120,
                  color: pal.colorAcento,
                ),
                const SizedBox(height: 28),

                // CARD
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
                  child: Column(
                    children: [
                      const Text(
                        "¡Contraseña cambiada con éxito!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Ahora podés iniciar sesión con tu nueva contraseña.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // BOTÓN — PILLOTA
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pal.colorAcento,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: const Text(
                            "Volver al login",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
