/// A vehicle from our auction listings found by its registration number
/// (`POST /api/v1/approved-veh/appr-veh-auction-lookup`), used to prefill the
/// Approved Vehicle sell form.
class AuctionVehicleMatch {
  final String vehicleId;
  final String? make;
  final String? model;
  final int? year;
  final String? chassisNumber;
  final String? description;
  final String? yardName;
  final String? yardLocation;

  /// Photo URLs (.jpg/.jpeg), in display order.
  final List<String> images;

  const AuctionVehicleMatch({
    required this.vehicleId,
    this.make,
    this.model,
    this.year,
    this.chassisNumber,
    this.description,
    this.yardName,
    this.yardLocation,
    this.images = const [],
  });

  /// From the endpoint's `data` object.
  factory AuctionVehicleMatch.fromJson(Map<String, dynamic> data) {
    final v = (data['vehicle'] as Map?)?.cast<String, dynamic>() ?? const {};
    String? text(Object? x) {
      final s = x?.toString().trim() ?? '';
      return s.isEmpty ? null : s;
    }

    final year = v['year_of_manufacturing'];
    return AuctionVehicleMatch(
      vehicleId: data['vehicle_id']?.toString() ?? '',
      make: text(v['make']),
      model: text(v['model']),
      year: year is int ? year : int.tryParse('${year ?? ''}'),
      chassisNumber: text(v['chassis_number']),
      description: text(v['asset_description']),
      yardName: text(v['yard_name']),
      yardLocation: text(v['yard_location']),
      images: [
        for (final u in (v['images'] as List?) ?? const [])
          if (text(u) != null) text(u)!,
      ],
    );
  }

  /// The brand in [brands] (`{brand_code, brand_name}`) that is this vehicle's
  /// make, ignoring case, spaces and punctuation. Auction makes are often
  /// shorter or longer than our brand names, so, best first:
  /// 1. the same name ("MARUTI SUZUKI" = "Maruti Suzuki");
  /// 2. the make starts with the brand ("TATA MOTORS LTD" → "Tata Motors";
  ///    the longest such brand wins);
  /// 3. the brand starts with the make ("HERO" → "Hero MotoCorp"; the
  ///    shortest such brand wins);
  /// 4. the same first word ("MAHINDRA AND MAHINDRA" → "Mahindra"; the
  ///    shortest such brand wins).
  /// Null when nothing matches.
  Map<String, String>? matchBrand(List<Map<String, String>> brands) {
    String norm(String? s) =>
        (s ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    String firstWord(String? s) {
      final words = (s ?? '')
          .toLowerCase()
          .split(RegExp(r'[^a-z0-9]+'))
          .where((w) => w.isNotEmpty);
      return words.isEmpty ? '' : words.first;
    }

    final m = norm(make);
    if (m.isEmpty) return null;
    final mFirst = firstWord(make);
    Map<String, String>? pick(
      bool Function(String n) ok, {
      required bool longest,
    }) {
      Map<String, String>? best;
      var bestLen = 0;
      for (final b in brands) {
        final n = norm(b['brand_name']);
        if (n.isEmpty || !ok(n)) continue;
        if (best == null ||
            (longest ? n.length > bestLen : n.length < bestLen)) {
          best = b;
          bestLen = n.length;
        }
      }
      return best;
    }

    // Brand names keyed by their first word, for step 4.
    final firstWords = {
      for (final b in brands) norm(b['brand_name']): firstWord(b['brand_name']),
    };
    return pick((n) => n == m, longest: true) ??
        pick((n) => m.startsWith(n), longest: true) ??
        pick((n) => n.startsWith(m), longest: false) ??
        (mFirst.length < 2
            ? null
            : pick((n) => firstWords[n] == mFirst, longest: false));
  }
}
