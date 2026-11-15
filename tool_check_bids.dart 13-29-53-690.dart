// Standalone check — run with: dart run tool_check_bids.dart
import 'lib/features/auction/models/my_bids_wins_models.dart';

void main() {
  // Reproduces the crash: current_bid + numeric fields sent as Strings.
  final item = {
    "bid_id": "273",
    "auction_id": "AUC000000124",
    "vehicle_details": {"images": null, "minimum_price": 1000},
    "user_bid_amount": "122000",
    "user_bid_count": 1,
    "current_highest_bid": "122000",
    "current_bid": "120000",
    "bid_status": "approved",
    "auction_end_time": "15 Oct 2025 - 06:00PM",
    "is_auction_active": "false",
  };

  final parsed = MyBidItem.fromJson(item);
  print('bidId=${parsed.bidId} (${parsed.bidId.runtimeType})');
  print('userBidAmount=${parsed.userBidAmount}');
  print('currentHighestBid=${parsed.currentHighestBid}');
  print('currentBid=${parsed.currentBid}');
  print('isAuctionActive=${parsed.isAuctionActive}');
  print('isEnded=${parsed.isEnded}');
  print('OK — no crash');
}
