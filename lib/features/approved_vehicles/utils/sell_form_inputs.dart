import 'package:flutter/services.dart';

/// Input rules for the Approved Vehicle sell form, matching what
/// `appr-veh-submit` accepts (year 1900..next year, price > 0).
class SellFormInputs {
  SellFormInputs._();

  static const minYear = 1900;
  static int maxYear([DateTime? now]) => (now ?? DateTime.now()).year + 1;

  /// True when [value] is a 4-digit year the API accepts.
  static bool isValidYear(String value, {DateTime? now}) {
    final year = int.tryParse(value.trim());
    return year != null && year >= minYear && year <= maxYear(now);
  }

  /// True when [value] is a price above zero (up to 2 decimals).
  static bool isValidPrice(String value) {
    final v = value.trim();
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(v)) return false;
    return (double.tryParse(v) ?? 0) > 0;
  }
}

/// Rupee amount: digits with at most one decimal point and 2 decimals.
/// Commas and spaces (e.g. a pasted "1,81,000") are dropped. Anything else is
/// refused rather than stripped, so "181000.50" can never turn into 18100050.
class PriceInputFormatter extends TextInputFormatter {
  static final _allowed = RegExp(r'^\d*\.?\d{0,2}$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = newValue.text.replaceAll(RegExp(r'[,\s]'), '');
    if (!_allowed.hasMatch(cleaned)) return oldValue;
    if (cleaned == newValue.text) return newValue;
    final removed = newValue.text.length - cleaned.length;
    final offset = (newValue.selection.baseOffset - removed).clamp(0, cleaned.length);
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
