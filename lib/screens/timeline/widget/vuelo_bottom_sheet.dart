// vuelo_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/vuelo/vuelo.dart';
import '../../../providers/vuelo_provider.dart';
import '../../../widgets/crear_vuelo_bottomsheet.dart';

class VueloBottomSheet extends StatelessWidget {
  final Vuelo vuelo;

  const VueloBottomSheet({
    super.key,
    required this.vuelo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.flight, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Detalles del Vuelo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DetailField(
                  icon: Icons.business,
                  label: 'Empresa',
                  value: vuelo.empresaName,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DetailField(
                  icon: Icons.place,
                  label: 'Posición',
                  value: vuelo.posicion,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DetailField(
                  icon: Icons.flight_land,
                  label: 'Llegada',
                  value: '${vuelo.numeroVueloLlegada} - ${TimeOfDay.fromDateTime(vuelo.horaLlegada).format(context)}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DetailField(
                  icon: Icons.flight_takeoff,
                  label: 'Salida',
                  value: '${vuelo.numeroVueloSalida} - ${TimeOfDay.fromDateTime(vuelo.horaSalida).format(context)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar el bottomSheet actual
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: CrearVueloBottomSheet(
                          vueloExistente: vuelo,
                          selectedDate: vuelo.fecha,
                          onGuardar: () {
                            // Actualizar la vista si es necesario
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmarEliminar(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Eliminar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro que desea eliminar este vuelo?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pop(context);

              final vueloProvider = Provider.of<VueloProvider>(
                context,
                listen: false,
              );
              await vueloProvider.eliminarVuelo(vuelo.id!, vuelo.fecha);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vuelo eliminado correctamente')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.blue),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}