class FormValidators {
  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName es requerido';
    return null;
  }

  static String? minLength(String? value, int min,
      {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().length < min) {
      return '$fieldName debe tener al menos $min caracteres';
    }
    return null;
  }

  static String? positiveNumber(String? value,
      {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName es requerido';
    final n = double.tryParse(value.trim());
    if (n == null || n <= 0) return '$fieldName debe ser un número positivo';
    return null;
  }

  static String? positiveInt(String? value,
      {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName es requerido';
    final n = int.tryParse(value.trim());
    if (n == null || n <= 0) return '$fieldName debe ser un entero positivo';
    return null;
  }

  static String? combine(
      String? value, List<String? Function(String?)> validators) {
    for (final v in validators) {
      final result = v(value);
      if (result != null) return result;
    }
    return null;
  }
}
