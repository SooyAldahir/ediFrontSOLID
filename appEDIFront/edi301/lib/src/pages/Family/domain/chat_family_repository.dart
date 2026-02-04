abstract class ChatFamilyRepository {
  Future<List<dynamic>> getMensajesFamilia(int idFamilia);
  Future<bool> enviarMensaje(int idFamilia, String mensaje);
}
