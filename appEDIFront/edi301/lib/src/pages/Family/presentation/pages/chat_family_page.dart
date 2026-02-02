import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 👈 IMPORTANTE
import '../controllers/chat_family_controller.dart';

class ChatFamilyPage extends StatelessWidget {
  final int idFamilia;
  final String nombreFamilia;

  const ChatFamilyPage({
    super.key,
    required this.idFamilia,
    required this.nombreFamilia,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatFamilyController()..init(idFamilia),
      child: Scaffold(
        appBar: AppBar(
          title: Text(nombreFamilia),
          backgroundColor: const Color.fromRGBO(19, 67, 107, 1),
        ),
        body: Consumer<ChatFamilyController>(
          builder: (context, controller, _) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: controller.mensajes.length,
                    itemBuilder: (context, index) {
                      final msg = controller.mensajes[index];
                      // Aquí reutilizas tu diseño de burbujas
                      return Text(msg['mensaje'] ?? '...');
                    },
                  ),
                ),
                _buildInputArea(context, controller),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputArea(
    BuildContext context,
    ChatFamilyController controller,
  ) {
    final textCtrl = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textCtrl,
              decoration: const InputDecoration(hintText: "Escribir..."),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              controller.enviar(idFamilia, textCtrl.text);
              textCtrl.clear();
            },
          ),
        ],
      ),
    );
  }
}
