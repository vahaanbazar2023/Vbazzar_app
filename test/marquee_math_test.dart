import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/utils/marquee_math.dart';

void main() {
  const base = 1200.0, period = 600.0;

  test('forward row moves one period to the right, constant speed', () {
    double at(double p) => marqueeOffset(base: base, period: period, progress: p, reverse: false);
    expect(at(0), base);
    expect(at(1), base + period);
    expect(at(0.5) - at(0.25), closeTo(at(0.75) - at(0.5), 1e-9), reason: 'constant speed');
  });

  test('reverse row moves one period the other way', () {
    double at(double p) => marqueeOffset(base: base, period: period, progress: p, reverse: true);
    expect(at(0), base);
    expect(at(1), base - period);
  });

  test('wrapping from the end back to the start is exactly one pattern (seamless)', () {
    for (final reverse in [false, true]) {
      final end = marqueeOffset(base: base, period: period, progress: 1, reverse: reverse);
      final start = marqueeOffset(base: base, period: period, progress: 0, reverse: reverse);
      expect((end - start).abs(), period);
    }
  });

  test('position never leaves the safe window around the base', () {
    for (var i = 0; i <= 100; i++) {
      for (final reverse in [false, true]) {
        final o = marqueeOffset(base: base, period: period, progress: i / 100, reverse: reverse);
        expect(o, inInclusiveRange(base - period, base + period));
      }
    }
  });
}
