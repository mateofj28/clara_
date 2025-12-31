class CurrencyFormatter {
  /// Formatea un monto como moneda con separadores de miles
  /// Ejemplo: 1234567.89 -> "$1,234,567"
  static String format(double amount) {
    // Convertir a entero para evitar decimales
    int intAmount = amount.toInt();

    // Manejar el signo negativo
    bool isNegative = intAmount < 0;
    String numStr = intAmount.abs().toString();
    String result = '';

    // Formatear manualmente con separadores de miles
    for (int i = 0; i < numStr.length; i++) {
      if (i > 0 && (numStr.length - i) % 3 == 0) {
        result += ',';
      }
      result += numStr[i];
    }

    // Agregar el signo negativo si es necesario
    if (isNegative) {
      result = '-$result';
    }

    return '\$$result';
  }

  /// Parsea una cadena de moneda formateada a double
  /// Ejemplo: "$1,234,567" -> 1234567.0
  static double parse(String formatted) {
    final cleanText = formatted.replaceAll(',', '').replaceAll('\$', '');
    return double.tryParse(cleanText) ?? 0.0;
  }

  /// Valida si una cadena es un formato de moneda válido
  static bool isValid(String formatted) {
    final cleanText = formatted.replaceAll(',', '').replaceAll('\$', '');
    return double.tryParse(cleanText) != null;
  }
}
