/// Define los entornos de ejecución para SimCore.
enum Environment {
  dev,
  staging,
  prod;

  /// Helpers convenientes para validar el entorno actual en la lógica de negocio.
  bool get isDev => this == Environment.dev;
  bool get isStaging => this == Environment.staging;
  bool get isProd => this == Environment.prod;
}
