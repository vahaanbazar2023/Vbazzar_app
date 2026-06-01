/// Utility helpers and constants for the Auction feature.
class AuctionUtils {
  AuctionUtils._();

  // ─── Filter option constants ──────────────────────────────────

  static const List<String> categoryOptions = [
    'All',
    'Commercial',
    'Passenger',
    'Two Wheeler',
    'Three Wheeler',
    'Construction Equipment',
  ];

  static const List<String> vehicleTypeOptions = [
    'All',
    'Car',
    'SUV',
    'Truck',
    'Bus',
    'Auto',
    'Tractor',
    'JCB',
    'Crane',
    'Trailer',
  ];

  // ─── Helpers ──────────────────────────────────────────────────

  /// Returns a human-readable status label for an auction.
  static String auctionStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return 'Live';
      case 'upcoming':
        return 'Upcoming';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// Formats a price integer to a readable ₹ string.
  static String formatPrice(int price) {
    if (price == 0) return '₹ 0';
    return '₹ ${_formatNumber(price)}';
  }

  static String _formatNumber(int number) {
    final s = number.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(',');
      buf.write(s[i]);
      count++;
    }
    return buf.toString().split('').reversed.join('');
  }
}