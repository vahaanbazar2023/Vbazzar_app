import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/features/buy_and_sell/controllers/vehicle_detail_controller.dart';
import 'package:vahaan_mobile_2_0/features/buy_and_sell/data/models/buy_vehicle_model.dart';
import 'package:vahaan_mobile_2_0/features/buy_and_sell/data/repositories/buy_sell_repository_impl.dart';
import 'package:vahaan_mobile_2_0/features/buy_and_sell/domain/entities/paginated_buy_vehicles_response.dart';
import 'package:vahaan_mobile_2_0/features/buy_and_sell/domain/repositories/buy_sell_repository.dart';

BuyVehicleModel _vehicle(String id) => BuyVehicleModel.fromJson({
  'sb_vehicle_id': id,
  'category_code': 'TRUCK',
  'category_name': 'Truck',
  'is_interested': 'yes',
});

/// Only the two calls the wishlist uses are implemented.
class _FakeRepo implements BuySellRepository {
  final pages = <int, List<BuyVehicleModel>>{};
  int totalPages = 1;
  final listCalls = <Map<String, dynamic>>[];
  final interestCalls = <Map<String, dynamic>>[];
  bool interestSucceeds = true;

  @override
  Future<PaginatedBuyVehiclesResponse> listVehiclesByCategoryFilters({
    required String userId,
    required String categoryCode,
    required int limit,
    required int page,
    Map<String, dynamic>? filters,
  }) async {
    listCalls.add({
      'user_id': userId,
      'category_code': categoryCode,
      'page': page,
      'filters': filters,
    });
    return PaginatedBuyVehiclesResponse(
      vehicles: pages[page] ?? [],
      ads: const [],
      totalPages: totalPages,
      totalCount: pages.values.fold(0, (a, b) => a + b.length),
      currentPage: page,
      hasMore: page < totalPages,
    );
  }

  @override
  Future<Map<String, dynamic>> userInterest({
    String? userId,
    String? vehicleId,
    int? vehicleOffer,
    String? isInterested,
    String? ownerDetailsAccess,
    String? vehicleDetailsAccess,
    String? inspectionRequest,
  }) async {
    interestCalls.add({'vehicle_id': vehicleId, 'is_interested': isInterested});
    return {'status': interestSucceeds ? 'success' : 'error'};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    '${invocation.memberName} is not used by the wishlist',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => call.method == 'read' ? 'VB0000001' : null,
        );
  });

  test('wishlist request: all categories, is_interested yes, same body shape', () {
    expect(
      BuySellRepositoryImpl.buildCategoryFilterBody(
        userId: 'VB0000001',
        categoryCode: 'all',
        limit: 10,
        page: 1,
        filters: const {'is_interested': 'yes'},
      ),
      {
        'category_code': 'all',
        'page': 1,
        'limit': 10,
        'user_id': 'VB0000001',
        'is_interested': 'yes',
      },
    );
  });

  test('loads the wishlist, paginates, and remembers the hearts', () async {
    final repo = _FakeRepo()
      ..totalPages = 2
      ..pages[1] = [_vehicle('A'), _vehicle('B')]
      ..pages[2] = [_vehicle('C')];
    final c = BuyVehicleController(repository: repo);

    await c.refreshWishlist();
    expect(c.wishlistVehicles.map((v) => v.sbVehicleId), ['A', 'B']);
    expect(c.hasMoreWishlist.value, isTrue);
    expect(repo.listCalls.first['category_code'], 'all');
    expect(repo.listCalls.first['user_id'], 'VB0000001');
    expect(repo.listCalls.first['filters'], {'is_interested': 'yes'});

    await c.fetchWishlist(); // next page
    expect(c.wishlistVehicles.map((v) => v.sbVehicleId), ['A', 'B', 'C']);
    expect(c.hasMoreWishlist.value, isFalse);
    expect(c.wishlistedIds, containsAll(['A', 'B', 'C']));

    await c.refreshWishlist(); // refresh starts over, no duplicates
    expect(c.wishlistVehicles.length, 2);
  });

  test('an empty wishlist is an empty list, not an error', () async {
    final c = BuyVehicleController(repository: _FakeRepo());
    await c.refreshWishlist();
    expect(c.wishlistVehicles, isEmpty);
    expect(c.hasErrorWishlist.value, isFalse);
  });

  test('un-hearting removes it from the wishlist and tells the server', () async {
    final repo = _FakeRepo()..pages[1] = [_vehicle('A'), _vehicle('B')];
    final c = BuyVehicleController(repository: repo);
    await c.refreshWishlist();

    await c.toggleWishlist(c.wishlistVehicles.first);

    expect(c.wishlistVehicles.map((v) => v.sbVehicleId), ['B']);
    expect(c.wishlistedIds.contains('A'), isFalse);
    expect(repo.interestCalls, [
      {'vehicle_id': 'A', 'is_interested': 'no'},
    ]);
  });

  test('if the server refuses, the vehicle stays in the wishlist', () async {
    final repo = _FakeRepo()
      ..interestSucceeds = false
      ..pages[1] = [_vehicle('A'), _vehicle('B')];
    final c = BuyVehicleController(repository: repo);
    await c.refreshWishlist();

    // The error snackbar needs a screen; in a unit test GetX reports that from its own queue.
    // Only the wishlist state matters here.
    final done = Completer<void>();
    runZonedGuarded(() async {
      await c.toggleWishlist(c.wishlistVehicles.first);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      done.complete();
    }, (_, __) {});
    await done.future;

    expect(c.wishlistVehicles.map((v) => v.sbVehicleId), ['A', 'B']);
    expect(c.wishlistedIds.contains('A'), isTrue);
  });

  test('a failed load shows the error state', () async {
    final c = BuyVehicleController(repository: _ThrowingRepo());
    await c.refreshWishlist();
    expect(c.hasErrorWishlist.value, isTrue);
  });
}

class _ThrowingRepo extends _FakeRepo {
  @override
  Future<PaginatedBuyVehiclesResponse> listVehiclesByCategoryFilters({
    required String userId,
    required String categoryCode,
    required int limit,
    required int page,
    Map<String, dynamic>? filters,
  }) => throw Exception('offline');
}
