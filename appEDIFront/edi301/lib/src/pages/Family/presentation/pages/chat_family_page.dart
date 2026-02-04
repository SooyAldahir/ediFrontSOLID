import 'dart:convert';
import 'package:edi301/src/pages/Family/data/chat_family_repository_impl.dart';
import 'package:edi301/src/pages/Family/domain/chat_family_repository.dart';
import 'package:edi301/src/pages/Family/presentation/controllers/chat_family_controller_solid.dart';
import 'package:flutter/material.dart';
import 'package:edi301/core/api_client_http.dart';

class ChatFamilyPage extends StatefulWidget {
  final int idFamilia;
  final String nombreFamilia;

  const ChatFamilyPage({
    Key? key,
    required this.idFamilia,
    required this.nombreFamilia,
  }) : super(key: key);

  @override
  _ChatFamilyPageState createState() => _ChatFamilyPageState();
}

class _ChatFamilyPageState extends State<ChatFamilyPage> {
  late final ChatFamilyControllerSolid _controller;

  @override
  void initState() {
    super.initState();

    final ChatFamilyRepository repo = ChatFamilyRepositoryImpl();
    _controller = ChatFamilyControllerSolid(repo);

    _controller.init(
      idFamilia: widget.idFamilia,
      onUpdate: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColorForName(String name) {
    final List<Color> colors = [
      Colors.red[700]!,
      Colors.pink[700]!,
      Colors.purple[700]!,
      Colors.deepPurple[700]!,
      Colors.indigo[700]!,
      Colors.blue[700]!,
      Colors.teal[700]!,
      Colors.green[700]!,
      Colors.orange[800]!,
      Colors.brown[700]!,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiHttp.baseUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreFamilia),
        backgroundColor: const Color.fromRGBO(19, 67, 107, 1),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _controller.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              itemCount: _controller.mensajes.length,
              itemBuilder: (context, index) {
                final msg = _controller.mensajes[index];
                final esMio =
                    (msg['id_usuario'] ?? 0) == _controller.miIdUsuario;
                final hora = msg['created_at'] != null
                    ? msg['created_at'].toString().substring(11, 16)
                    : '';

                final colorFondo = esMio
                    ? const Color.fromRGBO(19, 67, 107, 1)
                    : const Color.fromRGBO(245, 188, 6, 1);

                final colorTexto = esMio ? Colors.white : Colors.black87;
                final colorHora = esMio ? Colors.white70 : Colors.grey[600];

                final nombreUsuario = (msg['nombre'] ?? 'Desconocido')
                    .toString();
                final colorNombre = _getColorForName(nombreUsuario);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: esMio
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!esMio) ...[
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: (msg['foto_perfil'] != null)
                              ? NetworkImage('$baseUrl${msg['foto_perfil']}')
                              : null,
                          child: (msg['foto_perfil'] == null)
                              ? Text(
                                  nombreUsuario.isNotEmpty
                                      ? nombreUsuario[0]
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 6),
                      ],
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: colorFondo,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: esMio
                                  ? const Radius.circular(18)
                                  : const Radius.circular(2),
                              bottomRight: esMio
                                  ? const Radius.circular(2)
                                  : const Radius.circular(18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!esMio)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    nombreUsuario,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorNombre,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Text(
                                msg['mensaje']?.toString() ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: colorTexto,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  hora,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorHora,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ).withOpacity(0.1),
                  offset: const Offset(0, -2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller.textController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color.fromRGBO(19, 67, 107, 1),
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () =>
                        _controller.enviarMensaje(widget.idFamilia, () {
                          if (mounted) setState(() {});
                        }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
