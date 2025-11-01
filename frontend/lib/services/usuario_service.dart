import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/config/api.dart';

class UsuarioService {
  /// Obtiene los datos del usuario actual desde la base de datos
  /// usando el uid de Firebase
  static Future<Map<String, dynamic>?> obtenerUsuarioActual() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerUsuarioActual: $e');
      return null;
    }
  }

  /// Actualiza los datos personales del usuario
  static Future<bool> actualizarDatosPersonales({
    required String nombre,
    required String apellido,
    required String documento,
    required String fechaNacimiento,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'nombre': nombre,
          'apellido': apellido,
          'documento': documento,
          'fecha_nacimiento': fechaNacimiento,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error en actualizarDatosPersonales: $e');
      return false;
    }
  }

  /// Actualiza la cobertura médica del usuario
  static Future<bool> actualizarCobertura({
    required int idObraSocial,
    required String planObraSocial,
    required String nroAfiliado,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/me/cobertura'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'id_obra_social': idObraSocial,
          'plan_obra_social': planObraSocial,
          'nro_afiliado': nroAfiliado,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error en actualizarCobertura: $e');
      return false;
    }
  }

  /// Elimina la cuenta del usuario (tanto en Firebase como en la DB)
  static Future<bool> eliminarCuenta() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final idToken = await user.getIdToken();

      // Primero eliminar de la base de datos
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Luego eliminar de Firebase
        await user.delete();
        await FirebaseAuth.instance.signOut();
        return true;
      }

      return false;
    } catch (e) {
      print('Error en eliminarCuenta: $e');
      return false;
    }
  }
}
