import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/features/auction/models/auction_listing.dart';

AuctionListing _auction(String endAt) => AuctionListing(
  auctionId: 'AUC1',
  auctionTitle: 'HLF_PAN_India_FE',
  startAt: '2026-11-21T14:30:00+05:30',
  endAt: endAt,
  status: 'active',
);

void main() {
  final end = DateTime.parse('2026-11-23T17:30:00+05:30');

  test('the card stays while the auction runs and goes once it ends', () {
    final a = _auction('2026-11-23T17:30:00+05:30');
    expect(a.hasEndedAt(end.subtract(const Duration(minutes: 1))), isFalse);
    expect(a.hasEndedAt(end), isTrue);
    expect(a.hasEndedAt(end.add(const Duration(minutes: 5))), isTrue);
  });

  test('the IST text format is read too', () {
    final when = parseAuctionEnd('29 Jun 2029 - 06:00PM')!;
    expect([when.year, when.month, when.day, when.hour, when.minute], [2029, 6, 29, 18, 0]);
    expect(parseAuctionEnd('01 Jan 2030 - 12:15AM')!.hour, 0);
  });

  test('an unreadable end time never hides the card', () {
    expect(parseAuctionEnd(''), isNull);
    expect(parseAuctionEnd('soon'), isNull);
    expect(_auction('soon').hasEndedAt(DateTime(2100)), isFalse);
  });
}
