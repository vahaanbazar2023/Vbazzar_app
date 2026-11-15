// Standalone check — run with: dart run tool_check_bids.dart
import 'lib/features/auction/models/my_bids_wins_models.dart';

void main() {
  final item = {
    "bid_id": 273,
    "auction_id": "AUC000000124",
    "auction_title": "IDFC South Online",
    "vehicle_id": "VEH000008837",
    "vehicle_details": {
      "id": 8837,
      "vehicle_id": "VEH000008837",
      "market_value": null,
      "transaction_fees": null,
      "parking_charges": null,
      "images": ["https://x/1.jpg"],
      "your_bid": 122000,
      "bids_received": 4,
      "bids_left": 6,
      "available_balance": 0,
      "minimum_price": 1000,
    },
    "user_bid_amount": 122000,
    "user_bid_count": 1,
    "current_highest_bid": 122000,
    "current_bid": null,
    "bid_status": "approved",
    "auction_status": "active",
    "auction_end_time": "15 Oct 2025 - 06:00PM",
    "bid_placed_at": "11 Oct 2025 - 02:07AM",
    "last_updated_at": "11 Oct 2025 - 02:34AM",
    "user_auction_status": "Pending",
    "is_auction_active": false,
  };

  final parsed = MyBidItem.fromJson(item);
  print('parsed bidId=${parsed.bidId}');
  print('endDateTime=${parsed.auctionEndDateTime}');
  print('isEnded=${parsed.isEnded}');
  print('isWinning=${parsed.isWinning}');
  print('OK');
}
