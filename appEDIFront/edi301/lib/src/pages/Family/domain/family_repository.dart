import 'dart:io';
import 'package:edi301/models/family_model.dart';

abstract class FamilyRepository {
  Future<int?> resolveFamilyId();
  Future<String> getUserRole();

  Future<Family?> getFamily(int familyId);

  Future<bool> updateFamily({
    required int familyId,
    String? descripcion,
    File? profileImage,
    File? coverImage,
  });
}
