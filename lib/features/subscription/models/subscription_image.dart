class SubscriptionImage {
  final int id;
  final String s3Url;
  final String title;
  final String altText;
  final String imageType;
  final int priority;

  const SubscriptionImage({
    required this.id,
    required this.s3Url,
    required this.title,
    required this.altText,
    required this.imageType,
    required this.priority,
  });

  factory SubscriptionImage.fromJson(Map<String, dynamic> json) {
    return SubscriptionImage(
      id: json['id'] as int? ?? 0,
      s3Url: json['s3_url'] as String? ?? '',
      title: json['title'] as String? ?? '',
      altText: json['alt_text'] as String? ?? '',
      imageType: json['image_type'] as String? ?? '',
      priority: json['priority'] as int? ?? 0,
    );
  }
}
