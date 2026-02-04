import 'dart:io';
import 'package:flutter/material.dart';
import 'package:edi301/src/pages/Family/domain/family_repository.dart';

class EditFamilyController extends ChangeNotifier {
  final FamilyRepository repository;

  EditFamilyController(this.repository);

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> saveChanges({
    required int familyId,
    String? descripcion,
    File? profileImage,
    File? coverImage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.updateFamily(
        familyId: familyId,
        descripcion: descripcion,
        profileImage: profileImage,
        coverImage: coverImage,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
