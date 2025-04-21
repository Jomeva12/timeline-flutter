import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class ColorPickerDialog extends StatelessWidget {
  final Color initialColor;
  final Function(Color) onColorSelected;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Seleccionar color',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorPicker(
              color: initialColor,
              onColorChanged: onColorSelected,
              width: 44,
              height: 44,
              spacing: 8,
              runSpacing: 8,
              borderRadius: 22,
              heading: Text(
                'Selecciona un color',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subheading: Text(
                'Selecciona el tono',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              wheelSubheading: Text(
                'Selecciona de la rueda de colores',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              pickersEnabled: const <ColorPickerType, bool>{
                ColorPickerType.primary: true,
                ColorPickerType.accent: true,
                ColorPickerType.wheel: true,
              },
              showColorName: true,
              showColorCode: true,
              copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                longPressMenu: true,
              ),
              enableShadesSelection: true,
              selectedColorIcon: Icons.check,
              materialNameTextStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              colorNameTextStyle: GoogleFonts.poppins(
                fontSize: 12,
              ),
              colorCodeTextStyle: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              pickerTypeLabels: const <ColorPickerType, String>{
                ColorPickerType.primary: 'Primarios',
                ColorPickerType.accent: 'Acentos',
                ColorPickerType.wheel: 'Rueda de colores',
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: GoogleFonts.poppins(),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          child: Text(
            'Aceptar',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
    );
  }
}

// Opcional: Puedes agregar una clase de estilos personalizados
class ColorPickerStyles {
  static const double borderRadius = 22.0;
  static const double spacing = 8.0;
  static const double colorSize = 44.0;

  static TextStyle get headingStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get subheadingStyle => GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.grey[600],
  );

  static TextStyle get colorNameStyle => GoogleFonts.poppins(
    fontSize: 12,
  );

  static TextStyle get colorCodeStyle => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}