import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'registro_1.dart'; // Para importar UsuarioRegistro
import '../../config/api.dart';
import 'package:flutter_application_1/config/paleta_colores.dart' as pal;



class RegisterStep2Screen extends StatefulWidget {
  final UsuarioRegistro usuarioRegistro; // ← Ahora recibe el objeto completo

  const RegisterStep2Screen({super.key, required this.usuarioRegistro});

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
  bool _isLoading = false; // ← para mostrar loading durante el registro

  @override
  void dispose() {
    _emailCtrl.dispose();
    _repetirEmailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// PASO 1: Crear cuenta en Firebase Authentication
  Future<String?> _crearCuentaFirebase(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Retornar el UID del usuario creado
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al crear la cuenta';
      
      if (e.code == 'weak-password') {
        mensaje = 'La contraseña es muy débil';
      } else if (e.code == 'email-already-in-use') {
        mensaje = 'Este email ya está registrado';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El email no es válido';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
      return null;
    }
  }

  /// PASO 2: Guardar usuario en la base de datos
  Future<bool> _guardarUsuarioEnDB(String uid, String email) async {
    try {
      // Obtener el token de Firebase del usuario recién creado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no autenticado')),
        );
        return false;
      }

      final idToken = await user.getIdToken();
      
      // Preparar los datos completos del usuario
      final usuarioCompleto = {
        ...widget.usuarioRegistro.toJson(), // Datos de registro_1
        'email': email,                      // Email ingresado
        // No enviamos el uid, el backend lo obtiene del token
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // Token de Firebase para autenticación
        },
        body: jsonEncode(usuarioCompleto),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        final errorBody = response.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: ${response.statusCode} - $errorBody')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
      return false;
    }
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
        focusedBorder: _tfBorder(pal.colorPrimario),
        suffixIcon: suffix,
        floatingLabelStyle: const TextStyle(color: pal.colorPrimario),
      );

  /// FLUJO COMPLETO: Validar → Firebase → Base de Datos → Éxito
  void _confirmar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    // PASO 1: Crear cuenta en Firebase
    final uid = await _crearCuentaFirebase(email, password);
    
    if (uid == null) {
      setState(() {
        _isLoading = false;
      });
      return; // Si falló Firebase, no continuar
    }

    // PASO 2: Guardar en la base de datos
    final guardadoExitoso = await _guardarUsuarioEnDB(uid, email);

    setState(() {
      _isLoading = false;
    });

    if (guardadoExitoso) {
      // TODO: Si todo salió bien, mostrar mensaje de éxito
      setState(() {
        _cuentaCreada = true;
      });
    } else {
      // Si falló guardar en DB, eliminar la cuenta de Firebase
      try {
        await FirebaseAuth.instance.currentUser?.delete();
      } catch (e) {
        // Silencioso, ya mostramos el error antes
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo completar el registro. Intentá de nuevo.')),
      );
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
        color: pal.colorSecundario,
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
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: pal.colorAcento),
                      shape: const StadiumBorder(),
                      foregroundColor: pal.colorAcento,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Anterior"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirmar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pal.colorAcento,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("Confirmar"),
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
    final nombre = widget.usuarioRegistro.nombre; // Obtener del objeto completo

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorSecundario,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: pal.colorAcento, size: 48),
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
              backgroundColor: pal.colorAcento,
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
