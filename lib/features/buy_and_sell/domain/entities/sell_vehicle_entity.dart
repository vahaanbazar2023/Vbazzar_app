class SellVehicleEntity {
  final String id;
  final String? categoryCode;
  final String? categoryName;
  final String? brandCode;
  final String? brandName;
  final String? model;
  final String? year;
  final String? status;
  final String? imageUrl;
  final String? createdAt;
  final double? askingPrice;
  final String? registrationNumber;
  final String? approved;
  final String? isSold;
  final double? price;
  final List<VehicleFile>? vehicleFiles;

  const SellVehicleEntity({
    required this.id,
    this.categoryCode,
    this.categoryName,
    this.brandCode,
    this.brandName,
    this.model,
    this.year,
    this.status,
    this.imageUrl,
    this.createdAt,
    this.askingPrice,
    this.registrationNumber,
    this.approved,
    this.isSold,
    this.price,
    this.vehicleFiles,
  });

  /// Backward-compatible alias used by views.
  String get sbVehicleId => id;

  /// Primary image URL for display - uses first vehicle file image if available.
  String get primaryImageUrl {
    if (vehicleFiles != null && vehicleFiles!.isNotEmpty) {
      final imageFile = vehicleFiles!.firstWhere(
        (f) => f.fileType == 'image',
        orElse: () => vehicleFiles!.first,
      );
      return imageFile.fileUrl;
    }
    return imageUrl ?? '';
  }

  /// List of image URLs from vehicle_files
  List<String> get imageUrls {
    if (vehicleFiles == null) return [];
    return vehicleFiles!
        .where((f) => f.fileType == 'image')
        .map((f) => f.fileUrl)
        .toList();
  }

  /// Human-readable status label.
  String get statusLabel {
    if (isSold == 'yes') return 'Sold';
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status ?? 'Unknown';
    }
  }

  /// Whether the vehicle has been marked as sold.
  bool get isVehicleSold => isSold == 'yes';

  /// Whether the vehicle status is pending.
  bool get isPending => status == 'pending';

  /// Whether the vehicle status is approved.
  bool get isApproved => status == 'approved' || approved == 'yes';

  /// Whether the vehicle status is rejected.
  bool get isRejected => status == 'rejected';

  /// Formatted price string, e.g. "₹12,50,000".
  String get formattedPrice {
    final p = price ?? askingPrice;
    if (p == null || p <= 0) return 'Price on request';
    return '₹${_formatNumber(p.toInt())}';
  }

  static String _formatNumber(int n) {
    if (n >= 10000000) {
      return '${(n / 10000000).toStringAsFixed(2)} Cr';
    } else if (n >= 100000) {
      return '${(n / 100000).toStringAsFixed(2)} L';
    } else if (n >= 1000) {
      final s = n.toString();
      final last3 = s.substring(s.length - 3);
      final rest = s.substring(0, s.length - 3);
      return rest.isNotEmpty ? '$rest,$last3' : last3;
    }
    return n.toString();
  }
}

/// Vehicle file model for images, RC, insurance documents
class VehicleFile {
  final int id;
  final String fileType;
  final String fileTypeSource;
  final String bucketName;
  final String fileKey;
  final String fileUrl;
  final String status;
  final String uploadedAt;

  const VehicleFile({
    required this.id,
    required this.fileType,
    required this.fileTypeSource,
    required this.bucketName,
    required this.fileKey,
    required this.fileUrl,
    required this.status,
    required this.uploadedAt,
  });

  factory VehicleFile.fromJson(Map<String, dynamic> json) {
    return VehicleFile(
      id: json['id'] as int? ?? 0,
      fileType: json['file_type']?.toString() ?? '',
      fileTypeSource: json['file_type_source']?.toString() ?? '',
      bucketName: json['bucket_name']?.toString() ?? '',
      fileKey: json['file_key']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      uploadedAt: json['uploaded_at']?.toString() ?? '',
    );
  }
}
