import 'package:flutter/material.dart';

import '../../../models/vuelo/vuelo_import.dart';
import '../card_importaion_vuelo/card_importacion_vuelo.dart';

import 'package:flutter_slidable/flutter_slidable.dart';

class VuelosPreviewList extends StatefulWidget {
  final List<VueloImport> vuelos;
  final String Function(DateTime) formatTimeOfDay;
  final Function(List<VueloImport>) onVuelosChanged;
  const VuelosPreviewList({
    super.key,
    required this.vuelos,
    required this.formatTimeOfDay,
    required this.onVuelosChanged,
  });

  @override
  State<VuelosPreviewList> createState() => _VuelosPreviewListState();
}

class _VuelosPreviewListState extends State<VuelosPreviewList> {
  late List<VueloImport> _vuelos;

  @override
  void initState() {
    super.initState();
    _vuelos = List.from(widget.vuelos);
  }

  void _updateVuelos(List<VueloImport> newVuelos) {
    setState(() {
      _vuelos = newVuelos;
    });
    widget.onVuelosChanged(_vuelos);
  }

  void _removeVuelo(BuildContext context, int index, VueloImport vuelo) {
    _updateVuelos(_vuelos..removeAt(index));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vuelo ${vuelo.numeroVueloLlegada} eliminado'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            _updateVuelos(_vuelos..insert(index, vuelo));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _vuelos.length,
        itemBuilder: (ctx, i) {
          final v = _vuelos[i];
          return Slidable(
            key: ValueKey('${v.numeroVueloLlegada}_${v.numeroVueloSalida}_$i'),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              dismissible: DismissiblePane(
                onDismissed: () => _removeVuelo(context, i, v),
              ),
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: const Text('Confirmar eliminación'),
                          content: Text(
                              '¿Está seguro de eliminar el vuelo ${v.numeroVueloLlegada} → ${v.numeroVueloSalida}?'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      _removeVuelo(context, i, v);
                    }
                  },
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red.shade700,
                  icon: Icons.delete_outline,
                  label: 'Eliminar',
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ],
            ),
            child: _VueloPreviewCard(
              vuelo: v,
              index: i,
              total: _vuelos.length,
              formatTimeOfDay: widget.formatTimeOfDay,
            ),
          );
        },
      ),
    );
  }
}
class _VueloPreviewCard extends StatelessWidget {
  final VueloImport vuelo;
  final int index;
  final int total;
  final String Function(DateTime) formatTimeOfDay;

  const _VueloPreviewCard({
    super.key,
    required this.vuelo,
    required this.index,
    required this.total,
    required this.formatTimeOfDay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VueloPreviewHeader(
                empresaNombre: vuelo.empresaNombre,
                index: index,
                total: total,
              ),
              const Divider(height: 24),
              _VueloPreviewInfo(
                vuelo: vuelo,
                formatTimeOfDay: formatTimeOfDay,
              ),
              const Divider(height: 24),
              CardImportacionVuelo(v: vuelo),
            ],
          ),
        ),
      ),
    );
  }
}

class _VueloPreviewHeader extends StatelessWidget {
  final String? empresaNombre;
  final int index;
  final int total;

  const _VueloPreviewHeader({
    super.key,
    required this.empresaNombre,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.flight_takeoff, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Text(
              empresaNombre ?? '<pendiente>',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${index + 1}/$total',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _VueloPreviewInfo extends StatelessWidget {
  final VueloImport vuelo;
  final String Function(DateTime) formatTimeOfDay;

  const _VueloPreviewInfo({
    super.key,
    required this.vuelo,
    required this.formatTimeOfDay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoColumn(
          'Llegada',
          vuelo.numeroVueloLlegada,
          formatTimeOfDay(vuelo.horaLlegada),
          Icons.flight_land,
        ),
        Container(
          height: 40,
          width: 1,
          color: Colors.grey.shade300,
        ),
        _buildInfoColumn(
          'Salida',
          vuelo.numeroVueloSalida,
          formatTimeOfDay(vuelo.horaSalida),
          Icons.flight_takeoff,
        ),
      ],
    );
  }

  Widget _buildInfoColumn(
      String label,
      String number,
      String time,
      IconData icon,
      ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(height: 4),
          Text(
            number,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

