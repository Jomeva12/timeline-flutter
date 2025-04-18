import 'package:flutter/material.dart';

class CrearVueloBottomSheet extends StatefulWidget {
  final void Function()? onGuardar;

  const CrearVueloBottomSheet({super.key, this.onGuardar});

  @override
  State<CrearVueloBottomSheet> createState() => _CrearVueloBottomSheetState();
}

class _CrearVueloBottomSheetState extends State<CrearVueloBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _numVueloController = TextEditingController();
  TimeOfDay? _horaLlegada;
  TimeOfDay? _horaSalida;
  String? _empresaSeleccionada;
  String? _posicionSeleccionada;
  final _focusVuelo = FocusNode();

  final _inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue[300]!, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  Future<void> _seleccionarHora(BuildContext context, bool esLlegada) async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (hora != null) {
      setState(() {
        if (esLlegada) {
          _horaLlegada = hora;
        } else {
          _horaSalida = hora;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Se eliminó el requestFocus para evitar abrir teclado automáticamente
  }

  @override
  void dispose() {
    _numVueloController.dispose();
    _focusVuelo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '✈️ Crear Vuelo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Empresa Dropdown
              DropdownButtonFormField<String>(
                decoration: _inputDecoration.copyWith(
                  labelText: 'Empresa',
                  prefixIcon: const Icon(Icons.business, color: Colors.blue),
                ),
                value: _empresaSeleccionada,
                hint: const Text('Selecciona una empresa'),
                items: ['Avianca', 'Wingo', 'AeroRepublica']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _empresaSeleccionada = value);
                },
              ),
              const SizedBox(height: 16),

              // Número de vuelo
              TextFormField(
                controller: _numVueloController,
                focusNode: _focusVuelo,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration.copyWith(
                  labelText: 'Número de vuelo',
                  prefixIcon: const Icon(Icons.flight_takeoff, color: Colors.blue),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un número de vuelo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Hora de llegada
              GestureDetector(
                onTap: () => _seleccionarHora(context, true),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: _inputDecoration.copyWith(
                      labelText: 'Hora de llegada',
                      prefixIcon: const Icon(Icons.access_time, color: Colors.blue),
                    ),
                    controller: TextEditingController(
                      text: _horaLlegada != null ? _horaLlegada!.format(context) : '',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hora de salida
              GestureDetector(
                onTap: () => _seleccionarHora(context, false),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: _inputDecoration.copyWith(
                      labelText: 'Hora de salida',
                      prefixIcon: const Icon(Icons.schedule, color: Colors.blue),
                    ),
                    controller: TextEditingController(
                      text: _horaSalida != null ? _horaSalida!.format(context) : '',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Posición Dropdown
              DropdownButtonFormField<String>(
                decoration: _inputDecoration.copyWith(
                  labelText: 'Posición',
                  prefixIcon: const Icon(Icons.place, color: Colors.blue),
                ),
                value: _posicionSeleccionada,
                hint: const Text('Selecciona una posición'),
                items: ['P1', 'P2', 'P3', 'P4', 'P5', 'P6']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _posicionSeleccionada = value);
                },
              ),
              const SizedBox(height: 32),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onGuardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
