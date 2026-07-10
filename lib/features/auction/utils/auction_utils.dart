/// Utility helpers and constants for the Auction feature.
class AuctionUtils {
  AuctionUtils._();

  // ─── Auction source/category options ────────────────────────
  // Display label → API value sent in the `category` field.
  static const Map<String, String> auctionCategoryOptions = {
    'All': '',
    'Bank': 'bank',
    'Insurance': 'insurance',
    'Customer': 'customer',
  };

  /// Display labels shown in the dropdown.
  static List<String> get auctionCategoryLabels =>
      auctionCategoryOptions.keys.toList();

  /// Returns the API value for a display label. Returns '' for 'All'/unknown.
  static String auctionCategoryApiValue(String label) =>
      auctionCategoryOptions[label] ?? '';

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

  // ─── Category → vehicle_type mapping ─────────────────────────
  static const Map<String, String> categoryVehicleTypeMap = {
    // Exact names returned by the API
    'Commercial Vehicles': 'CV',
    'Commercial': 'CV',
    'Passenger Vehicles': '4w',
    'Passenger': '4w',
    'Two Wheeler': '2w',
    'Two Wheelers': '2w',
    'Three Wheeler': '3w',
    'Three Wheelers': '3w',
    'Construction Equipment': 'CE',
    'Construction Equipments': 'CE',
    // By category code
    'CV': 'CV',
    '4W': '4w',
    '2W': '2w',
    '3W': '3w',
    'CE': 'CE',
  };

  /// Returns the API vehicle_type string for a given category name or code.
  /// Returns empty string if not found (API will return all types).
  static String vehicleTypeForCategory(String category) {
    if (category.isEmpty || category.toLowerCase() == 'all') return '';
    // Exact match first
    if (categoryVehicleTypeMap.containsKey(category)) {
      return categoryVehicleTypeMap[category]!;
    }
    // Case-insensitive fallback
    final lower = category.toLowerCase();
    for (final entry in categoryVehicleTypeMap.entries) {
      if (entry.key.toLowerCase() == lower) return entry.value;
    }
    return '';
  }

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
