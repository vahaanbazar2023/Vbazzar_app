import 'inspection_vehicle_model.dart';

class MyInspectionsResponse {
  final bool success;
  final String message;
  final List<InspectionVehicleModel> inspections;
  final InspectionPagination pagination;

  const MyInspectionsResponse({
    required this.success,
    required this.message,
    required this.inspections,
    required this.pagination,
  });

  factory MyInspectionsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return MyInspectionsResponse(
      success: data['success'] as bool? ?? false,
      message: data['message']?.toString() ?? '',
      inspections: (data['data'] as List<dynamic>?)
              ?.map((e) =>
                  InspectionVehicleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: InspectionPagination.fromJson(
          data['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class InspectionPagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int limit;
  final bool hasNext;
  final bool hasPrevious;

  const InspectionPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.limit,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory InspectionPagination.fromJson(Map<String, dynamic> json) {
    return InspectionPagination(
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      totalItems: json['total_items'] as int? ?? 0,
      limit: (json['per_page'] ?? json['limit']) as int? ?? 10,
      hasNext: json['has_next'] as bool? ?? false,
      hasPrevious: json['has_previous'] as bool? ?? false,
    );
  }
}