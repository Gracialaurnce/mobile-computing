// lib/models/product.dart
class Product {
  final String productId;
  final String productName;
  final String category;
  final String discountedPrice;
  final String actualPrice;
  final String discountPercentage;
  final String rating;
  final String ratingCount;
  final String aboutProduct;
  final List<String> userIds;
  final List<String> userNames;
  final List<String> reviewIds;
  final List<String> reviewTitles;
  final List<String> reviewContents;
  final String imgLink;
  final String productLink;

  Product({
    required this.productId,
    required this.productName,
    required this.category,
    required this.discountedPrice,
    required this.actualPrice,
    required this.discountPercentage,
    required this.rating,
    required this.ratingCount,
    required this.aboutProduct,
    required this.userIds,
    required this.userNames,
    required this.reviewIds,
    required this.reviewTitles,
    required this.reviewContents,
    required this.imgLink,
    required this.productLink,
  });

  factory Product.fromCsv(Map<String, dynamic> csvData) {
    return Product(
      productId: csvData['product_id'] ?? '',
      productName: csvData['product_name']?.replaceAll('"', '') ?? '',
      category: csvData['category'] ?? '',
      discountedPrice: csvData['discounted_price'] ?? '',
      actualPrice: csvData['actual_price'] ?? '',
      discountPercentage: csvData['discount_percentage'] ?? '',
      rating: csvData['rating'] ?? '',
      ratingCount: csvData['rating_count'] ?? '',
      aboutProduct: csvData['about_product'] ?? '',
      userIds: (csvData['user_id']?.toString().split(',') ?? []),
      userNames: (csvData['user_name']?.toString().split(',') ?? []),
      reviewIds: (csvData['review_id']?.toString().split(',') ?? []),
      reviewTitles: (csvData['review_title']?.toString().split(',') ?? []),
      reviewContents: (csvData['review_content']?.toString().split(',') ?? []),
      imgLink: csvData['img_link'] ?? '',
      productLink: csvData['product_link'] ?? '',
    );
  }

  double get ratingValue => double.tryParse(rating) ?? 0.0;
  int get ratingCountValue =>
      int.tryParse(ratingCount.replaceAll(',', '')) ?? 0;
  double get discountPercentageValue =>
      double.tryParse(discountPercentage.replaceAll('%', '')) ?? 0.0;
  double get currentPriceValue =>
      double.tryParse(
        discountedPrice.replaceAll('₹', '').replaceAll(',', ''),
      ) ??
      0.0;
  double get originalPriceValue =>
      double.tryParse(actualPrice.replaceAll('₹', '').replaceAll(',', '')) ??
      0.0;

  List<String> get categories => category.split('|');
}
