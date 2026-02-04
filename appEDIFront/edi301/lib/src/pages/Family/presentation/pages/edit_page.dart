import 'dart:io';
import 'package:edi301/src/pages/Family/presentation/family_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _picker = ImagePicker();
  late TextEditingController _descripcionCtrl;
  File? _selectedProfileImage;
  File? _selectedCoverImage;

  @override
  void initState() {
    super.initState();
    final family = context.read<FamilyProvider>().family;
    _descripcionCtrl = TextEditingController(text: family?.descripcion ?? '');
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isProfile) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _selectedProfileImage = File(pickedFile.path);
        } else {
          _selectedCoverImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    final success = await context.read<FamilyProvider>().updateFamilyData(
      descripcion: _descripcionCtrl.text.trim(),
      profileImage: _selectedProfileImage,
      coverImage: _selectedCoverImage,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cambios guardados con éxito!')),
      );
      Navigator.pop(context);
    } else {
      final error = context.read<FamilyProvider>().error;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'Error al guardar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FamilyProvider>();
    final family = provider.family;

    if (family == null)
      return const Scaffold(body: Center(child: Text("Error: No hay datos")));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Familia'),
        backgroundColor: const Color.fromRGBO(19, 67, 107, 1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // FOTO PORTADA
            GestureDetector(
              onTap: () => _pickImage(false),
              child: Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[300],
                child: _selectedCoverImage != null
                    ? Image.file(_selectedCoverImage!, fit: BoxFit.cover)
                    : (family.fotoPortadaUrl != null
                          ? Image.network(
                              family.fotoPortadaUrl!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.camera_alt)),
              ),
            ),
            const SizedBox(height: 20),

            // FOTO PERFIL
            GestureDetector(
              onTap: () => _pickImage(true),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _selectedProfileImage != null
                    ? FileImage(_selectedProfileImage!)
                    : (family.fotoPerfilUrl != null
                          ? NetworkImage(family.fotoPerfilUrl!) as ImageProvider
                          : null),
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _descripcionCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(19, 67, 107, 1),
                ),
                child: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Guardar',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
