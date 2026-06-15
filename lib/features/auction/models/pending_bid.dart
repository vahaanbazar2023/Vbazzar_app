/// Immutable value object that survives navigation to the Subscription screen.
/// Stored in-memory on [VehicleListingController].
/// Cleared immediately before any auto-submission attempt to prevent duplicates.
class PendingBid {
  final String vehicleId;
  final String auctionId;
  final int bidAmount;

  const PendingBid({
    required this.vehicleId,
    required this.auctionId,
    required this.bidAmount,
  });
}
