/// Rupee amounts in English words, Indian system (thousand, lakh, crore).
///
/// `AmountInWords.rupees(250000)` → `Two Lakh Fifty Thousand Rupees Only`.
class AmountInWords {
  AmountInWords._();

  static const _ones = [
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', //
    'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
    'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen',
  ];
  static const _tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', //
    'Eighty', 'Ninety',
  ];

  /// Words for a whole number, e.g. `12,34,56,789` → `Twelve Crore Thirty Four
  /// Lakh Fifty Six Thousand Seven Hundred Eighty Nine`.
  static String number(int n) {
    if (n == 0) return 'Zero';
    if (n < 0) return 'Minus ${number(-n)}';
    final parts = <String>[];
    final crore = n ~/ 10000000;
    n %= 10000000;
    if (crore > 0) parts.add('${number(crore)} Crore');
    final lakh = n ~/ 100000;
    n %= 100000;
    if (lakh > 0) parts.add('${_belowHundred(lakh)} Lakh');
    final thousand = n ~/ 1000;
    n %= 1000;
    if (thousand > 0) parts.add('${_belowHundred(thousand)} Thousand');
    final hundred = n ~/ 100;
    n %= 100;
    if (hundred > 0) parts.add('${_ones[hundred]} Hundred');
    if (n > 0) parts.add(_belowHundred(n));
    return parts.join(' ');
  }

  /// `number(n)` followed by "Rupees Only" (or "Rupee Only" for 1).
  static String rupees(int n) =>
      '${number(n)} ${n == 1 ? 'Rupee' : 'Rupees'} Only';

  static String _belowHundred(int n) {
    if (n < 20) return _ones[n];
    final t = _tens[n ~/ 10];
    final o = _ones[n % 10];
    return o.isEmpty ? t : '$t $o';
  }
}
