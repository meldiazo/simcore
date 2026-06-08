import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/organization_position_model.dart';
import '../providers/organization_providers.dart';

class OrganizationPositionForm extends StatefulWidget {
  final String areaId;

  const OrganizationPositionForm({super.key, required this.areaId});

  @override
  State<OrganizationPositionForm> createState() => _OrganizationPositionFormState();
}

class _OrganizationPositionFormState extends State<OrganizationPositionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _respController = TextEditingController();
  final _headcountController = TextEditingController();
  final _salaryController = TextEditingController();
  final _capacityController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final provider = context.read<OrganizationProvider>();
      final newPosition = OrganizationPositionModel(
        areaId: widget.areaId,
        title: _titleController.text,
        responsibilities: _respController.text,
        headcount: int.parse(_headcountController.text),
        monthlySalary: double.parse(_salaryController.text),
        capacityPerPerson: double.parse(_capacityController.text),
      );
      
      await provider.repository.createPosition(provider.companyId, newPosition);
      
      await provider.loadOrganization(provider.summary?.projectedDemand ?? 0);
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear cargo: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Definir Nuevo Cargo'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título del Cargo (ej. Operario)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _respController,
                decoration: const InputDecoration(labelText: 'Responsabilidades', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _headcountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cantidad de Personas', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Req.' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Salario Mensual (\$)', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Req.' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacidad operativa por persona (uds/mes)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const CircularProgressIndicator() : const Text('Crear Cargo'),
        ),
      ],
    );
  }
}