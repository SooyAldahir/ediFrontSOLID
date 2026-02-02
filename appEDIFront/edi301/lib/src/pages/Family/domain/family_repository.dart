import 'dart:io';
import 'package:edi301/models/family_model.dart';

abstract class FamilyRepository {
  // Obtiene la familia por ID específico
  Future<Family?> getFamilyById(int id);

  // Obtiene la familia del usuario logueado
  Future<Family?> getCurrentUserFamily();

  // Actualizaciones
  Future<void> updateDescripcion(int id, String descripcion);
  Future<void> updateFotos(int id, File? perfil, File? portada);
}
