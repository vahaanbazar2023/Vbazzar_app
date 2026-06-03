class InsuranceRequestEntity {
  final String userId;
  final String vehicleNo;
  final String insuranceType; // "comprehensive" | "third_party"
  final String claimType; // "yes" | "no"
  final String acceptedTerms; // "true" | "false"

  const InsuranceRequestEntity({
    required this.userId,
    required this.vehicleNo,
    required this.insuranceType,
    required this.claimType,
    required this.acceptedTerms,
  });
}