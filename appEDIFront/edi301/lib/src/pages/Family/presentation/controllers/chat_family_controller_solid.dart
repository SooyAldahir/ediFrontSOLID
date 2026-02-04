import 'dart:async';
import 'dart:convert';

import 'package:edi301/src/pages/Family/domain/chat_family_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatFamilyControllerSolid {
  final ChatFamilyRepository _repo;

  ChatFamilyControllerSolid(this._repo);

  int miIdUsuario = 0;
  List<dynamic> mensajes = [];
  Timer? timer;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Future<void> init({
    required int idFamilia,
    required VoidCallback onUpdate,
  }) async {
    await _loadCurrentUserId();
    await cargarMensajes(idFamilia, onUpdate);

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await cargarMensajes(idFamilia, onUpdate);
    });
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString('user');
    if (rawUser == null) return;

    try {
      final decoded = jsonDecode(rawUser);
      if (decoded is Map) {
        miIdUsuario = (decoded['id_usuario'] ?? 0) is int
            ? (decoded['id_usuario'] ?? 0)
            : int.tryParse((decoded['id_usuario'] ?? '0').toString()) ?? 0;
      }
    } catch (_) {}
  }

  Future<void> cargarMensajes(int idFamilia, VoidCallback onUpdate) async {
    mensajes = await _repo.getMensajesFamilia(idFamilia);
    onUpdate();
    _scrollToBottom();
  }

  Future<void> enviarMensaje(int idFamilia, VoidCallback onUpdate) async {
    final texto = textController.text.trim();
    if (texto.isEmpty) return;

    final ok = await _repo.enviarMensaje(idFamilia, texto);
    if (ok) {
      textController.clear();
      await cargarMensajes(idFamilia, onUpdate);
    }
  }

  void _scrollToBottom() {
    if (!scrollController.hasClients) return;
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void dispose() {
    timer?.cancel();
    textController.dispose();
    scrollController.dispose();
  }
}
