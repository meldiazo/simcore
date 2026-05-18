import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core_sim_ia/core/config/environment.dart';

/// Capa central de configuración de SimCore.
/// Dictamina hacia dónde apuntan los dominios de IAM y Simulación,
/// y si la app debe usar datos estáticos o exigir conexión real.
class AppConfig {
  final Environment environment;
  final String iamUrl;
  final String simUrl;
  final bool useMockData;

  const AppConfig({
    required this.environment,
    required this.iamUrl,
    required this.simUrl,
    required this.useMockData,
  });

  /// Configuración base para el entorno de Desarrollo Local.
  factory AppConfig.dev() {
    return const AppConfig(
      environment: Environment.dev,
      iamUrl: 'http://localhost:8081',
      simUrl: 'http://localhost:8082',
      useMockData: true, // En desarrollo permitimos usar los mocks de UI temporalmente
    );
  }

  /// Configuración para pruebas integradas (QA / Docentes).
  factory AppConfig.staging() {
    return const AppConfig(
      environment: Environment.staging,
      iamUrl: 'https://iam-staging.simcore.local', 
      simUrl: 'https://sim-staging.simcore.local',
      useMockData: false, // Tensión real exigida: la API debe funcionar.
    );
  }

  /// Configuración para los servidores de Producción (Universidades).
  factory AppConfig.prod() {
    return const AppConfig(
      environment: Environment.prod,
      iamUrl: 'https://iam.simcore.com',
      simUrl: 'https://sim.simcore.com',
      useMockData: false, // Prohibido usar mocks, consecuencias reales obligatorias.
    );
  }
}

/// Proveedor inmutable de la configuración. 
/// Todas las capas de repositorios de datos y API Clients deben leer de este provider.
final appConfigProvider = Provider<AppConfig>((ref) {
  // Cambia aquí a .dev(), .staging() o .prod() según el entorno que necesites.
  return AppConfig.dev();
});