import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/empresa_provider.dart';
import '../../empresa/empresa.dart';
import '../vuelo.dart';

class VueloWidget extends StatelessWidget {
  final Vuelo vuelo;

  const VueloWidget({
    super.key,
    required this.vuelo,
  });

  @override
  Widget build(BuildContext context) {
    final empresaProvider = context.watch<EmpresaProvider>();

    final empresa = empresaProvider.empresas.firstWhere(
          (e) => e.id == vuelo.empresaId,
      orElse: () {
        debugPrint('⚠️ No se encontró la empresa con ID: ${vuelo.empresaId}');
        return Empresa(id: '', nombre: 'Desconocida', alias: '', color: Colors.grey);
      },
    );



    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: empresa.color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Cambiado a min para que no se expanda
          mainAxisAlignment: MainAxisAlignment.start, // Alineación al inicio
          crossAxisAlignment: CrossAxisAlignment.center, // Centrado horizontal
          children: [
            Text(
              empresa.nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1), // Reducido el espacio
            Text(
              "${vuelo.numeroVueloLlegada}-${vuelo.numeroVueloSalida}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
              ),
              textAlign: TextAlign.center, // Centrado del texto
            ),
            const SizedBox(height: 1), // Reducido el espacio
            Text(
              '${TimeOfDay.fromDateTime(vuelo.horaLlegada).format(context)}\n'
                  '${TimeOfDay.fromDateTime(vuelo.horaSalida).format(context)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
              textAlign: TextAlign.center, // Centrado del texto
            ),
          ],
        ),
      ),
    );
  }
}