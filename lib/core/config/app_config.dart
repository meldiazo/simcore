import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/config/environment.dart';

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

  /// Desarrollo con backend local real.
  /// IAM: http://localhost:8081
  /// SIM: http://localhost:8082
  factory AppConfig.devLocal() {
    return const AppConfig(
      environment: Environment.dev,
      iamUrl: 'http://localhost:8081',
      simUrl: 'http://localhost:8082',
      useMockData: false,
    );
  }

  /// Desarrollo visual sin backend.
  /// Úsalo solo para pantallas demo o trabajo UI aislado.
  factory AppConfig.devMock() {
    return const AppConfig(
      environment: Environment.dev,
      iamUrl: 'http://localhost:8081',
      simUrl: 'http://localhost:8082',
      useMockData: true,
    );
  }

  /// Backend desplegado en Railway.
  /// Úsalo solo para smoke test o validación final.
  factory AppConfig.railway() {
    return const AppConfig(
      environment: Environment.staging,
      iamUrl: 'https://simcore-production.up.railway.app',
      simUrl: 'https://simcore-production.up.railway.app',
      useMockData: false,
    );
  }

  /// Producción final.
  /// Cambiar cuando exista dominio definitivo.
  factory AppConfig.prod() {
    return const AppConfig(
      environment: Environment.prod,
      iamUrl: 'https://simcore-production.up.railway.app',
      simUrl: 'https://simcore-production.up.railway.app',
      useMockData: false,
    );
  }

  /// Selección por dart-define.
  ///
  /// Ejemplos:
  /// flutter run --dart-define=APP_ENV=local
  /// flutter run --dart-define=APP_ENV=mock
  /// flutter run --dart-define=APP_ENV=railway
  factory AppConfig.fromEnvironment() {
    const forceMock =
        bool.fromEnvironment('USE_MOCK_DATA', defaultValue: false);

    if (forceMock) {
      return AppConfig.devMock();
    }

    const appEnv = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'local',
    );

    switch (appEnv) {
      case 'mock':
        return AppConfig.devMock();
      case 'railway':
        return AppConfig.railway();
      case 'prod':
        return AppConfig.prod();
      case 'local':
      default:
        return AppConfig.devLocal();
    }
  }
}

/// Provider global de configuración.
/// Por defecto usa backend local real.
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
