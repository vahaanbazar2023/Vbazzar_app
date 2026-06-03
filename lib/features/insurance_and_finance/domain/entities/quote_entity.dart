/// A single quote from an insurance/finance provider.
class QuoteEntity {
  final String providerName;
  final double price;
  final String downloadablePdfUrl;

  const QuoteEntity({
    required this.providerName,
    required this.price,
    required this.downloadablePdfUrl,
  });
}

/// URLs to previously uploaded documents for a vehicle.
class FileUrlsEntity {
  final String? aadharFile;
  final String? panFile;
  final String? rcFile;
  final String? previousPolicyFile;

  const FileUrlsEntity({
    this.aadharFile,
    this.panFile,
    this.rcFile,
    this.previousPolicyFile,
  });
}

/// A vehicle item with its associated quotes.
class VehicleQuoteItemEntity {
  final String vehicleId;
  final String vehicleNo;
  final String serviceType; // "insurance" | "finance"
  final List<QuoteEntity> quotes;
  final int totalQuotes;
  final FileUrlsEntity? fileUrls;

  const VehicleQuoteItemEntity({
    required this.vehicleId,
    required this.vehicleNo,
    required this.serviceType,
    required this.quotes,
    required this.totalQuotes,
    this.fileUrls,
  });
}