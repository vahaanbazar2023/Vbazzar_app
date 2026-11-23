// ignore_for_file: depend_on_referenced_packages
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:vahaan_mobile_2_0/core/localisation/app_localizations.dart';
import 'package:vahaan_mobile_2_0/core/storage/storage_keys.dart';
import 'package:vahaan_mobile_2_0/features/approved_vehicles/controllers/approved_vehicle_controller.dart';
import 'package:vahaan_mobile_2_0/features/approved_vehicles/domain/repositories/approved_vehicle_repository.dart';
import 'package:vahaan_mobile_2_0/features/approved_vehicles/domain/entities/auction_vehicle_match.dart';
import 'package:vahaan_mobile_2_0/features/approved_vehicles/views/sell_vehicle_form_screen.dart';
import 'package:vahaan_mobile_2_0/features/main_shell/controllers/main_shell_controller.dart';

/// The Approved Vehicles sell form used to add fake "sample_file_1.jpg" names
/// (which then failed to upload) instead of opening the picker.
class _FakePicker extends FilePicker with MockPlatformInterfaceMixin {
  FileType? lastType;
  List<String>? lastExtensions;
  List<PlatformFile> next = [];

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    lastType = type;
    lastExtensions = allowedExtensions;
    return next.isEmpty ? null : FilePickerResult(next);
  }
}

/// Records what the form submits; [reject] makes the server refuse it.
class _Repo extends Fake implements ApprovedVehicleRepository {
  dio.FormData? sent;
  String? reject;

  @override
  Future<void> submitVehicle(dio.FormData formData) async {
    sent = formData;
    if (reject != null) throw SubmitVehicleRejected(reject!);
  }
}

class _QuietController extends ApprovedVehicleController {
  _QuietController(this.repo) : super(repository: repo);
  final _Repo repo;

  // Skips the category / state fetches (no network in tests).
  @override
  // ignore: must_call_super
  void onInit() {}
  @override
  void initSellForm(String categoryName, String categoryCode) {}

  /// What the auction lookup answers (null = not in our auctions).
  AuctionVehicleMatch? auctionMatch;
  bool lookupFails = false;
  final lookedUp = <String>[];

  @override
  Future<AuctionVehicleMatch?> findAuctionVehicle(String reg) async {
    lookedUp.add(reg);
    if (lookupFails) throw Exception('offline');
    return auctionMatch;
  }

  /// Photos that fail to download (by file name).
  final failingPhotos = <String>{};

  /// "Downloads" into real temp files so the submit can attach them.
  @override
  Future<List<String>> downloadAuctionPhotos(List<String> urls) async {
    final dir = Directory.systemTemp.createTempSync('auction_photos');
    return [
      for (final u in urls.where(
        (u) => !failingPhotos.contains(u.split('/').last),
      ))
        (File(
          '${dir.path}/${u.split('/').last}',
        )..writeAsBytesSync([1, 2, 3])).path,
    ];
  }
}

PlatformFile _file(String path) =>
    PlatformFile(name: path.split('/').last, path: path, size: 10);

