import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

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

  /// Request storage permission
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we need different permissions
      if (await Permission.photos.isGranted ||
          await Permission.videos.isGranted) {
        return true;
      }

      // Try to request storage permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      // If storage is permanently denied, try manage external storage
      if (status.isPermanentlyDenied) {
        final manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus.isGranted;
      }

      return status.isGranted;
    } else if (Platform.isIOS) {
      // iOS doesn't require explicit permission for app's document directory
      return true;
    }

    return false;
  }

  /// Get appropriate download directory based on platform
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // For Android, try multiple paths for Downloads directory
      final possiblePaths = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/sdcard/Download',
        '/sdcard/Downloads',
      ];

      for (final path in possiblePaths) {
        try {
          final directory = Directory(path);
          if (await directory.exists()) {
            debugPrint('✅ [Download] Using directory: $path');
            return directory;
          }
        } catch (e) {
          debugPrint('⚠️ Could not access $path: $e');
        }
      }

      // If none of the standard paths work, use external storage
      debugPrint(
        '⚠️ Standard Downloads paths not accessible, using external storage',
      );
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        // Create a Downloads folder in external storage
        final downloadDir = Directory('${directory.path}/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        debugPrint('✅ [Download] Created directory: ${downloadDir.path}');
        return downloadDir;
      }
    } else if (Platform.isIOS) {
      // For iOS, save to app's documents directory (accessible via Files app)
      final directory = await getApplicationDocumentsDirectory();
      debugPrint('✅ [Download] Using iOS documents: ${directory.path}');
      return directory;
    }

    // Final fallback to app's documents directory
    final fallback = await getApplicationDocumentsDirectory();
    debugPrint('⚠️ [Download] Using fallback directory: ${fallback.path}');
    return fallback;
  }

  /// Open the downloaded file (optional helper method)
  Future<void> openFile(String filePath) async {
    // This would require a plugin like open_file or url_launcher
    // For now, just log the path
    debugPrint('📂 File location: $filePath');
  }
}
