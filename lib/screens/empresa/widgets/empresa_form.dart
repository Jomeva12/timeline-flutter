import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_picker_dialog.dart';

class EmpresaForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController aliasController;
  final Color selectedColor;
  final bool isEditing;
  final Function(Color) onColorChanged;
  final VoidCallback onSave;

  const EmpresaForm({
    super.key,
    required this.formKey,
    required this.nombreController,
    required this.aliasController,
    required this.selectedColor,
    required this.isEditing,
    required this.onColorChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildNombreField(),
            const SizedBox(height: 16),
            _buildAliasField(),
            const SizedBox(height: 20),
            _buildColorSection(context),
            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isEditing ? 'Editar Empresa' : 'Nueva Empresa',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildNombreField() {
    return TextFormField(
      controller: nombreController,
      decoration: InputDecoration(
        labelText: 'Nombre',
        hintText: 'Ingrese el nombre de la empresa',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.business),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Por favor ingrese un nombre';
        }
        return null;
      },
    );
  }

  Widget _buildAliasField() {
    return TextFormField(
      controller: aliasController,
      decoration: InputDecoration(
        labelText: 'Alias',
        hintText: 'Ingrese un alias corto',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.short_text),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Por favor ingrese un alias';
        }
        return null;
      },
    );
  }

  Widget _buildColorSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color de la empresa',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showColorPicker(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Toca para cambiar el color',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(Icons.colorize, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onSave,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          isEditing ? 'Actualizar Empresa' : 'Guardar Empresa',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: selectedColor,
        onColorSelected: onColorChanged,
      ),
    );
  }
}