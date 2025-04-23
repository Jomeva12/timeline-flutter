// lib/screens/empresas/empresas_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeline/screens/empresa/widgets/empresa_form.dart';
import 'package:timeline/screens/empresa/widgets/empty_state.dart';

import '../../../models/empresa/empresa.dart';
import '../../../providers/empresa_provider.dart';
import '../../../utils/notification_utils.dart';
import '../../widgets/delete_confirmation_dialog.dart';
import 'widgets/empresa_list.dart';

class EmpresasScreen extends StatefulWidget {
  const EmpresasScreen({super.key});

  @override
  State<EmpresasScreen> createState() => _EmpresasScreenState();
}

class _EmpresasScreenState extends State<EmpresasScreen> {
  late EmpresaProvider _empresaProvider;
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _aliasController = TextEditingController();
  Color _selectedColor = Colors.blue;
  bool _isEditing = false;
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _empresaProvider = Provider.of<EmpresaProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEmpresas();
    });
  }

  // Métodos de carga de datos
  Future<void> _loadEmpresas() async {
    try {
      await _empresaProvider.loadEmpresas();
    } catch (e) {
      if (mounted) {
        NotificationUtils.showErrorNotification(
          context,
          'Error al cargar las empresas',
        );
      }
    }
  }

  // Métodos de gestión del formulario
  void _mostrarFormularioEmpresa() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmpresaForm(
        formKey: _formKey,
        nombreController: _nombreController,
        aliasController: _aliasController,
        selectedColor: _selectedColor,
        isEditing: _isEditing,
        onColorChanged: (color) => setState(() => _selectedColor = color),
        onSave: _guardarEmpresa,
      ),
    );
  }

  void _limpiarFormulario() {
    setState(() {
      _nombreController.clear();
      _aliasController.clear();
      _selectedColor = Colors.blue;
      _isEditing = false;
      _editingId = null;
    });
  }

  // Métodos CRUD
  Future<void> _guardarEmpresa() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final empresa = Empresa(
          id: _editingId,
          nombre: _nombreController.text,
          alias: _aliasController.text,
          color: _selectedColor,
        );

        if (_isEditing) {
          await _empresaProvider.updateEmpresa(empresa);
          NotificationUtils.showSuccessNotification(
            context,
            'Empresa actualizada exitosamente',
          );
        } else {
          await _empresaProvider.addEmpresa(empresa);
          NotificationUtils.showSuccessNotification(
            context,
            'Empresa creada exitosamente',
          );
        }

        _limpiarFormulario();
        if (mounted) Navigator.pop(context);
      } catch (e) {
        NotificationUtils.showErrorNotification(
          context,
          'Error al guardar la empresa',
        );
      }
    }
  }

  void _editarEmpresa(Empresa empresa) {
    setState(() {
      _isEditing = true;
      _editingId = empresa.id;
      _nombreController.text = empresa.nombre;
      _aliasController.text = empresa.alias;
      _selectedColor = empresa.color;
    });
    _mostrarFormularioEmpresa();
  }

  Future<void> _eliminarEmpresa(String id, String nombreEmpresa) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteConfirmationDialog(
        empresaNombre: nombreEmpresa,
      ),
    );

    if (result == true) {
      try {
        await _empresaProvider.deleteEmpresa(id);
        if (mounted) {
          NotificationUtils.showSuccessNotification(
            context,
            'Empresa eliminada exitosamente',
          );
        }
      } catch (e) {
        if (mounted) {
          NotificationUtils.showErrorNotification(
            context,
            'Error al eliminar la empresa',
          );
        }
      }
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Empresas',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return Consumer<EmpresaProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final empresas = provider.empresas;
        return empresas.isEmpty
            ? const EmptyState()
            : EmpresaList(
          empresas: empresas,
          onEdit: _editarEmpresa,
          onDelete: _eliminarEmpresa, // El método actualizado que acepta dos parámetros
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        _limpiarFormulario();
        _mostrarFormularioEmpresa();
      },
      icon: const Icon(Icons.add_business),
      label: Text(
        'Nueva Empresa',
        style: GoogleFonts.poppins(),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _aliasController.dispose();
    super.dispose();
  }
}