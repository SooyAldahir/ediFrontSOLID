import 'dart:async';
import 'package:flutter/material.dart';
import 'package:edi301/services/mensajes_api.dart';

class ChatFamilyController extends ChangeNotifier {
  final MensajesApi _api = MensajesApi();
  List<dynamic> mensajes = [];
  Timer? _timer;

  void init(int familyId) {
    _fetchMensajes(familyId);
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchMensajes(familyId),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMensajes(int familyId) async {
    try {
      final nuevos = await _api.getMensajesFamilia(familyId);
      mensajes = nuevos;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> enviar(int familyId, String texto) async {
    if (texto.isEmpty) return;
    await _api.enviarMensaje(familyId, texto);
    _fetchMensajes(familyId);
  }
}
