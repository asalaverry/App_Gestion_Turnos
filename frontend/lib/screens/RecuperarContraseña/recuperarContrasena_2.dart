import 'package:flutter/material.dart';
import 'recuperarContrasena_3.dart';
import 'package:flutter_application_1/config/paleta_colores.dart' as pal;


class Recuperarcontrasena2 extends StatefulWidget {
  final String initialEmail;
  const Recuperarcontrasena2({super.key, required this.initialEmail});

  @override
  State<Recuperarcontrasena2> createState() => _Recuperarcontrasena2State();
}

class _Recuperarcontrasena2State extends State<Recuperarcontrasena2> {
  bool _reenviando = false;

  void _continuar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecuperarContrasena3()),
    );
  }

  void _cancelar() {
    Navigator.pop(context);
  }

  Future<void> _reenviar() async {
    setState(() => _reenviando = true);
    try {
      // OPCIONAL — si usás Firebase:
      // await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.initialEmail);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reenviamos el correo a ${widget.initialEmail}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo reenviar: $e")),
      );
    } finally {
      if (mounted) setState(() => _reenviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pal.fondo,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/logo.png", height: 120),
              const SizedBox(height: 32),

              // ========= CARD =========
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Revisá tu correo electrónico",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      "Te enviamos un enlace para restablecer tu contraseña a:\n"
                      "${widget.initialEmail}\n\n"
                      "El enlace vencerá en 15 minutos.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 22),
                    Icon(Icons.vpn_key, size: 38, color: pal.colorAcento),
                    const SizedBox(height: 26),

                    // ========= Botón Continuar =========
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _continuar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pal.colorAcento,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),   
                          ),
                        ),
                        child: const Text(
                          "Continuar",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ========= Botón Cancelar =========
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _cancelar,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: pal.colorAcento,   
                          side: BorderSide(
                             color: pal.colorAcento, 
                            width: 1.2,
                          ),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),   
                          ),
                        ),
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: pal.colorAcento, 
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: _reenviando ? null : _reenviar,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "¿No recibiste el correo? ",
                          style: const TextStyle(color: Colors.black54),
                          children: [
                            TextSpan(
                              text: _reenviando ? "Reenviando…" : "Reenviar",
                              style: TextStyle(
                                color: pal.colorAcento,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),
                    const Text(
                      "Recordá revisar la carpeta de spam.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
