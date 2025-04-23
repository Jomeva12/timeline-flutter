import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline/screens/home_screen.dart';
import '../models/vuelo/vuelo.dart';
import '../screens/empresa/empresas_screen.dart';
import 'curve_appbar_clipper.dart';

class CurvedAppBarMenu extends StatelessWidget {
  final VoidCallback? onImportExcel;
  final VoidCallback? onCrearVuelo;
 final DateTime? selectedDate;
 final List<Vuelo>? vuelos;
  const CurvedAppBarMenu({
    super.key,
    this.onImportExcel,
    this.onCrearVuelo,
     this.selectedDate,
    this.vuelos
  });
  String _getDisplayDate() {
    if (selectedDate != null) {
      return DateFormat('dd/MM/yyyy').format(selectedDate!);
    }
    return DateFormat('dd/MM/yyyy').format(DateTime.now());
  }
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
              Color(0xFF072A4E), // celeste más suave
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
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 800),
    ),
  );
},
  ),
  title: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
       Text(
        'Itineario (${vuelos!.length})',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 22,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 4), // Espacio entre los textos
      Text(
        _getDisplayDate(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    ],
  ),
  // ... resto del código
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
                  }
                  if (value == 'crear_vuelo') {
                    onCrearVuelo?.call();
                  }
                  if (value == 'empresa') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EmpresasScreen()),
                    );
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
                    child: Text('🏢 Empresa', style: TextStyle(fontSize: 14)),
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
