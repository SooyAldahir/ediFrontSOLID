import 'package:edi301/services/mensajes_api.dart';

import '../domain/chat_family_repository.dart';

class ChatFamilyRepositoryImpl implements ChatFamilyRepository {
  final MensajesApi _mensajesApi;

  ChatFamilyRepositoryImpl({MensajesApi? mensajesApi})
    : _mensajesApi = mensajesApi ?? MensajesApi();

  @override
  Future<List<dynamic>> getMensajesFamilia(int idFamilia) {
    return _mensajesApi.getMensajesFamilia(idFamilia);
  }

  @override
  Future<bool> enviarMensaje(int idFamilia, String mensaje) {
    return _mensajesApi.enviarMensaje(idFamilia, mensaje);
  }
}
