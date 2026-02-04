import 'package:edi301/models/family_model.dart';
import 'package:edi301/src/pages/Family/domain/family_repository.dart';

class FamilyControllerSolid {
  final FamilyRepository _repo;

  FamilyControllerSolid(this._repo);

  Future<int?> resolveFamilyId() => _repo.resolveFamilyId();

  Future<String> loadUserRole() => _repo.getUserRole();

  Future<Family?> loadFamily() async {
    final id = await _repo.resolveFamilyId();
    if (id == null || id <= 0) return null;
    return _repo.getFamily(id);
  }
}
