/// Central price formatting - the app displays prices in Nepali rupees.
class Currency {
  Currency._();

  static const String symbol = 'Rs.';

  /// Formats [amount] as `Rs. 2,100` (whole rupees) or `Rs. 2,100.50`
  /// when there are paisa, with thousands separators.
  static String format(double amount) {
    final isWhole = amount == amount.roundToDouble();
    final raw = isWhole ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);

    final parts = raw.split('.');
    final digits = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
    }

    final grouped = parts.length > 1 ? '$buffer.${parts[1]}' : buffer.toString();
    return '$symbol $grouped';
  }
}
