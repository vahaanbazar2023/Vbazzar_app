class FinanceRequestEntity {
  final String userId;
  final String vehicleNo;
  final String vehicleState;
  final String vehicleCity;
  final String fleetSize; // optional, can be empty
  final String vehicleLocation;
  final String applicantMobileNum;
  final String coApplicantDetails; // "yes" | "no"
  final String coApplicantMobileNum; // optional, can be empty

  const FinanceRequestEntity({
    required this.userId,
    required this.vehicleNo,
    required this.vehicleState,
    required this.vehicleCity,
    required this.fleetSize,
    required this.vehicleLocation,
    required this.applicantMobileNum,
    required this.coApplicantDetails,
    required this.coApplicantMobileNum,
  });
}