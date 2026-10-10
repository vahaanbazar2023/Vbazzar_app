import '../extensions/context_extensions.dart';

class Validators {
  Validators._();

  static String? required(String? v, {String? field}) =>
      (v == null || v.trim().isEmpty)
      ? appL10n.coreFieldRequired(field ?? appL10n.coreThisField)
      : null;

  static String? email(String? v) {
    if (v == null || v.isEmpty) return appL10n.emailRequired;
    return RegExp(r'^[\w.]+@[\w]+\.[a-z]{2,}$').hasMatch(v)
        ? null
        : appL10n.coreEnterValidEmailShort;
  }

  static String? password(String? v, {int min = 6}) {
    if (v == null || v.isEmpty) return appL10n.corePasswordRequired;
    return v.length >= min ? null : appL10n.coreMinCharactersRequired(min);
  }

  static String? confirmPassword(String? v, String? original) {
    if (v == null || v.isEmpty) return appL10n.coreConfirmPasswordPrompt;
    return v == original ? null : appL10n.corePasswordsDoNotMatch;
  }

  static String? phone(String? v) {
    if (v == null || v.isEmpty) return appL10n.corePhoneRequired;
    final digits = v.replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^[6-9]\d{9}$').hasMatch(digits)
        ? null
        : appL10n.coreEnterValidMobile;
  }

  static String? vehicleReg(String? v) {
    if (v == null || v.isEmpty) return appL10n.coreRegNumberRequired;
    return RegExp(
          r'^[A-Z]{2}\d{2}[A-Z]{1,3}\d{4}$',
        ).hasMatch(v.toUpperCase().replaceAll(' ', ''))
        ? null
        : appL10n.coreEnterValidRegNumber;
  }

  static String? minLength(String? v, int min, {String? field}) {
    final err = required(v, field: field);
    if (err != null) return err;
    return v!.length >= min ? null : appL10n.coreMinCharacters(min);
  }

  static String? maxLength(String? v, int max, {String? field}) =>
      (v != null && v.length > max) ? appL10n.coreMaxCharacters(max) : null;

  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) => (v) {
    for (final fn in validators) {
      final e = fn(v);
      if (e != null) return e;
    }
    return null;
  };
}
