class CategoryItem {
  final String id;
  final String title;

  /// Optional shorter label used where space is limited (e.g. home 3-col grid).
  /// Falls back to [title] when null.
  final String? shortTitle;

  final String assetPath;

  const CategoryItem({
    required this.id,
    required this.title,
    this.shortTitle,
    required this.assetPath,
  });
}
