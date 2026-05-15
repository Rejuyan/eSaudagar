class Product {
  final String productId;
  final String title;
  final String description;
  final double price;
  final int stockCount;
  final String category;
  final List<String> images;
  final List<String> searchTags;
  final double rating;
  final int reviewCount;

  Product({
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    required this.stockCount,
    required this.category,
    required this.images,
    required this.searchTags,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: map['productId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      stockCount: map['stockCount'] ?? 0,
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      searchTags: List<String>.from(map['searchTags'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
    );
  }

  factory Product.fromFirestore(Map<String, dynamic> map, String id) {
    return Product(
      productId: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      stockCount: map['stockCount'] ?? 0,
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      searchTags: List<String>.from(map['searchTags'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'description': description,
      'price': price,
      'stockCount': stockCount,
      'category': category,
      'images': images,
      'searchTags': searchTags,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}
