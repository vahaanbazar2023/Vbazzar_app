import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/features/approved_vehicles/data/models/approved_vehicle_listing_model.dart';
import 'package:vahaan_mobile_2_0/features/payment/models/payment_models.dart';

void main() {
  test('listing reads the per-vehicle booking and inspection amounts', () {
    final l = ApprovedVehicleListingModel.fromJson({
      'id': 1,
      'approved_vehicle_id': 'AVEH000000001',
      'price': 181000,
      'booking_amount': 45250,
      'inspection_amount': 1810.5,
      'inspection_subscription': {
        'inspection_amount': 1810.5,
        'category_plan': 'AV00003',
      },
    });
    expect(l.bookingAmount, 45250.0);
    expect(l.inspectionAmount, 1810.5);
    expect(l.inspectionSubscription?.categoryPlan, 'AV00003');
  });

  test('older responses without the amounts parse as null', () {
    final l = ApprovedVehicleListingModel.fromJson({'id': 1});
    expect(l.bookingAmount, isNull);
    expect(l.inspectionAmount, isNull);
  });

  test('payment initiate sends the vehicle and purpose', () {
    final json = const InitiatePaymentReq(
      userId: 'VB1',
      planCode: 'AV00003',
      forPayment: 45250,
      approvedVehicleId: 'AVEH000000001',
      purpose: 'booking',
    ).toJson();
    expect(json['approved_vehicle_id'], 'AVEH000000001');
    expect(json['purpose'], 'booking');
    expect(
      const InitiatePaymentReq(
        userId: 'VB1',
        planCode: 'P',
      ).toJson().containsKey('purpose'),
      isFalse,
    );
  });
}
