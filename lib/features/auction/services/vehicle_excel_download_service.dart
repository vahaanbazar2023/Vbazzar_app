import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/network/network_service.dart';
import '../../../core/network/endpoints/api_endpoints.dart';

class VehicleExcelDownloadService {
  final NetworkService _network;

  VehicleExcelDownloadService({NetworkService? network})
    : _network = network ?? NetworkService.to;

  /// Download vehicle listing Excel file for a specific auction
  Future<String> downloadVehicleExcel({
    required String auctionId,
    required String userId,
  }) async {
    try {
      // No storage permission needed: the file is saved in the app's own
      // storage and then opened / shared (Android 11+ blocks direct writes to
      // the public Downloads folder, and Android 13+ has no storage permission).
      // Get download directory
      final directory = await _getDownloadDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'vehicles_${auctionId}_$timestamp.xlsx';
      final filePath = '${directory.path}/$fileName';

      debugPrint('📥 [Download] Starting download to: $filePath');

      // API expects POST request with body data
      // Response is binary Excel file data, not JSON
      final requestBody = {'auction_id': auctionId, 'user_id': userId};

      // Make POST request with responseType bytes to get raw file data
      final response = await _network.post(
        ApiEndpoints.vehicleExcelDownload,
        data: requestBody,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        final file = File(filePath);

        // Delete file if it already exists (shouldn't happen with timestamp, but just in case)
        if (await file.exists()) {
          await file.delete();
          debugPrint('🗑️ [Download] Deleted existing file');
        }

        // Response.data is now List<int> (bytes) because of ResponseType.bytes
        if (response.data is List<int>) {
          await file.writeAsBytes(response.data as List<int>, flush: true);
        } else if (response.data is List) {
          final bytes = (response.data as List).cast<int>();
          await file.writeAsBytes(bytes, flush: true);
        } else {
          throw Exception(
            'Unexpected response data type: ${response.data.runtimeType}',
          );
        }

        debugPrint('✅ [Download] File saved successfully: $filePath');
        debugPrint('📂 [Download] File size: ${await file.length()} bytes');

        // Notify media scanner on Android so file appears in Downloads
        if (Platform.isAndroid) {
          try {
            // This makes the file visible in the device's Downloads folder
            await Process.run('am', [
              'broadcast',
              '-a',
              'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
              '-d',
              'file://$filePath',
            ]);
            debugPrint('📢 [Download] Media scanner notified');
          } catch (e) {
            debugPrint('⚠️ [Download] Could not notify media scanner: $e');
          }
        }

        return filePath;
      } else {
        throw Exception('Download failed with status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Download] Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// App-scoped directory (no permission required on any Android version / iOS).
  Future<Directory> _getDownloadDirectory() async {
    Directory? base;
    if (Platform.isAndroid) {
      base = await getExternalStorageDirectory();
    }
    base ??= await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/Downloads');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    debugPrint('✅ [Download] Using directory: ${dir.path}');
    return dir;
  }

  /// Open the downloaded file in a spreadsheet app; if none is installed,
  /// fall back to the share sheet so the user can save it anywhere.
  Future<void> openFile(String filePath) async {
    final result = await OpenFilex.open(filePath);
    if (result.type != ResultType.done) {
      debugPrint('⚠️ [Download] No viewer (${result.message}); sharing instead');
      await Share.shareXFiles([XFile(filePath)]);
    }
  }
}
