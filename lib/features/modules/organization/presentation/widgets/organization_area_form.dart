import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/organization_area_model.dart';
import '../providers/organization_providers.dart';

class OrganizationAreaForm extends StatefulWidget {
  const OrganizationAreaForm({super.key});

  @override
  State<OrganizationAreaForm> createState() => _OrganizationAreaFormState();
}

class _OrganizationAreaFormState extends State<OrganizationAreaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final provider = context.read<OrganizationProvider>();
      final newArea = OrganizationAreaModel(name: _nameController.text);
      
      
      await provider.repository.createArea(provider.companyId, newArea);
      
      
      await provider.loadOrganization(provider.summary?.projectedDemand ?? 0);
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear área: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Área Organizativa'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Área (ej. Producción, Ventas)',
            prefixIcon: Icon(Icons.workspaces_rounded),
          ),
          validator: (v) => v!.isEmpty ? 'Requerido' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const CircularProgressIndicator() : const Text('Crear Área'),
        ),
      ],
    );
  }
}