void main() {
  late _FakePicker picker;
  late _QuietController ctrl;

  setUp(() {
    Get.testMode = true;
    picker = _FakePicker();
    FilePicker.platform = picker;
    Get.put(MainShellController());
    // The logged-in vendor, as the app keeps it in secure storage.
    FlutterSecureStorage.setMockInitialValues({
      StorageKeys.userId: 'VB0000160',
    });
    ctrl = _QuietController(_Repo());
    Get.put<ApprovedVehicleController>(ctrl);
  });
  tearDown(Get.reset);

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => GetMaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // Opened on top of a page, as in the app (it goes back on success).
          home: const Scaffold(body: Text('Buy & Sell')),
        ),
      ),
    );
    Get.to(() => const SellVehicleFormScreen());
    await tester.pumpAndSettle();
  }

  // The three upload boxes, in order: photos, RC, insurance.
  Future<void> tapUpload(WidgetTester tester, int index) async {
    final box = find.text('Tap to upload').at(index);
    await tester.ensureVisible(box);
    await tester.tap(box);
    await tester.pump();
  }

  testWidgets('vehicle photos open the image picker and list the real files', (
    tester,
  ) async {
    await open(tester);
    picker.next = [
      _file('/data/user/0/app/cache/front.jpg'),
      _file('/data/user/0/app/cache/back.jpg'),
    ];
    await tapUpload(tester, 0);

    expect(picker.lastExtensions, ['jpg', 'jpeg', 'png', 'gif']);
    expect(find.text('front.jpg'), findsOneWidget);
    expect(find.text('back.jpg'), findsOneWidget);
    expect(find.textContaining('sample_file'), findsNothing);
    expect(find.textContaining('integration pending'), findsNothing);
  });

  testWidgets('RC and insurance uploads are gone; only vehicle photos', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('RC Documents'), findsNothing);
    expect(find.text('Insurance Documents'), findsNothing);
    expect(find.text('Tap to upload'), findsOneWidget);
  });

  Future<void> typeReg(WidgetTester tester, String reg) async {
    await tester.enterText(find.byType(TextField).first, reg);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    await tester.pump();
  }

  testWidgets('a registration in our auctions fills the form and adds photos', (
    tester,
  ) async {
    ctrl.sellBrands.assignAll([
      {'brand_code': 'TATA', 'brand_name': 'Tata'},
      {'brand_code': 'ASHO', 'brand_name': 'Ashok Leyland'},
    ]);
    ctrl.auctionMatch = AuctionVehicleMatch.fromJson({
      'vehicle_id': 'VEH000000002',
      'vehicle': {
        'make': 'TATA MOTORS',
        'year_of_manufacturing': 2019,
        'chassis_number': 'MAT123',
        'asset_description': 'Tata Signa 2823.K, Diesel',
        'images': ['https://cdn/AUC1/front.jpg', 'https://cdn/AUC1/back.jpg'],
      },
    });
    await open(tester);
    await typeReg(tester, 'ts09ab1234');

    expect(ctrl.lookedUp, ['TS09AB1234']);
    expect(
      find.textContaining('Found in our auction listings'),
      findsOneWidget,
    );
    expect(find.text('MAT123'), findsOneWidget);
    expect(find.text('2019'), findsOneWidget);
    expect(find.text('Tata Signa 2823.K, Diesel'), findsOneWidget);
    expect(find.text('Tata'), findsWidgets); // brand box
    expect(ctrl.sellBrandC.text, 'Tata');
    expect(find.text('front.jpg'), findsOneWidget);
    expect(find.text('back.jpg'), findsOneWidget);

    // Fields stay editable.
    await tester.enterText(find.widgetWithText(TextField, 'MAT123'), 'MAT999');
    expect(find.text('MAT999'), findsOneWidget);
  });

  testWidgets('not in our auctions: the seller fills it in by hand', (
    tester,
  ) async {
    await open(tester);
    await typeReg(tester, 'KA01MJ5678');
    expect(find.textContaining('Not in our auction listings'), findsOneWidget);
    expect(find.byIcon(Icons.attach_file), findsNothing);

    ctrl.lookupFails = true;
    await typeReg(tester, 'KA01MJ5679');
    expect(find.textContaining("Couldn't check"), findsOneWidget);
  });

  // ── Submission ────────────────────────────────────────────────

  Future<void> fillAndFind(WidgetTester tester) async {
    ctrl.sellBrands.assignAll([
      {'brand_code': 'TATA', 'brand_name': 'Tata'},
    ]);
    ctrl.auctionMatch = AuctionVehicleMatch.fromJson({
      'vehicle_id': 'VEH000000002',
      'vehicle': {
        'make': 'Tata Motors',
        'year_of_manufacturing': 2019,
        'chassis_number': 'MAT123',
        'asset_description': 'Tata Signa 2823.K, Diesel',
        'yard_name': 'Hyd Yard',
        'yard_location': 'Medchal, Hyderabad',
        'images': ['https://cdn/AUC1/front.jpg', 'https://cdn/AUC1/back.jpg'],
      },
    });
    await open(tester);
    await typeReg(tester, 'TS09AB1234');
    await tester.pumpAndSettle();
    // Price and location are not in auction data: the seller adds them.
    await tester.enterText(
      find.byWidgetPredicate(
        (w) =>
            w is TextField && w.decoration?.labelText == 'Expected Price (₹) *',
      ),
      '1850000',
    );
    ctrl.selectedSellStateId.value = 'TS';
    ctrl.selectedSellCityId.value = 'TS_HYD';
  }

  Future<void> submit(WidgetTester tester) async {
    final button = find.text('Submit Vehicle');
    await tester.ensureVisible(button);
    // Real work happens here (reading the photo files), so let it run.
    await tester.runAsync(() async {
      await tester.tap(button);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Lets the 5 s message popup finish so no timer outlives the test.
  Future<void> closePopups(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    // GetX keeps its snackbar queue across tests; empty it.
    SnackbarController.cancelAllSnackbars();
    await tester.pumpAndSettle();
  }

  testWidgets('removed fields are gone; yard fields are there', (tester) async {
    await open(tester);
    expect(find.textContaining('Owner Mobile'), findsNothing);
    expect(find.textContaining('Fitness'), findsNothing);
    expect(find.textContaining('GST'), findsNothing);
    expect(find.textContaining('Insurance Valid'), findsNothing);
    expect(find.text('Yard Name'), findsOneWidget);
    expect(find.text('Yard Location'), findsOneWidget);
  });

  testWidgets('an auction vehicle submits with its details, yard and photos', (
    tester,
  ) async {
    await fillAndFind(tester);
    expect(find.text('Hyd Yard'), findsOneWidget); // yard prefilled
    await submit(tester);

    final sent = ctrl.repo.sent;
    expect(sent, isNotNull, reason: 'the form was not submitted');
    final fields = {for (final f in sent!.fields) f.key: f.value};
    expect(fields, {
      'user_id': 'VB0000160',
      'category_type': '',
      'registration_number': 'TS09AB1234',
      'state_code': 'TS',
      'city_code': 'TS_HYD',
      'brand': 'Tata',
      'asset_description': 'Tata Signa 2823.K, Diesel',
      'year_of_manufacturing': '2019',
      'price': '1850000',
      'chassis_number': 'MAT123',
      'yard_name': 'Hyd Yard',
      'yard_location': 'Medchal, Hyderabad',
    });
    // Removed from the form, so never sent.
    for (final gone in [
      'owner_mobile_number',
      'fitness_available',
      'original_invoice_available',
      'gst_applicable',
      'vehicle_insurance_date',
      'offer_end_date',
      'offer_end_time',
      'insurance',
    ]) {
      expect(fields.containsKey(gone), isFalse, reason: gone);
    }
    // The photos go in the API's `images` field, with their file names.
    expect(sent.files.map((f) => f.key), ['images', 'images']);
    expect(sent.files.map((f) => f.value.filename), ['front.jpg', 'back.jpg']);
    expect(find.text('Vehicle submitted successfully!'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(SellVehicleFormScreen), findsNothing); // went back
    expect(find.text('Buy & Sell'), findsOneWidget);
    await closePopups(tester);
  });

  testWidgets("the server's exact reason is shown when it refuses", (
    tester,
  ) async {
    ctrl.repo.reject =
        "city_code 'TS_HYD' does not belong to state_code 'KAR'.";
    await fillAndFind(tester);
    await submit(tester);
    expect(
      find.text("city_code 'TS_HYD' does not belong to state_code 'KAR'."),
      findsOneWidget,
    );
    expect(find.text('Vehicle submitted successfully!'), findsNothing);
    await closePopups(tester);
  });

  testWidgets('an empty form names exactly what is missing', (tester) async {
    await open(tester);
    await submit(tester);
    expect(ctrl.repo.sent, isNull);
    final shown = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .firstWhere((t) => t.contains('Registration number is required'));
    expect(shown, contains('Price is required'));
    expect(shown, contains('Vehicle images are required'));
    expect(shown, isNot(contains('mobile')));
    expect(find.textContaining('Fix'), findsNothing); // no generic message
    await closePopups(tester);
  });

  testWidgets('photos that could not be added are reported', (tester) async {
    ctrl.failingPhotos.add('back.jpg');
    await fillAndFind(tester);
    expect(find.text('front.jpg'), findsOneWidget);
    expect(find.text('back.jpg'), findsNothing);
    expect(
      find.textContaining(
        "1 photo(s) from the auction listing couldn't be added",
      ),
      findsOneWidget,
    );
  });

  testWidgets('brand is filled once a slow brand list arrives', (tester) async {
    ctrl.auctionMatch = AuctionVehicleMatch.fromJson({
      'vehicle_id': 'VEH9',
      'vehicle': {'make': 'MARUTI', 'images': <String>[]},
    });
    await open(tester);
    ctrl.isLoadingSellBrands.value = true; // brand list still loading
    await typeReg(tester, 'TG24A0088');
    expect(ctrl.sellBrandC.text, isEmpty);

    ctrl.sellBrands.assignAll([
      {'brand_code': 'MARU', 'brand_name': 'Maruti Suzuki'},
    ]);
    ctrl.isLoadingSellBrands.value = false;
    await tester.pump();
    expect(ctrl.sellBrandC.text, 'Maruti Suzuki');
  });
}
