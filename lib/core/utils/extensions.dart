import 'package:flutter/material.dart';

// ── String ──────────────────────────────────────────────────────────────────
extension StringX on String {
  String get capitalizeFirst =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);

  String get titleCase => split(
    ' ',
  ).map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' ');

  bool get isEmail => RegExp(r'^[\w.]+@[\w]+\.[a-z]{2,}$').hasMatch(this);

  bool get isBlank => trim().isEmpty;

  String truncate(int max, {String suffix = '…'}) =>
      length <= max ? this : '${substring(0, max)}$suffix';
}

extension StringNullX on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
  String get orEmpty => this ?? '';
}

// ── DateTime ────────────────────────────────────────────────────────────────
extension DateTimeX on DateTime {
  bool get isToday {
    final n = DateTime.now();
    return year == n.year && month == n.month && day == n.day;
  }

  String get ddMmYyyy =>
      '${day.toString().padLeft(2, '0')}/'
      '${month.toString().padLeft(2, '0')}/$year';

  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

// ── num ─────────────────────────────────────────────────────────────────────
extension NumX on num {
  String get inr => '₹${toStringAsFixed(2)}';
  String get compact {
    if (this >= 1e7) return '${(this / 1e7).toStringAsFixed(1)}Cr';
    if (this >= 1e5) return '${(this / 1e5).toStringAsFixed(1)}L';
    if (this >= 1e3) return '${(this / 1e3).toStringAsFixed(1)}K';
    return toString();
  }
}

// ── List ────────────────────────────────────────────────────────────────────
extension ListX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
  List<T> get unique => toSet().toList();
}

// ── BuildContext ─────────────────────────────────────────────────────────────
extension ContextX on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  void showSnackBar(String msg, {Color? bg}) => ScaffoldMessenger.of(
    this,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: bg));
}
