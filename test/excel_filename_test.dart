import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/features/auction/services/vehicle_excel_download_service.dart';

void main() {
  test('reads the filename the server sends', () {
    expect(
      filenameFromContentDisposition(
        'attachment; filename=vehicles_TVS_Telangana_4W_20261017_205034.xlsx',
      ),
      'vehicles_TVS_Telangana_4W_20261017_205034.xlsx',
    );
    expect(
      filenameFromContentDisposition('attachment; filename="my list.xlsx"'),
      'my_list.xlsx',
    );
    expect(
      filenameFromContentDisposition("attachment; filename*=UTF-8''cars%20list.xlsx"),
      'cars_list.xlsx',
    );
  });

  test('is safe and always ends in .xlsx', () {
    expect(filenameFromContentDisposition('attachment; filename=../../etc/passwd'), 'passwd.xlsx');
    expect(filenameFromContentDisposition('attachment; filename=report'), 'report.xlsx');
    expect(filenameFromContentDisposition('attachment; filename=.hidden.xlsx'), isNull);
  });

  test('returns null when there is no usable name', () {
    expect(filenameFromContentDisposition(null), isNull);
    expect(filenameFromContentDisposition(''), isNull);
    expect(filenameFromContentDisposition('attachment'), isNull);
  });
}
