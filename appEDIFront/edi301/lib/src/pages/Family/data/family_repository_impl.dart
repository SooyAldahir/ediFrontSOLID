import 'dart:convert';
import 'dart:io';

import 'package:edi301/auth/token_storage.dart';
import 'package:edi301/models/family_model.dart';
import 'package:edi301/services/familia_api.dart';
import 'package:edi301/services/users_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/family_repository.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  final UsersApi _usersApi;
  final FamiliaApi _familiaApi;
  final TokenStorage _tokenStorage;

  FamilyRepositoryImpl({
    UsersApi? usersApi,
    FamiliaApi? familiaApi,
    TokenStorage? tokenStorage,
  }) : _usersApi = usersApi ?? UsersApi(),
       _familiaApi = familiaApi ?? FamiliaApi(),
       _tokenStorage = tokenStorage ?? TokenStorage();

  @override
  Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr == null) return '';

    try {
      final user = jsonDecode(userStr);
      if (user is Map) {
        return (user['nombre_rol'] ?? user['rol'] ?? '').toString();
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<int?> resolveFamilyId() async {
    final cachedId = await _readFamilyIdFromSession();
    if (cachedId != null) return cachedId;
    return _fetchFamilyIdByDocument();
  }

  Future<int?> _readFamilyIdFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString('user');
    if (rawUser == null) return null;

    try {
      final dynamic decoded = jsonDecode(rawUser);
      return _extractFamilyId(decoded);
    } catch (_) {
      return null;
    }
  }

  int? _extractFamilyId(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      // buscar keys tipo id_familia, familia_id, etc.
      for (final entry in data.entries) {
        final key = entry.key.toString().toLowerCase();
        if (key.contains('familia') && key.contains('id')) {
          final parsed = _asInt(entry.value);
          if (parsed != null) return parsed;
        }
      }
      // buscar anidado
      for (final entry in data.entries) {
        final value = entry.value;
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

  Future<int?> _fetchFamilyIdByDocument() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawUser = prefs.getString('user');
      if (rawUser == null) return null;

      final Map<String, dynamic> user = Map<String, dynamic>.from(
        jsonDecode(rawUser) as Map,
      );

      final matricula = _asInt(user['matricula'] ?? user['Matricula']);
      final numEmpleado = _asInt(user['numEmpleado'] ?? user['NumEmpleado']);
      if (matricula == null && numEmpleado == null) return null;

      final familias = await _usersApi.familiasByDocumento(
        matricula: matricula,
        numEmpleado: numEmpleado,
      );
      if (familias.isEmpty) return null;

      return familias.first.id;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Family?> getFamily(int familyId) async {
    final token = await _tokenStorage.read();
    final data = await _familiaApi.getById(familyId, authToken: token);
    if (data == null) return null;
    return Family.fromJson(data);
  }

  @override
  Future<bool> updateFamily({
    required int familyId,
    String? descripcion,
    File? profileImage,
    File? coverImage,
  }) async {
    final token = await _tokenStorage.read();

    bool changed = false;

    if (descripcion != null) {
      final desc = descripcion.trim();
      if (desc.isNotEmpty) {
        final ok = await _familiaApi.updateDescripcion(
          familyId: familyId,
          descripcion: desc,
          authToken: token,
        );
        changed = changed || ok;
      }
    }

    if (profileImage != null || coverImage != null) {
      final ok = await _familiaApi.updateFamilyFotos(
        familyId: familyId,
        profileImage: profileImage,
        coverImage: coverImage,
        authToken: token,
      );
      changed = changed || ok;
    }

    return changed;
  }
}
