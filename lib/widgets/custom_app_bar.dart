import 'package:flutter/material.dart';
import 'curve_appbar_clipper.dart';

class CurvedAppBarMenu extends StatelessWidget {
  final VoidCallback? onImportExcel;
  final VoidCallback? onCrearVuelo;

  const CurvedAppBarMenu({
    super.key,
    this.onImportExcel,
    this.onCrearVuelo,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CurvedAppBarClipper(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4A90E2), // azul pastel
              Color(0xFF6EB5FF), // celeste más suave
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black38, offset: Offset(0, 4), blurRadius: 10),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Timeline Diarios',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: PopupMenuButton<String>(
                color: Colors.white,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'importar_excel') {
                    onImportExcel?.call();
                  } else if (value == 'crear_vuelo') {
                    onCrearVuelo?.call();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    
                    value: 'importar_excel',
                    child: Text('📥 Importar Excel', style: TextStyle(fontSize: 14)),
                  ),
                  const PopupMenuItem(
                    value: 'crear_vuelo',
                    child: Text('✈️ Crear Vuelo', style: TextStyle(fontSize: 14)),
                  ),
                  PopupMenuItem(
                    value: 'empresa',
                    child: Text('✈️ Empresas', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
