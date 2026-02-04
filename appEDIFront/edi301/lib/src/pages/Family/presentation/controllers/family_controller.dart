import 'package:edi301/models/family_model.dart';
import 'package:edi301/src/pages/Family/data/family_repository_impl.dart';
import 'package:edi301/src/pages/Family/domain/family_repository.dart';
import 'package:edi301/src/pages/Family/presentation/controllers/family_controller_solid.dart';

class FamilyController {
  late final FamilyControllerSolid _controller;

  FamilyController({FamilyRepository? repository}) {
    _controller = FamilyControllerSolid(repository ?? FamilyRepositoryImpl());
  }

  Future<int?> resolveFamilyId() => _controller.resolveFamilyId();

  Future<String> loadUserRole() => _controller.loadUserRole();

  Future<Family?> loadFamily() => _controller.loadFamily();
}
