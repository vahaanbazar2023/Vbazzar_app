/// Buy & Sell `vehicle_files` split into the photo gallery and documents.
///
/// The gallery (carousel / full-screen viewer) must show vehicle photos only.
/// RC and insurance files are documents: the backend sends them only to users
/// with the Vehicle Details Access plan (and to the seller), and the detail
/// screen lists them as separate buttons.
class VehicleDocument {
  /// Backend `file_type`: `rc` or `insurance`.
  final String type;
  final String url;

  const VehicleDocument({required this.type, required this.url});

  bool get isRc => type == 'rc';
  bool get isInsurance => type == 'insurance';
}

class VehicleFiles {
  final List<String> photoUrls;
  final List<VehicleDocument> documents;

  const VehicleFiles({this.photoUrls = const [], this.documents = const []});

  /// Parses the `vehicle_files` array of a Buy & Sell API response.
  ///
  /// `file_type == "image"` is a photo. A file with no `file_type` (older
  /// payloads) is treated as a photo. Anything else is a document.
  factory VehicleFiles.fromJson(Object? raw) {
    final photos = <String>[];
    final documents = <VehicleDocument>[];
    if (raw is! List) return const VehicleFiles();
    for (final file in raw) {
      if (file is! Map) continue;
      final url = (file['file_url'] ?? file['url'])?.toString() ?? '';
      if (url.isEmpty) continue;
      final type = (file['file_type'] ?? '').toString().trim().toLowerCase();
      if (type.isEmpty || type == 'image') {
        if (!photos.contains(url)) photos.add(url);
      } else {
        documents.add(VehicleDocument(type: type, url: url));
      }
    }
    return VehicleFiles(photoUrls: photos, documents: documents);
  }
}
