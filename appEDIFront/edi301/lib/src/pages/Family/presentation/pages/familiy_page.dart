import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edi301/core/api_client_http.dart';
import 'package:edi301/models/family_model.dart'; // Asegúrate de importar tu modelo
import 'package:edi301/src/widgets/responsive_content.dart';
import 'package:edi301/src/widgets/family_gallery.dart';
import '../controllers/family_controller.dart';
import 'chat_family_page.dart';

class FamiliyPage extends StatefulWidget {
  const FamiliyPage({super.key});

  @override
  State<FamiliyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamiliyPage> {
  bool mostrarHijos = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<FamilyController>();
      controller.loadData();
      _loadUserRole(controller);
    });
  }

  Future<void> _loadUserRole(FamilyController controller) async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      final user = jsonDecode(userStr);
      controller.setUserRole(user['nombre_rol'] ?? user['rol'] ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FamilyController>();
    final family = controller.family;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(19, 67, 107, 1),
        title: const Text("Mi Familia", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButton: controller.hasFamily
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatFamilyPage(
                      idFamilia: family!.id!,
                      nombreFamilia: family.familyName,
                    ),
                  ),
                );
              },
              backgroundColor: const Color.fromRGBO(245, 188, 6, 1),
              child: const Icon(Icons.chat, color: Colors.black),
            )
          : null,
      body: ResponsiveContent(
        child: Builder(
          builder: (context) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.errorMessage != null) {
              return Center(child: Text(controller.errorMessage!));
            }
            if (!controller.hasFamily) {
              return const Center(child: Text("Sin Asignación Familiar"));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                    child: FamilyWidget(
                      backgroundImage: _getImageProvider(
                        family!.fotoPortadaUrl,
                      ),
                      circleImage: _getImageProvider(family.fotoPerfilUrl),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FamilyData(
                      familyName: family.familyName,
                      numChildres:
                          (family.householdChildren.length +
                                  family.assignedStudents.length)
                              .toString(),
                      text: 'Hijos EDI',
                      description:
                          family.descripcion ??
                          'Añade una descripción en "Editar Perfil".',
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (![
                    'Hijo',
                    'HijoEDI',
                    'ALUMNO',
                    'Estudiante',
                  ].contains(controller.userRole))
                    _buildEditButton(context, family.id!),

                  const SizedBox(height: 10),
                  _buildToggleButtons(),
                  const SizedBox(height: 10),

                  mostrarHijos
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _buildHijosList(family),
                        )
                      : FamilyGallery(idFamilia: family.id ?? 0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, int familyId) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            'edit',
            arguments: familyId,
          );
          if (result == true && mounted) {
            context.read<FamilyController>().loadData();
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: const Color.fromRGBO(245, 188, 6, 1),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'Editar Perfil',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildToggleButton('Mis hijos EDI', mostrarHijos, () {
          setState(() => mostrarHijos = true);
        }),
        const SizedBox(width: 10),
        _buildToggleButton('Fotos', !mostrarHijos, () {
          setState(() => mostrarHijos = false);
        }),
      ],
    );
  }

  Widget _buildToggleButton(
    String text,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color.fromARGB(190, 245, 189, 6)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        text,
        style: TextStyle(color: isSelected ? Colors.black : Colors.black),
      ),
    );
  }

  Widget _buildHijosList(Family family) {
    final hijos = [...family.householdChildren, ...family.assignedStudents];
    if (hijos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No hay hijos EDI registrados.'),
        ),
      );
    }
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: hijos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final hijo = hijos[index];
        return ProfileCard(
          imageUrl: 'https://cdn-icons-png.flaticon.com/512/7141/7141724.png',
          name: hijo.fullName,
          school: hijo.carrera,
          fechaNacimiento: hijo.fechaNacimiento,
          phoneNumber: hijo.telefono,
          onTap: () {}, // Navegación a detalle alumno
          onChat: () {}, // Iniciar chat privado
        );
      },
    );
  }

  ImageProvider _getImageProvider(String? url) {
    if (url != null && url.isNotEmpty) {
      return NetworkImage('${ApiHttp.serverUrl}$url');
    }
    return const AssetImage('assets/img/familia-extensa-e1591818033557.jpg');
  }
}

// ... (Incluye aquí las clases FamilyWidget, FamilyData y ProfileCard si no las tienes en archivos separados) ...
class FamilyWidget extends StatelessWidget {
  final ImageProvider backgroundImage;
  final ImageProvider circleImage;
  final VoidCallback onTap;
  const FamilyWidget({
    super.key,
    required this.backgroundImage,
    required this.circleImage,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image(
          image: backgroundImage,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: CircleAvatar(radius: 50, backgroundImage: circleImage),
        ),
      ],
    );
  }
}

class FamilyData extends StatelessWidget {
  final String familyName, numChildres, text, description;
  const FamilyData({
    super.key,
    required this.familyName,
    required this.numChildres,
    required this.text,
    required this.description,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          familyName,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        Text("$numChildres $text"),
        Text(description),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String imageUrl, name;
  final String? school, fechaNacimiento, phoneNumber;
  final VoidCallback? onTap, onChat;
  const ProfileCard({
    super.key,
    required this.imageUrl,
    required this.name,
    this.school,
    this.fechaNacimiento,
    this.phoneNumber,
    this.onTap,
    this.onChat,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
      title: Text(name),
      subtitle: Text(school ?? ''),
      onTap: onTap,
    );
  }
}
