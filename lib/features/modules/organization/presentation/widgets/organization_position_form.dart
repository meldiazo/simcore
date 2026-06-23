import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                decoration: const InputDecoration(
                  labelText: 'Título del Cargo (ej. Operario)',
                  prefixIcon: Icon(Icons.work_outline_rounded),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _respController,
                decoration: const InputDecoration(
                  labelText: 'Responsabilidades',
                  prefixIcon: Icon(Icons.assignment_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _headcountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Cantidad de Personas',
                        prefixIcon: Icon(Icons.people_alt_rounded),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Req.';
                        final val = int.tryParse(v);
                        if (val == null || val <= 0) return 'Mín. 1';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _salaryController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      decoration: const InputDecoration(
                        labelText: 'Salario Mensual',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Req.';
                        final val = double.tryParse(v);
                        if (val == null || val <= 0) return 'Mín. 0.01';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                decoration: const InputDecoration(
                  labelText: 'Capacidad operativa por persona (uds/mes)',
                  prefixIcon: Icon(Icons.speed_rounded),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  final val = double.tryParse(v);
                  if (val == null || val < 0) return 'Mín. 0';
                  return null;
                },
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