import 'dart:async';

import 'package:core_sim_ia/app/theme/app_theme.dart';
import 'package:core_sim_ia/features/shared/data/demo/simcore_demo_data.dart';
import 'package:core_sim_ia/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DecisionsPage extends StatefulWidget {
  const DecisionsPage({super.key});

  @override
  State<DecisionsPage> createState() => _DecisionsPageState();
}

class _DecisionsPageState extends State<DecisionsPage> {
  static const _auditSteps = [
    'Inicializando sandbox cuantico...',
    'Cruzando elasticidad de Precio vs Marketing...',
    'Verificando capacidad operativa...',
    'Calculando riesgo de liquidez y tesoreria...',
    'Simulacion Montecarlo completada.',
  ];

  int currentTab = 0;
  bool isAuditing = false;
  bool auditComplete = false;
  bool isSubmitted = false;
  int auditStep = 0;
  double signProgress = 0;
  Timer? _auditTimer;
  Timer? _signTimer;

  @override
  void dispose() {
    _auditTimer?.cancel();
    _signTimer?.cancel();
    super.dispose();
  }

  void _runAudit() {
    setState(() {
      isAuditing = true;
      auditComplete = false;
      auditStep = 0;
    });

    _auditTimer?.cancel();
    _auditTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (auditStep >= _auditSteps.length - 1) {
        timer.cancel();
        setState(() {
          isAuditing = false;
          auditComplete = true;
          currentTab = 2;
        });
      } else {
        setState(() => auditStep += 1);
      }
    });
  }

  void _startSigning() {
    if (isSubmitted) {
      return;
    }
    _signTimer?.cancel();
    _signTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      setState(() {
        signProgress += 2;
        if (signProgress >= 100) {
          signProgress = 100;
          isSubmitted = true;
          timer.cancel();
        }
      });
    });
  }

  void _stopSigning() {
    _signTimer?.cancel();
    if (!isSubmitted) {
      setState(() => signProgress = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      ('1. Chequeo de Borradores', Icons.shield_outlined),
      ('2. Auditoria Pre-Vuelo', Icons.smart_toy_outlined),
      ('3. Firma Ejecutiva', Icons.fingerprint_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          title: 'Centro de Decisiones',
          subtitle:
              'Revision final, auditoria algoritmica y firma de la estrategia del Ciclo 03.',
          trailing: GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.hub_rounded, color: SimcoreColors.success),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Servidor de Simulacion',
                        style: TextStyle(
                            fontSize: 11, color: SimcoreColors.textTertiary)),
                    Text('ONLINE',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: SimcoreColors.success)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        LayoutBuilder(builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 520;
          final tabItems = List.generate(tabs.length, (index) {
            final active = index == currentTab;
            final completed =
                index < currentTab || (index == 1 && auditComplete);
            final item = InkWell(
              onTap:
                  isSubmitted ? null : () => setState(() => currentTab = index),
              child: isCompact
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            active ? SimcoreColors.accentSoft : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: SimcoreColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: completed
                                ? SimcoreColors.success
                                : active
                                    ? SimcoreColors.accent
                                    : SimcoreColors.surface,
                            child: Icon(
                              completed ? Icons.check_rounded : tabs[index].$2,
                              size: 18,
                              color: completed || active
                                  ? Colors.white
                                  : SimcoreColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tabs[index].$1,
                              softWrap: true,
                              style: TextStyle(
                                fontWeight:
                                    active ? FontWeight.w700 : FontWeight.w500,
                                color: active
                                    ? SimcoreColors.textPrimary
                                    : SimcoreColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: completed
                              ? SimcoreColors.success
                              : active
                                  ? SimcoreColors.accent
                                  : SimcoreColors.surface,
                          child: Icon(
                            completed ? Icons.check_rounded : tabs[index].$2,
                            color: completed || active
                                ? Colors.white
                                : SimcoreColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          tabs[index].$1,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            color: active
                                ? SimcoreColors.textPrimary
                                : SimcoreColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
            );

            return isCompact ? item : Expanded(child: item);
          });

          if (isCompact) {
            return Column(
              children: tabItems
                  .expand((child) => [child, const SizedBox(height: 8)])
                  .take(tabItems.length * 2 - 1)
                  .toList(growable: false),
            );
          }

          return Row(children: tabItems);
        }),
        const SizedBox(height: 24),
        if (currentTab == 0)
          _ReviewTab(onContinue: () => setState(() => currentTab = 1)),
        if (currentTab == 1)
          _AuditTab(
            isAuditing: isAuditing,
            auditComplete: auditComplete,
            auditStep: auditStep,
            stepLabel: _auditSteps[auditStep],
            onStart: _runAudit,
            onContinue: () => setState(() => currentTab = 2),
          ),
        if (currentTab == 2)
          _SignTab(
            signProgress: signProgress,
            isSubmitted: isSubmitted,
            onStart: _startSigning,
            onStop: _stopSigning,
          ),
      ],
    );
  }
}

