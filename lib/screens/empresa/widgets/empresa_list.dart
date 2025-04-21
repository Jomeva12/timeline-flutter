import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/empresa/empresa.dart';
// lib/screens/empresas/widgets/empresa_list.dart

class EmpresaList extends StatelessWidget {
  final List<Empresa> empresas;
  final Function(Empresa) onEdit;
  final Function(String, String) onDelete; // Modificado para aceptar también el nombre

  const EmpresaList({
    super.key,
    required this.empresas,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: empresas.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final empresa = empresas[index];
        return Animate(
          effects: const [FadeEffect(), SlideEffect()],
          child: Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => onDelete(empresa.id!, empresa.nombre), // Modificado para pasar el nombre
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Eliminar',
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () => onEdit(empresa),
                leading: CircleAvatar(
                  backgroundColor: empresa.color,
                  child: Text(
                    empresa.alias[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  empresa.nombre,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  empresa.alias,
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
                trailing: Icon(Icons.edit, color: Colors.grey[400]),
              ),
            ),
          ),
        );
      },
    );
  }
}