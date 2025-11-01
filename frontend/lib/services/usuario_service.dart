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
  /// Devuelve un Map con 'success' (bool) y 'message' (String?)
  static Future<Map<String, dynamic>> actualizarDatosPersonales({
    required String nombre,
    required String apellido,
    required String documento,
    required String fechaNacimiento,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'No hay usuario autenticado'};
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

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        // Intentar extraer el mensaje de error del backend
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['detail'] ?? 'Error al guardar los datos';
          return {'success': false, 'message': errorMessage};
        } catch (_) {
          return {'success': false, 'message': 'Error al guardar los datos'};
        }
      }
    } catch (e) {
      print('Error en actualizarDatosPersonales: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
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

  /// Elimina la cuenta del usuario (marca como inactivo en DB, cancela turnos y elimina de Firebase)
  /// El backend se encarga de todo: marcar inactivo, cancelar turnos y eliminar de Firebase
  static Future<bool> eliminarCuenta() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final idToken = await user.getIdToken();

      // El backend se encarga de:
      // 1. Marcar usuario como inactivo (soft delete)
      // 2. Cancelar todos los turnos activos del usuario
      // 3. Eliminar la cuenta de Firebase Authentication
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Solo cerrar sesión localmente (el backend ya eliminó de Firebase)
        await FirebaseAuth.instance.signOut();
        return true;
      }

      return false;
    } catch (e) {
      print('Error en eliminarCuenta: $e');
      return false;
    }
  }

  /// Obtiene la lista de todas las obras sociales disponibles
  static Future<List<Map<String, dynamic>>> obtenerObrasSociales() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/obras-sociales/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Error al obtener obras sociales: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerObrasSociales: $e');
      return [];
    }
  }
}
