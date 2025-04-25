import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vuelo/vuelo.dart';
import '../providers/empresa_provider.dart';
import '../providers/vuelo_provider.dart';

class CrearVueloBottomSheet extends StatefulWidget {
  final void Function()? onGuardar;
  final DateTime? selectedDate;
  final Vuelo? vueloExistente; // Añadir este parámetro

  const CrearVueloBottomSheet({
    super.key,
    this.onGuardar,
    this.selectedDate,
    this.vueloExistente, // Añadir este parámetro
  });

  @override
  State<CrearVueloBottomSheet> createState() => _CrearVueloBottomSheetState();
}


class _CrearVueloBottomSheetState extends State<CrearVueloBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _numVueloLlegadaController = TextEditingController();
  final _numVueloSalidaController = TextEditingController();
  final _origenController = TextEditingController();
  final _destinoController = TextEditingController();
  TimeOfDay? _horaLlegada;
  TimeOfDay? _horaSalida;
  String? _empresaSeleccionada;
  String? _empresaName;
  String? _importarVuelos;
  String? _posicionSeleccionada;
  final _focusVueloLlegada = FocusNode();
  final _focusVueloSalida = FocusNode();
final _focusOrigen = FocusNode();
  final _focusDestino = FocusNode();
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

    // Prellenar campos si existe un vuelo
    if (widget.vueloExistente != null) {
      _empresaSeleccionada = widget.vueloExistente!.empresaId;
      _empresaName = widget.vueloExistente!.empresaName;
      _numVueloLlegadaController.text = widget.vueloExistente!.numeroVueloLlegada;
      _numVueloSalidaController.text = widget.vueloExistente!.numeroVueloSalida;
      _origenController.text = widget.vueloExistente!.origen;
      _destinoController.text = widget.vueloExistente!.destino;
      _horaLlegada = TimeOfDay.fromDateTime(widget.vueloExistente!.horaLlegada);
      _horaSalida = TimeOfDay.fromDateTime(widget.vueloExistente!.horaSalida);
      _posicionSeleccionada = widget.vueloExistente!.posicion;
    }

    // Cargar las empresas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmpresaProvider>().loadEmpresas();
    });
  }

  @override
  void dispose() {
    _numVueloLlegadaController.dispose();
    _numVueloSalidaController.dispose();
    _destinoController.dispose();
    _origenController.dispose();
    _focusVueloLlegada.dispose();
    _focusVueloSalida.dispose();
     _focusOrigen.dispose();
    _focusDestino.dispose();
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
                  Text(
                    widget.vueloExistente != null ? '✈️ Editar Vuelo' : '✈️ Crear Vuelo',
                    style: const TextStyle(
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
              // Empresa Dropdown
              Consumer<EmpresaProvider>(
                builder: (context, empresaProvider, child) {
                  final empresas = empresaProvider.empresas;

                  return DropdownButtonFormField<String>(
                    decoration: _inputDecoration.copyWith(
                      labelText: 'Empresa',
                      prefixIcon: const Icon(Icons.business, color: Colors.blue),
                    ),
                    value: _empresaSeleccionada,
                    hint: const Text('Selecciona una empresa'),
                    items: empresas.map((empresa) {
                      return DropdownMenuItem(
                        value: empresa.id,  // Usamos el ID como valor
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: empresa.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(empresa.nombre),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final empresaSeleccionada = empresas.firstWhere(
                              (empresa) => empresa.id == value,
                        );
                        setState(() {
                          _empresaSeleccionada = value;
                          _empresaName = empresaSeleccionada.nombre;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona una empresa';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _numVueloLlegadaController,
                      focusNode: _focusVueloLlegada,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration.copyWith(
                        labelText: 'Vlo llegada',
                        prefixIcon: const Icon(Icons.flight_land, color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa número de llegada';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _numVueloSalidaController,
                      focusNode: _focusVueloSalida,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration.copyWith(
                        labelText: 'Vlo salida',
                        prefixIcon: const Icon(Icons.flight_takeoff, color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa número de salida';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

// 2. Fila: Origen y Destino
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _origenController,
                      focusNode: _focusOrigen,
                      decoration: _inputDecoration.copyWith(
                        labelText: 'Origen',
                        prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa origen';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _destinoController,
                      focusNode: _focusDestino,
                      decoration: _inputDecoration.copyWith(
                        labelText: 'Destino',
                        prefixIcon: const Icon(Icons.place, color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa destino';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

// 3. Fila: Hora de llegada y hora de salida
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _seleccionarHora(context, true),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: _inputDecoration.copyWith(
                            labelText: 'Hora llegada',
                            prefixIcon: const Icon(Icons.access_time, color: Colors.blue),
                          ),
                          controller: TextEditingController(
                            text: _horaLlegada != null ? _horaLlegada!.format(context) : '',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _seleccionarHora(context, false),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: _inputDecoration.copyWith(
                            labelText: 'Hora salida',
                            prefixIcon: const Icon(Icons.schedule, color: Colors.blue),
                          ),
                          controller: TextEditingController(
                            text: _horaSalida != null ? _horaSalida!.format(context) : '',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                items: ['P1', 'P2', 'P3', 'P4', 'P5', 'R6']
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        _empresaSeleccionada != null &&
                        _horaLlegada != null &&
                        _horaSalida != null &&
                        _posicionSeleccionada != null) {
                      try {
                        final vueloProvider = context.read<VueloProvider>();

                        if (widget.vueloExistente != null) {
                          // Actualizar vuelo existente
                          await vueloProvider.actualizarVuelo(
                            widget.vueloExistente!.id!,
                            _empresaSeleccionada!,
                            _empresaName!,
                            _numVueloLlegadaController.text,
                            _numVueloSalidaController.text,
                            _origenController.text,
                            _destinoController.text,
                            widget.selectedDate ?? widget.vueloExistente!.fecha,
                            _horaLlegada!,
                            _horaSalida!,
                            _posicionSeleccionada!,
                          );
                        } else {
                          // Crear nuevo vuelo
                          await vueloProvider.crearVuelo(
                            _empresaSeleccionada!,
                            _empresaName!,
                            _numVueloLlegadaController.text,
                            _numVueloSalidaController.text,
                            _origenController.text,
                            _destinoController.text,
                            widget.selectedDate ?? DateTime.now(),
                            _horaLlegada!,
                            _horaSalida!,
                            _posicionSeleccionada!,
                          );
                        }

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.vueloExistente != null
                                    ? 'Vuelo actualizado exitosamente'
                                    : 'Vuelo creado exitosamente',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error al ${widget.vueloExistente != null ? 'actualizar' : 'crear'} el vuelo: $e',
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.vueloExistente != null ? 'Actualizar' : 'Guardar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
