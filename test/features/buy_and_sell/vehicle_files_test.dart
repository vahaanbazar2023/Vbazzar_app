import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/features/buy_and_sell/data/models/buy_vehicle_model.dart';
import 'package:vahaan_mobile_2_0/features/buy_and_sell/data/models/subscribed_vehicle_model.dart';
import 'package:vahaan_mobile_2_0/features/buy_and_sell/domain/entities/buy_vehicle_entity.dart';
import 'package:vahaan_mobile_2_0/features/buy_and_sell/domain/entities/vehicle_files.dart';

/// What the backend sends for a paid buyer: photos plus RC and insurance.
const _files = [
  {'file_type': 'image', 'file_url': 'https://s3/p1.jpg'},
  {'file_type': 'rc', 'file_url': 'https://s3/rc.pdf'},
  {'file_type': 'insurance', 'file_url': 'https://s3/ins.pdf'},
  {'file_type': 'image', 'file_url': 'https://s3/p2.jpg'},
];

void main() {
  test('vehicle_files splits into photos and documents', () {
    final files = VehicleFiles.fromJson(_files);
    expect(files.photoUrls, ['https://s3/p1.jpg', 'https://s3/p2.jpg']);
    expect(files.documents.map((d) => d.type), ['rc', 'insurance']);
    expect(files.documents.first.isRc, isTrue);
  });

  test('a file with no file_type is treated as a photo', () {
    final files = VehicleFiles.fromJson([
      {'file_url': 'https://s3/old.jpg'},
    ]);
    expect(files.photoUrls, ['https://s3/old.jpg']);
    expect(files.documents, isEmpty);
  });

  test('buy list gallery shows only vehicle photos', () {
    final v = BuyVehicleModel.fromJson({
      'sb_vehicle_id': 'BSVEH1',
      'category_code': 'TRUCK',
      'category_name': 'Truck',
      'vehicle_files': _files,
    });
    expect(v.allImageUrls, ['https://s3/p1.jpg', 'https://s3/p2.jpg']);
    expect(v.documents.map((d) => d.url), [
      'https://s3/rc.pdf',
      'https://s3/ins.pdf',
    ]);
  });

  test('deep-link vehicle shows each photo once, without documents', () {
    final v = BuyVehicleEntity.fromSingleVehicleJson({
      'sb_vehicle_id': 'BSVEH1',
      'category_code': 'TRUCK',
      'category_name': 'Truck',
      'vehicle_files': _files,
    });
    expect(v.allImageUrls, ['https://s3/p1.jpg', 'https://s3/p2.jpg']);
    expect(v.documents, hasLength(2));
  });

  test('subscribed vehicle gallery shows only vehicle photos', () {
    final v = SubscribedVehicleModel.fromJson({
      'id': 1,
      'sb_vehicle_id': 'BSVEH1',
      'vehicle_files': _files,
    });
    expect(v.imageUrls, ['https://s3/p1.jpg', 'https://s3/p2.jpg']);
  });

  group('documents in the detail gallery (Vehicle Details Access plan)', () {
    BuyVehicleEntity vehicle(List<Map<String, String>> files) =>
        BuyVehicleEntity.fromSingleVehicleJson({
          'sb_vehicle_id': 'BSVEH1',
          'category_code': 'TRUCK',
          'category_name': 'Truck',
          'vehicle_files': files,
        });

    test('image RC / insurance go to the gallery, PDFs stay buttons', () {
      final v = vehicle([
        {'file_type': 'image', 'file_url': 'https://s3/p1.jpg'},
        {'file_type': 'rc', 'file_url': 'https://s3/rc1.jpg'},
        {'file_type': 'rc', 'file_url': 'https://s3/rc2.PNG?sig=1'},
        {'file_type': 'insurance', 'file_url': 'https://s3/ins.pdf?x=1'},
      ]);
      expect(v.galleryDocuments.map((d) => d.url), [
        'https://s3/rc1.jpg',
        'https://s3/rc2.PNG?sig=1',
      ]);
      expect(v.pdfDocuments.map((d) => d.url), ['https://s3/ins.pdf?x=1']);
      // List thumbnails still use photos only.
      expect(v.allImageUrls, ['https://s3/p1.jpg']);
    });

    test(
      'without the plan the backend sends photos only: gallery = photos',
      () {
        final v = vehicle([
          {'file_type': 'image', 'file_url': 'https://s3/p1.jpg'},
        ]);
        expect(v.galleryDocuments, isEmpty);
        expect(v.pdfDocuments, isEmpty);
      },
    );
  });

  test('isPdf ignores case and query strings', () {
    expect(
      const VehicleDocument(type: 'rc', url: 'https://s3/a.PDF?s=1').isPdf,
      isTrue,
    );
    expect(
      const VehicleDocument(type: 'rc', url: 'https://s3/a.jpg').isPdf,
      isFalse,
    );
  });
}