class _ReviewTab extends StatelessWidget {
  const _ReviewTab({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponsiveWrap(
          children: decisionModules.map((module) {
            return GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(module.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                      StatusBadge(status: module.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...module.summary.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(item),
                      )),
                ],
              ),
            );
          }).toList(growable: false),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Proceder a Auditoria Cuantica'),
          ),
        ),
      ],
    );
  }
}

class _AuditTab extends StatelessWidget {
  const _AuditTab({
    required this.isAuditing,
    required this.auditComplete,
    required this.auditStep,
    required this.stepLabel,
    required this.onStart,
    required this.onContinue,
  });

  final bool isAuditing;
  final bool auditComplete;
  final int auditStep;
  final String stepLabel;
  final VoidCallback onStart;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: GlassPanel(
          padding: const EdgeInsets.all(36),
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [SimcoreColors.accentSoft, Colors.white]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.smart_toy_outlined,
                    color: SimcoreColors.accent, size: 42),
              ),
              const SizedBox(height: 20),
              const Text('Sandbox de Validacion',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              const Text(
                'La IA integrara las metricas de tus cuatro dimensiones de decision y simulara escenarios de estres para buscar fisuras financieras u operativas.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: SimcoreColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 30),
              if (!isAuditing && !auditComplete)
                FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Iniciar Escaneo Algoritmico'),
                ),
              if (isAuditing) ...[
                CircularProgressIndicator(value: (auditStep + 1) / 5),
                const SizedBox(height: 18),
                Text(stepLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
              if (auditComplete) ...[
                const Icon(Icons.verified_rounded,
                    color: SimcoreColors.success, size: 44),
                const SizedBox(height: 12),
                const Text('Auditoria completada sin bloqueos criticos.',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Continuar a Firma Ejecutiva'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SignTab extends StatelessWidget {
  const _SignTab({
    required this.signProgress,
    required this.isSubmitted,
    required this.onStart,
    required this.onStop,
  });

  final double signProgress;
  final bool isSubmitted;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: GlassPanel(
          padding: const EdgeInsets.all(36),
          child: Column(
            children: [
              Text(
                isSubmitted
                    ? 'Estrategia enviada'
                    : 'Mantener presionado para firmar',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                isSubmitted
                    ? 'Las decisiones quedaron bloqueadas y listas para ser procesadas por el motor de simulacion.'
                    : 'La firma ejecutiva sella la estrategia consolidada y bloquea cambios en todos los modulos.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onLongPressStart: (_) => onStart(),
                onLongPressEnd: (_) => onStop(),
                child: Container(
                  width: double.infinity,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: SimcoreColors.textPrimary,
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: signProgress / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: isSubmitted
                                ? SimcoreColors.success
                                : SimcoreColors.accent,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          isSubmitted
                              ? 'Firmado y enviado'
                              : 'Mantener para firmar',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isSubmitted
                    ? '100% completado'
                    : '${signProgress.toInt()}% de firma',
                style: const TextStyle(color: SimcoreColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
