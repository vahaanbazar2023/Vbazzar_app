class Validators {
  Validators._();

  static String? required(String? v, {String field = 'This field'}) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;

  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    return RegExp(r'^[\w.]+@[\w]+\.[a-z]{2,}$').hasMatch(v)
        ? null
        : 'Enter a valid email';
  }

  static String? password(String? v, {int min = 6}) {
    if (v == null || v.isEmpty) return 'Password is required';
    return v.length >= min ? null : 'Minimum $min characters required';
  }

  static String? confirmPassword(String? v, String? original) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    return v == original ? null : 'Passwords do not match';
  }

  static String? phone(String? v) {
    if (v == null || v.isEmpty) return 'Phone number is required';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^[6-9]\d{9}$').hasMatch(digits)
        ? null
        : 'Enter a valid 10-digit mobile number';
  }

  static String? vehicleReg(String? v) {
    if (v == null || v.isEmpty) return 'Registration number is required';
    return RegExp(
          r'^[A-Z]{2}\d{2}[A-Z]{1,3}\d{4}$',
        ).hasMatch(v.toUpperCase().replaceAll(' ', ''))
        ? null
        : 'Enter a valid registration (e.g. MH12AB1234)';
  }

  static String? minLength(String? v, int min, {String? field}) {
    final err = required(v, field: field ?? 'This field');
    if (err != null) return err;
    return v!.length >= min ? null : 'Minimum $min characters';
  }

  static String? maxLength(String? v, int max, {String? field}) =>
      (v != null && v.length > max) ? 'Maximum $max characters' : null;

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
