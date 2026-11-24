import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/features/approved_vehicles/utils/sell_form_inputs.dart';

/// Type [typed] one character at a time through the price formatter.
String typePrice(String typed) {
  final f = PriceInputFormatter();
  var v = TextEditingValue.empty;
  for (final ch in typed.split('')) {
    final next = v.text + ch;
    v = f.formatEditUpdate(v, TextEditingValue(text: next, selection: TextSelection.collapsed(offset: next.length)));
  }
  return v.text;
}

String pastePrice(String pasted) => PriceInputFormatter()
    .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: pasted, selection: TextSelection.collapsed(offset: pasted.length)))
    .text;

void main() {
  test('a decimal price keeps its point (181000.50 never becomes 18100050)', () {
    expect(typePrice('181000.50'), '181000.50');
    expect(typePrice('181000.505'), '181000.50'); // at most 2 decimals
    expect(typePrice('1.2.3'), '1.23');           // a second point is refused
    expect(typePrice('12a3'), '123');
  });

  test('pasted Indian grouping is accepted without the commas', () {
    expect(pastePrice('1,81,000'), '181000');
    expect(pastePrice('1 81 000.5'), '181000.5');
    expect(pastePrice('₹1,81,000'), '');            // anything else is refused as a whole
  });

  test('price must be above zero', () {
    expect(SellFormInputs.isValidPrice('181000'), isTrue);
    expect(SellFormInputs.isValidPrice('181000.5'), isTrue);
    expect(SellFormInputs.isValidPrice('0'), isFalse);
    expect(SellFormInputs.isValidPrice('0.00'), isFalse);
    expect(SellFormInputs.isValidPrice(''), isFalse);
    expect(SellFormInputs.isValidPrice('12.'), isFalse);
  });

  test('year is 1900 to next year, like the API', () {
    final now = DateTime(2026, 11, 24);
    expect(SellFormInputs.maxYear(now), 2027);
    expect(SellFormInputs.isValidYear('2014', now: now), isTrue);
    expect(SellFormInputs.isValidYear('2027', now: now), isTrue);
    expect(SellFormInputs.isValidYear('2028', now: now), isFalse);
    expect(SellFormInputs.isValidYear('1899', now: now), isFalse);
    expect(SellFormInputs.isValidYear('201', now: now), isFalse);
  });
}
