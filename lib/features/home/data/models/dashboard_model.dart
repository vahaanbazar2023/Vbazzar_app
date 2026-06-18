import '../../../auction/models/auction_listing.dart';
import '../../../spare_and_fms/data/models/spare_part_model.dart';

// ─── Dashboard Vehicle (most_bought_veh) ─────────────────────────────────────

class DashboardVehicle {
  final int id;
  final String vehicleId;
  final String auctionId;
  final String make;
  final String model;
  final int year;
  final String registrationNo;
  final List<String> images;
  final int minimumPrice;
  final int bidsReceived;
  final int bidCount;
  final String status;
  final String yardName;
  final String yardLocation;
  final String fuelType;
  final int kilometers;
  final String colour;

  const DashboardVehicle({
    required this.id,
    required this.vehicleId,
    required this.auctionId,
    required this.make,
    required this.model,
    required this.year,
    required this.registrationNo,
    required this.images,
    required this.minimumPrice,
    required this.bidsReceived,
    required this.bidCount,
    required this.status,
    required this.yardName,
    required this.yardLocation,
    required this.fuelType,
    required this.kilometers,
    required this.colour,
  });

  factory DashboardVehicle.fromJson(Map<String, dynamic> json) {
    return DashboardVehicle(
      id: (json['id'] as num?)?.toInt() ?? 0,
      vehicleId: json['vehicle_id'] as String? ?? '',
      auctionId: json['auction_id'] as String? ?? '',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      registrationNo: json['registration_no'] as String? ?? '',
      images: _parseImages(json['images']),
      minimumPrice: (json['minimum_price'] as num?)?.toInt() ?? 0,
      bidsReceived: (json['bids_received'] as num?)?.toInt() ?? 0,
      bidCount: (json['bid_count'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      yardName: json['yard_name'] as String? ?? '',
      yardLocation: json['yard_location'] as String? ?? '',
      fuelType: json['fuel_type'] as String? ?? '',
      kilometers: (json['kilometers'] as num?)?.toInt() ?? 0,
      colour: json['colour'] as String? ?? '',
    );
  }

  String get displayTitle => '$make $model'.trim();
  String get primaryImage => images.isNotEmpty ? images.first : '';

  static List<String> _parseImages(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }
}

// ─── Dashboard Response ───────────────────────────────────────────────────────

class DashboardData {
  final List<AuctionListing> liveAuctions;
  final List<DashboardVehicle> mostBoughtVehicles;
  final List<SparePartModel> sparesFms;

  const DashboardData({
    required this.liveAuctions,
    required this.mostBoughtVehicles,
    required this.sparesFms,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final auctionsRaw = json['live_auctions'] as List<dynamic>? ?? [];
    final vehiclesRaw = json['most_bought_veh'] as List<dynamic>? ?? [];
    final sparesRaw = json['spares_fms'] as List<dynamic>? ?? [];

    return DashboardData(
      liveAuctions: auctionsRaw
          .map((e) => AuctionListing.fromJson(e as Map<String, dynamic>))
          .toList(),
      mostBoughtVehicles: vehiclesRaw
          .map((e) => DashboardVehicle.fromJson(e as Map<String, dynamic>))
          .toList(),
      sparesFms: sparesRaw
          .map((e) => SparePartModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
