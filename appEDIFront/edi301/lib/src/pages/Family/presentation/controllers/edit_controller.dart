import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/family_repository.dart';

class EditFamilyController extends ChangeNotifier {
  final FamilyRepository _repository;
  final ImagePicker _picker = ImagePicker();

  EditFamilyController(this._repository);

  bool isLoading = false;
  String? errorMessage;

  final TextEditingController descripcionCtrl = TextEditingController();
  XFile? profileImage;
  XFile? coverImage;

  Future<void> init(int familyId) async {
    isLoading = true;
    notifyListeners();
    try {
      final family = await _repository.getFamilyById(familyId);
      if (family != null) {
        descripcionCtrl.text = family.descripcion ?? '';
      }
    } catch (e) {
      errorMessage = "Error cargando datos: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage(bool isProfile) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (isProfile)
        profileImage = picked;
      else
        coverImage = picked;
      notifyListeners();
    }
  }

  Future<bool> saveChanges(int familyId) async {
    if (isLoading) return false;
    isLoading = true;
    notifyListeners();

    try {
      if (descripcionCtrl.text.isNotEmpty) {
        await _repository.updateDescripcion(
          familyId,
          descripcionCtrl.text.trim(),
        );
      }
      if (profileImage != null || coverImage != null) {
        File? pFile = profileImage != null ? File(profileImage!.path) : null;
        File? cFile = coverImage != null ? File(coverImage!.path) : null;
        await _repository.updateFotos(familyId, pFile, cFile);
      }
      return true;
    } catch (e) {
      errorMessage = "Error al guardar: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    descripcionCtrl.dispose();
    super.dispose();
  }
}
