import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core_sim_ia/core/config/environment.dart';

/// Capa central de configuración de SimCore.
/// Define hacia dónde apuntan los servicios de IAM y Simulación,
/// y si la app debe usar datos mock o conexión real.
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

  /// Desarrollo local.
  /// Usa esto SOLO si tienes backend corriendo localmente:
  /// IAM: http://localhost:8081
  /// SIM: http://localhost:8082
  factory AppConfig.dev() {
    return const AppConfig(
      environment: Environment.dev,
      iamUrl: 'http://localhost:8081',
      simUrl: 'http://localhost:8082',
      useMockData: true,
    );
  }

  /// Backend desplegado en Railway.
  /// Esta es la configuración que necesitas ahora para dejar de apuntar a localhost.
  factory AppConfig.railway() {
    return const AppConfig(
      environment: Environment.staging,
      iamUrl: 'https://simcore-production.up.railway.app',
      simUrl: 'https://simcore-production.up.railway.app',
      useMockData: false,
    );
  }

  /// Configuración para pruebas integradas/staging.
  /// Déjala preparada para cuando tengan dominios separados reales.
  factory AppConfig.staging() {
    return const AppConfig(
      environment: Environment.staging,
      iamUrl: 'https://simcore-production.up.railway.app',
      simUrl: 'https://simcore-production.up.railway.app',
      useMockData: false,
    );
  }

  /// Configuración para producción final.
  /// Cambiar cuando tengan dominio definitivo.
  factory AppConfig.prod() {
    return const AppConfig(
      environment: Environment.prod,
      iamUrl: 'https://simcore-production.up.railway.app',
      simUrl: 'https://simcore-production.up.railway.app',
      useMockData: false,
    );
  }
}

/// Provider global de configuración.
/// Ahora apunta a Railway, no a localhost.
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.railway();
});