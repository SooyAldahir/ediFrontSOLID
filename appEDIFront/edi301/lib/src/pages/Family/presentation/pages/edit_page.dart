import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edi301/src/widgets/responsive_content.dart';
import '../controllers/edit_controller.dart';

class EditPage extends StatefulWidget {
  final int familyId;
  const EditPage({super.key, required this.familyId});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EditFamilyController>().init(widget.familyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EditFamilyController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color.fromRGBO(19, 67, 107, 1),
      ),
      body: ResponsiveContent(
        child: controller.isLoading && controller.descripcionCtrl.text.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    _buildImagePicker(
                      "Foto de perfil",
                      controller.profileImage,
                      () => controller.pickImage(true),
                    ),
                    const SizedBox(height: 20),
                    _buildImagePicker(
                      "Foto de portada",
                      controller.coverImage,
                      () => controller.pickImage(false),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller.descripcionCtrl,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: "Descripción",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(19, 67, 107, 1),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: controller.isLoading
                          ? null
                          : () => _handleSave(context),
                      child: controller.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Guardar Cambios",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildImagePicker(String title, XFile? file, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextButton(onPressed: onTap, child: const Text("Editar")),
      ],
    );
  }

  void _handleSave(BuildContext context) async {
    final controller = context.read<EditFamilyController>();
    final success = await controller.saveChanges(widget.familyId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("¡Guardado exitosamente!")));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? "Error")),
      );
    }
  }
}
