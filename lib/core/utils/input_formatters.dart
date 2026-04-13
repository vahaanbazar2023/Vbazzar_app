import 'package:flutter/services.dart';

/// Custom input formatter that allows only numeric characters
/// Use for number-only fields
class NumericOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Allow only digits
    if (RegExp(r'^[0-9]+$').hasMatch(newValue.text)) {
      return newValue;
    }

    // Return old value if new value contains non-numeric characters
    return oldValue;
  }
}

/// Custom input formatter that allows only alphabetic characters (text only)
/// Use for name fields, etc.
class AlphabeticOnlyFormatter extends TextInputFormatter {
  /// Whether to allow spaces between words
  final bool allowSpaces;

  AlphabeticOnlyFormatter({this.allowSpaces = true});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Allow only letters and optionally spaces
    final pattern = allowSpaces ? r'^[a-zA-Z ]+$' : r'^[a-zA-Z]+$';
    if (RegExp(pattern).hasMatch(newValue.text)) {
      return newValue;
    }

    // Return old value if new value contains invalid characters
    return oldValue;
  }
}

/// Custom input formatter for phone numbers
/// Restricts input to exactly 10 digits
class PhoneNumberFormatter extends TextInputFormatter {
  /// Maximum length for phone number (default: 10)
  final int maxLength;

  PhoneNumberFormatter({this.maxLength = 10});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty value
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Only allow numeric characters
    if (!RegExp(r'^[0-9]+$').hasMatch(newValue.text)) {
      return oldValue;
    }

    // Restrict to max length
    if (newValue.text.length > maxLength) {
      return oldValue;
    }

    return newValue;
  }
}

/// Custom input formatter for alphanumeric characters only
/// Use for username, etc.
class AlphanumericOnlyFormatter extends TextInputFormatter {
  /// Whether to allow spaces
  final bool allowSpaces;

  /// Whether to allow special characters like underscore, hyphen
  final bool allowSpecialChars;

  AlphanumericOnlyFormatter({
    this.allowSpaces = false,
    this.allowSpecialChars = false,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String pattern;
    if (allowSpaces && allowSpecialChars) {
      pattern = r'^[a-zA-Z0-9 _-]+$';
    } else if (allowSpaces) {
      pattern = r'^[a-zA-Z0-9 ]+$';
    } else if (allowSpecialChars) {
      pattern = r'^[a-zA-Z0-9_-]+$';
    } else {
      pattern = r'^[a-zA-Z0-9]+$';
    }

    if (RegExp(pattern).hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}

/// Custom input formatter that restricts maximum length
/// Similar to maxLength but provides more control
class MaxLengthFormatter extends TextInputFormatter {
  final int maxLength;

  MaxLengthFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > maxLength) {
      return oldValue;
    }
    return newValue;
  }
}

/// Custom input formatter for decimal numbers
/// Use for price, quantity fields
class DecimalNumberFormatter extends TextInputFormatter {
  /// Number of decimal places allowed (default: 2)
  final int decimalPlaces;

  DecimalNumberFormatter({this.decimalPlaces = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Allow only digits and one decimal point
    if (RegExp(r'^[0-9]*\.?[0-9]*$').hasMatch(newValue.text)) {
      // Check decimal places
      if (newValue.text.contains('.')) {
        final parts = newValue.text.split('.');
        if (parts.length > 2) {
          return oldValue; // Multiple decimal points
        }
        if (parts[1].length > decimalPlaces) {
          return oldValue; // Too many decimal places
        }
      }
      return newValue;
    }

    return oldValue;
  }
}

/// Custom input formatter for email addresses
/// Allows alphanumeric, dots, hyphens, underscores, and @ symbol
class EmailFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Allow email-valid characters
    if (RegExp(r'^[a-zA-Z0-9._%+-@]+$').hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}

/// Custom input formatter that capitalizes first letter of each word
/// Use for name fields
class CapitalizeWordsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Capitalize first letter of each word
    final words = newValue.text.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();

    final capitalizedText = capitalizedWords.join(' ');

    return TextEditingValue(
      text: capitalizedText,
      selection: TextSelection.collapsed(offset: capitalizedText.length),
    );
  }
}

/// Convenience class with pre-configured formatters
class InputFormatters {
  InputFormatters._();

  /// Phone number formatter (10 digits only)
  static final phoneNumber = PhoneNumberFormatter(maxLength: 10);

  /// Numeric only formatter
  static final numericOnly = NumericOnlyFormatter();

  /// Alphabetic only formatter (with spaces)
  static final alphabeticOnly = AlphabeticOnlyFormatter(allowSpaces: true);

  /// Alphabetic only formatter (no spaces)
  static final alphabeticOnlyNoSpaces = AlphabeticOnlyFormatter(
    allowSpaces: false,
  );

  /// Alphanumeric only formatter
  static final alphanumericOnly = AlphanumericOnlyFormatter();

  /// Alphanumeric with spaces
  static final alphanumericWithSpaces = AlphanumericOnlyFormatter(
    allowSpaces: true,
  );

  /// Email formatter
  static final email = EmailFormatter();

  /// Currency/price formatter (2 decimal places)
  static final currency = DecimalNumberFormatter(decimalPlaces: 2);

  /// Capitalize first letter of each word
  static final capitalizeName = CapitalizeWordsFormatter();
}
