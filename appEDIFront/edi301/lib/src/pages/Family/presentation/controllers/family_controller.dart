import 'package:flutter/material.dart';
import 'package:edi301/models/family_model.dart';
import '../../domain/family_repository.dart';

class FamilyController extends ChangeNotifier {
  final FamilyRepository _repository;

  FamilyController(this._repository);

  Family? family;
  bool isLoading = false;
  String? errorMessage;
  String userRole = '';

  bool get hasFamily => family != null;

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      family = await _repository.getCurrentUserFamily();
      if (family == null) {
        errorMessage = "No se pudo identificar la familia.";
      }
    } catch (e) {
      errorMessage = "Error: $e";
      family = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setUserRole(String role) {
    userRole = role;
    notifyListeners();
  }
}
