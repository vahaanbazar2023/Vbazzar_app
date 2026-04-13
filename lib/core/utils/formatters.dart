import 'package:intl/intl.dart';

class AppFormat {
  AppFormat._();

  // ── Currency ─────────────────────────────────────────────────
  static String inr(num amount) => NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  ).format(amount);

  static String compact(num amount) {
    if (amount >= 1e7) return '₹${(amount / 1e7).toStringAsFixed(2)} Cr';
    if (amount >= 1e5) return '₹${(amount / 1e5).toStringAsFixed(2)} L';
    if (amount >= 1e3) return '₹${(amount / 1e3).toStringAsFixed(2)} K';
    return inr(amount);
  }

  // ── Date / Time ───────────────────────────────────────────────
  static String date(DateTime dt, {String pattern = 'dd MMM yyyy'}) =>
      DateFormat(pattern).format(dt);

  static String time(DateTime dt, {bool is24h = false}) =>
      DateFormat(is24h ? 'HH:mm' : 'hh:mm a').format(dt);

  static String dateTime(DateTime dt) =>
      DateFormat('dd MMM yyyy, hh:mm a').format(dt);

  static String relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  // ── Phone ─────────────────────────────────────────────────────
  static String phone(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length == 10) return '+91 ${d.substring(0, 5)} ${d.substring(5)}';
    return raw;
  }

  // ── Vehicle Reg ───────────────────────────────────────────────
  static String vehicleReg(String raw) {
    final clean = raw.toUpperCase().replaceAll(' ', '');
    // MH12AB1234 → MH 12 AB 1234
    if (clean.length == 10) {
      return '${clean.substring(0, 2)} ${clean.substring(2, 4)} '
          '${clean.substring(4, 6)} ${clean.substring(6)}';
    }
    return raw;
  }

  // ── File size ─────────────────────────────────────────────────
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}
