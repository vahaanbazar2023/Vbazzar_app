import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
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
      // The file is first written to the app's own storage (no permission
      // needed); saveToDevice() then lets the user save it to Downloads or any
      // folder through the system "Save as" dialog.
      // Get download directory
      final directory = await _getDownloadDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // Fallback name; replaced below by the server's own filename when sent.
      var fileName = 'vehicles_${auctionId}_$timestamp.xlsx';
      var filePath = '${directory.path}/$fileName';

      debugPrint('📥 [Download] Starting download for auction $auctionId');

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
        // Prefer the server's name, e.g. vehicles_TVS_Telangana_4W_20261017_205034.xlsx
        final serverName = filenameFromContentDisposition(
          response.headers.value('content-disposition'),
        );
        if (serverName != null) {
          fileName = serverName;
          filePath = '${directory.path}/$fileName';
        }
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

  /// Saves the downloaded file where the user can find it, via the system
  /// "Save as" dialog (works on every Android version without a storage
  /// permission, and on iOS). Returns false if the user cancelled. If the
  /// dialog can't be shown, falls back to the share sheet.
  Future<bool> saveToDevice(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final saved = await FilePicker.platform.saveFile(
        dialogTitle: 'Save vehicle list',
        fileName: filePath.split(Platform.pathSeparator).last,
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
        bytes: bytes,
      );
      debugPrint('💾 [Download] saveFile result: $saved');
      return saved != null;
    } catch (e) {
      debugPrint('⚠️ [Download] Save dialog failed ($e); sharing instead');
      await Share.shareXFiles([XFile(filePath)]);
      return true;
    }
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

/// Extracts a safe `.xlsx` filename from a Content-Disposition header, or null.
/// Handles `filename="x.xlsx"`, `filename=x.xlsx` and `filename*=UTF-8''x.xlsx`.
String? filenameFromContentDisposition(String? header) {
  if (header == null || header.isEmpty) return null;
  final star = RegExp(r"filename\*\s*=\s*[^']*'[^']*'([^;]+)", caseSensitive: false)
      .firstMatch(header);
  final plain = RegExp(r'filename\s*=\s*"?([^";]+)"?', caseSensitive: false)
      .firstMatch(header);
  final raw = (star?.group(1) ?? plain?.group(1))?.trim();
  if (raw == null || raw.isEmpty) return null;
  var name = raw;
  try {
    name = Uri.decodeComponent(raw);
  } catch (_) {}
  // Keep it a plain file name: no folders, no odd characters.
  name = name.split('/').last.split('\\').last;
  name = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  if (name.isEmpty || name.startsWith('.')) return null;
  if (!name.toLowerCase().endsWith('.xlsx')) name = '$name.xlsx';
  return name;
}
