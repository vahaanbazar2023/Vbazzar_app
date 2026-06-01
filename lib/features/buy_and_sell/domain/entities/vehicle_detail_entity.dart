class VehicleDetailEntity {
  final String id;
  final String? categoryCode;
  final String? categoryName;
  final String? brandCode;
  final String? brandName;
  final String? model;
  final String? year;
  final String? tonnage;
  final String? kv;
  final String? noOfTyres;
  final String? fuelType;
  final String? bodyType;
  final String? state;
  final String? imageUrl;
  final List<String>? images;
  final String? description;
  final double? price;
  final String? sellerName;
  final String? sellerPhone;

  const VehicleDetailEntity({
    required this.id,
    this.categoryCode,
    this.categoryName,
    this.brandCode,
    this.brandName,
    this.model,
    this.year,
    this.tonnage,
    this.kv,
    this.noOfTyres,
    this.fuelType,
    this.bodyType,
    this.state,
    this.imageUrl,
    this.images,
    this.description,
    this.price,
    this.sellerName,
    this.sellerPhone,
  });
}
