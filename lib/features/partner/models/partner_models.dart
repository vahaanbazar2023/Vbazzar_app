/// Roles a customer can apply for. [apiValue] is what the backend expects.
enum PartnerRole {
  vendor('VENDOR'),
  mechanic('MECHANIC'),
  sparePartShop('SPARE_PART_SHOP');

  final String apiValue;
  const PartnerRole(this.apiValue);

  static PartnerRole? fromApi(String? value) {
    for (final r in PartnerRole.values) {
      if (r.apiValue == (value ?? '').toUpperCase()) return r;
    }
    return null;
  }
}

/// A partner request as returned by `POST /partner/request` and
/// `GET /partner/my-request`. Status: pending | approved | rejected.
class PartnerRequest {
  final String requestId;
  final String role;
  final String name;
  final String mobileNumber;
  final String businessName;
  final String status;
  final String? city;
  final String? state;
  final String? rejectionReason;
  final String? submittedAt;

  const PartnerRequest({
    required this.requestId,
    required this.role,
    required this.name,
    required this.mobileNumber,
    required this.businessName,
    required this.status,
    this.city,
    this.state,
    this.rejectionReason,
    this.submittedAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory PartnerRequest.fromJson(Map<String, dynamic> json) => PartnerRequest(
    requestId: json['request_id'] as String? ?? '',
    role: json['role'] as String? ?? '',
    name: json['name'] as String? ?? '',
    mobileNumber: json['mobile_number'] as String? ?? '',
    businessName: json['business_name'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    city: json['city'] as String?,
    state: json['state'] as String?,
    rejectionReason: json['rejection_reason'] as String?,
    submittedAt: json['submitted_at'] as String?,
  );
}

/// Body of `POST /partner/request`.
class PartnerRequestPayload {
  final String userId;
  final String role;
  final String name;
  final String mobileNumber;
  final String businessName;
  final String? aadhaarNumber;
  final double? latitude;
  final double? longitude;
  final String? location;
  final String? city;
  final String? state;

  const PartnerRequestPayload({
    required this.userId,
    required this.role,
    required this.name,
    required this.mobileNumber,
    required this.businessName,
    this.aadhaarNumber,
    this.latitude,
    this.longitude,
    this.location,
    this.city,
    this.state,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'role': role,
    'name': name,
    'mobile_number': mobileNumber,
    'business_name': businessName,
    if (aadhaarNumber != null && aadhaarNumber!.isNotEmpty)
      'aadhaar_number': aadhaarNumber,
    if (latitude != null && longitude != null) ...{
      'latitude': latitude,
      'longitude': longitude,
    },
    if (location != null && location!.isNotEmpty) 'location': location,
    if (city != null && city!.isNotEmpty) 'city': city,
    if (state != null && state!.isNotEmpty) 'state': state,
  };
}

/// Envelope the backend wraps every response in. Business errors come back as
/// HTTP 200 with `status: "error"` and the real code in `code`.
class PartnerApiResult<T> {
  final bool success;
  final int code;
  final String message;
  final String? errorCode;
  final T? data;

  const PartnerApiResult({
    required this.success,
    required this.code,
    required this.message,
    this.errorCode,
    this.data,
  });
}
