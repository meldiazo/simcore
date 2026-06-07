class OrganizationPage extends StatefulWidget {
  const OrganizationPage({super.key});

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final double projectedMarketDemand = 5000.0; 
      context.read<OrganizationProvider>().loadOrganization(projectedMarketDemand);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrganizationProvider>();
    final summary = provider.summary;

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estructura Organizativa y Operaciones'),
      ),
      body: summary == null 
        ? const Center(child: Text('Error al cargar la estructura organizativa.'))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. EL PANEL DE TENSIÓN PEDAGÓGICA (Capacidad vs Demanda)
                CapacityVsDemandPanel(summary: summary),
                const SizedBox(height: 16),

                // 2. IMPACTO FINANCIERO VISIBLE
                GlassPanel(
                  child: Row(
                    children: [
                      const Icon(Icons.attach_money, color: SimcoreColors.danger),
                      const SizedBox(width: 12),
                      Text(
                        'Costo Mensual Total de Nómina: \$${summary.totalMonthlyCost.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SimcoreColors.danger),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 3. GESTIÓN DE ÁREAS Y CARGOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Diseño de Estructura',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Acción para abrir el modal OrganizationAreaForm
                        showDialog(
                          context: context,
                          builder: (_) => const OrganizationAreaForm(),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Nueva Área'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. LISTADO DE LA ESTRUCTURA (Evitando el organigrama decorativo)
                if (summary.areas.isEmpty)
                  const Center(child: Text('Aún no has definido áreas organizativas. Empieza creando una.'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: summary.areas.length,
                    itemBuilder: (context, index) {
                      final area = summary.areas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          title: Text(area.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${area.positions.length} cargos definidos'),
                          children: [
                            ...area.positions.map((pos) => ListTile(
                              title: Text(pos.title),
                              subtitle: Text('Personal: ${pos.headcount} | Salario: \$${pos.monthlySalary} | Capacidad: ${pos.capacityPerPerson} uds/persona'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // Llamada al provider para eliminar cargo
                                },
                              ),
                            )),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton.icon(
                                onPressed: () {
                                  // Acción para abrir modal OrganizationPositionForm pasando el areaId
                                  showDialog(
                                    context: context,
                                    builder: (_) => OrganizationPositionForm(areaId: area.areaId!),
                                  );
                                },
                                icon: const Icon(Icons.person_add),
                                label: const Text('Añadir Cargo a esta Área'),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 48),

                // 5. REGISTRO DE DECISIÓN
                Center(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    onPressed: provider.isCapacitySufficient 
                      ? () {
                          provider.confirmOrganizationStructure();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Estructura Organizativa registrada con éxito.')),
                          );
                        }
                      : null, // Bloqueo pedagógico si la capacidad no cubre la demanda
                    child: const Text('Confirmar y Registrar Estructura Organizativa', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}