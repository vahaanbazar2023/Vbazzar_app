/// Domain entity for a vehicle listed in an auction.
class VehicleListingEntity {
  final String vehicleId;
  final String auctionId;
  final String make;
  final String model;
  final String? variant;
  final String? manufacturingYear;
  final int minimumPrice;
  final int? currentBid;
  final int totalBids;
  final int bidsLeft;
  final String? imageUrl;
  final List<String> imageUrls;
  final String? categoryType;
  final String? vehicleType;
  final String? state;
  final String? city;
  final String? registrationNumber;
  final String? fuelType;
  final String? bodyType;
  final int? tonnage;
  final int? noOfTyres;
  final int? kv;
  final String? lotNumber;
  final String? status;
  final bool? isInterested;
  final String? vehicleDetails;

  const VehicleListingEntity({
    required this.vehicleId,
    required this.auctionId,
    required this.make,
    required this.model,
    this.variant,
    this.manufacturingYear,
    required this.minimumPrice,
    this.currentBid,
    this.totalBids = 0,
    this.bidsLeft = 0,
    this.imageUrl,
    this.imageUrls = const [],
    this.categoryType,
    this.vehicleType,
    this.state,
    this.city,
    this.registrationNumber,
    this.fuelType,
    this.bodyType,
    this.tonnage,
    this.noOfTyres,
    this.kv,
    this.lotNumber,
    this.status,
    this.isInterested,
    this.vehicleDetails,
  });

  /// Get all image URLs (deduplicated).
  List<String> get allImageUrls {
    final urls = <String>[];
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      urls.add(imageUrl!);
    }
    for (final url in imageUrls) {
      if (url.isNotEmpty && !urls.contains(url)) {
        urls.add(url);
      }
    }
    return urls;
  }

  /// Formatted price display.
  String get formattedMinimumPrice {
    if (minimumPrice == 0) return '₹ 0';
    return '₹ ${_formatNumber(minimumPrice)}';
  }

  String get formattedCurrentBid {
    if (currentBid == null || currentBid == 0) return 'No bids yet';
    return '₹ ${_formatNumber(currentBid!)}';
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