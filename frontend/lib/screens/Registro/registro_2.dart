import 'package:flutter/material.dart';

// Colores compartidos (los mismos de registro_1.dart)
const fondo = Color(0xFFF8FAFC);
const colorPrimario = Color(0xFF86B6F6);
const colorSecundario = Color(0xFFEEF5FF);
const colorAcento = Color(0xFF2C6E7B);
const colorFondo = Color(0xFFF8FAFC);
const colorAcento2 = Color(0xFF3A8FA0);

class RegisterStep2Screen extends StatefulWidget {
  final String nombre; // ← viene desde registro_1.dart

  const RegisterStep2Screen({super.key, required this.nombre});

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _repetirEmailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _cuentaCreada = false; // ← controla si ya mostramos el mensaje final

  @override
  void dispose() {
    _emailCtrl.dispose();
    _repetirEmailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Helpers para bordes de los TextFields
  OutlineInputBorder _tfBorder([Color? c]) => OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: c ?? Colors.black26, width: 1.2),
      );

  InputDecoration _dec(String label, {Widget? suffix}) => InputDecoration(
        labelText: label,
        border: _tfBorder(),
        enabledBorder: _tfBorder(),
        focusedBorder: _tfBorder(colorPrimario),
        suffixIcon: suffix,
        floatingLabelStyle: const TextStyle(color: colorPrimario),
      );

  void _confirmar() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _cuentaCreada = true;
      });
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
                const SizedBox(height: 24),

                !_cuentaCreada ? _buildFormulario() : _buildMensajeBienvenida(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// FORMULARIO DE CREACIÓN DE USUARIO
  Widget _buildFormulario() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorSecundario,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              "Crear usuario",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _dec("Email"),
              validator: (v) =>
                  (v == null || v.isEmpty) ? "Ingresá tu email" : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _repetirEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _dec("Repetir email"),
              validator: (v) {
                if (v == null || v.isEmpty) return "Repetí tu email";
                if (v != _emailCtrl.text) return "Los emails no coinciden";
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              decoration: _dec(
                "Contraseña",
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) => (v == null || v.length < 6)
                  ? "La contraseña debe tener al menos 6 caracteres"
                  : null,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: colorAcento),
                      shape: const StadiumBorder(),
                      foregroundColor: colorAcento,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Anterior"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirmar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorAcento,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Confirmar"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// MENSAJE DE BIENVENIDA DESPUÉS DE CREAR LA CUENTA
  Widget _buildMensajeBienvenida() {
    final nombre = widget.nombre; // viene desde registro_1.dart

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorSecundario,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: colorAcento, size: 48),
          const SizedBox(height: 16),
          Text(
            "¡Bienvenido, $nombre!",
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "Tu cuenta fue creada correctamente.\n"
            "Ahora podés reservar turnos y gestionar tus datos desde la app.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorAcento,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
            ),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }
}
