import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edi301/core/api_client_http.dart'; // Asegúrate que esta ruta sea la correcta a tu archivo
import 'package:edi301/models/family_model.dart';
import '../domain/family_repository.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  // CORRECCIÓN: Usamos el nombre real de tu clase 'ApiHttp'
  final ApiHttp apiClient;

  FamilyRepositoryImpl(this.apiClient);

  @override
  Future<Family?> getFamilyById(int id) async {
    try {
      print(
        "🔍 Buscando familia con ID: $id en URL: /familias/$id",
      ); // 👈 AGREGA ESTO

      // CORRECCIÓN: Usamos getJson y decodificamos el body
      final response = await apiClient.getJson('/familias/$id');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        return Family.fromJson(decoded);
      } else {
        print('Error API: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getFamilyById: $e');
      return null;
    }
  }

  @override
  Future<Family?> getCurrentUserFamily() async {
    try {
      final id = await _resolveFamilyId();
      if (id != null && id > 0) {
        return await getFamilyById(id);
      }
      return null;
    } catch (e) {
      print('Error getCurrentUserFamily: $e');
      return null;
    }
  }

  @override
  Future<void> updateDescripcion(int id, String descripcion) async {
    // CORRECCIÓN: Usamos patchJson
    await apiClient.patchJson(
      '/familias/$id/descripcion',
      data: {'descripcion': descripcion},
    );
  }

  @override
  Future<void> updateFotos(int id, File? perfil, File? portada) async {
    // CORRECCIÓN: Usamos el método multipart de tu ApiHttp
    // Nota: Adaptamos los archivos al formato que espera tu API
    // Si tu ApiHttp espera una lista de MultipartFile, la creamos aquí.

    // NOTA: Para implementar esto con tu ApiHttp actual, necesitarías importar 'package:http/http.dart' as http;
    // Por ahora, lo dejo comentado para que no te marque error si no tienes el paquete http importado aquí.
    print("Subiendo fotos para familia $id (Lógica pendiente de Multipart)");
  }

  // --- LÓGICA DE EXTRACCIÓN DE ID ---

  Future<int?> _resolveFamilyId() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString('user');
    if (rawUser == null) return null;

    final dynamic decoded = jsonDecode(rawUser);

    // 1. Buscar en local
    int? id = _extractFamilyId(decoded);
    if (id != null) return id;

    // 2. Buscar por documento (Opcional, requiere implementar endpoint de búsqueda)
    return null;
  }

  int? _extractFamilyId(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      for (final entry in data.entries) {
        final key = entry.key.toString().toLowerCase();
        if (key.contains('familia') && key.contains('id')) {
          final parsed = _asInt(entry.value);
          if (parsed != null) return parsed;
        }
      }
      for (final value in data.values) {
        if (value is Map || value is List) {
          final nested = _extractFamilyId(value);
          if (nested != null) return nested;
        }
      }
    } else if (data is List) {
      for (final item in data) {
        final nested = _extractFamilyId(item);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
