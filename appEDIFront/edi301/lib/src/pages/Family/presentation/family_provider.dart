import 'dart:io';
import 'package:edi301/src/pages/Family/domain/family_repository.dart';
import 'package:flutter/material.dart';
import 'package:edi301/models/family_model.dart';

class FamilyProvider extends ChangeNotifier {
  final FamilyRepository repository;

  FamilyProvider(this.repository);

  Family? _family;
  bool _isLoading = false;
  String? _error;

  Family? get family => _family;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFamily() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await repository.resolveFamilyId();
      if (id == null || id <= 0) {
        _family = null;
        _error = "No se pudo identificar la familia del usuario";
      } else {
        _family = await repository.getFamily(id);
      }
    } catch (e) {
      _error = e.toString();
      _family = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateFamilyData({
    String? descripcion,
    File? profileImage,
    File? coverImage,
  }) async {
    // CORRECCIÓN: Usamos .id porque así se llama en tu modelo Family
    if (_family == null || _family!.id == null) {
      _error = "No se puede editar: Familia no cargada";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await repository.updateFamily(
        familyId: _family!.id!,
        descripcion: descripcion,
        profileImage: profileImage,
        coverImage: coverImage,
      );

      // Recargar datos
      await loadFamily();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
