import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Product> _dummyProducts = [
    Product(
      productId: '1',
      title: 'Premium Wireless Headphones',
      description: 'High-fidelity audio with active noise cancellation. Features up to 30 hours of battery life and plush ear cushions for all-day comfort.',
      price: 15000,
      stockCount: 50,
      category: 'Electronics',
      images: [
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1000&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1583394838336-acd977736f90?q=80&w=1000&auto=format&fit=crop'
      ],
      searchTags: ['headphones', 'audio', 'wireless', 'music'],
      rating: 4.8,
      reviewCount: 342,
    ),
    Product(
      productId: '2',
      title: 'Minimalist Smartwatch',
      description: 'Track your fitness and stay connected with this sleek smartwatch. Water resistant and features a heart rate monitor.',
      price: 8500,
      stockCount: 120,
      category: 'Accessories',
      images: [
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1000&auto=format&fit=crop',
      ],
      searchTags: ['watch', 'smart', 'fitness', 'accessory'],
      rating: 4.5,
      reviewCount: 128,
    ),
    Product(
      productId: '3',
      title: 'Ergonomic Office Chair',
      description: 'Lumbar support and breathable mesh for long working hours. Adjustable armrests and seat height.',
      price: 12000,
      stockCount: 15,
      category: 'Furniture',
      images: [
        'https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1?q=80&w=1000&auto=format&fit=crop',
      ],
      searchTags: ['chair', 'office', 'furniture', 'ergonomic'],
      rating: 4.3,
      reviewCount: 56,
    ),
    Product(
      productId: '4',
      title: 'Mechanical Gaming Keyboard',
      description: 'Tactile switches with customizable RGB lighting. Full anti-ghosting and macro support.',
      price: 6500,
      stockCount: 40,
      category: 'Electronics',
      images: [
        'https://images.unsplash.com/photo-1595225476474-87563907a212?q=80&w=1000&auto=format&fit=crop',
      ],
      searchTags: ['keyboard', 'gaming', 'rgb', 'mechanical'],
      rating: 4.9,
      reviewCount: 890,
    ),
  ];

  ProductRepository() {
    _seedDatabaseIfEmpty();
  }

  Future<void> _seedDatabaseIfEmpty() async {
    try {
      final snap = await _firestore.collection('products').limit(1).get();
      if (snap.docs.isEmpty) {
        for (final product in _dummyProducts) {
          await _firestore.collection('products').doc(product.productId).set(product.toMap());
        }
      }
    } catch (e) {
      // Ignore if Firebase isn't correctly configured yet
    }
  }

  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _dummyProducts; // Fallback to dummy data if DB is empty/unreachable
      }
      return snapshot.docs.map((doc) => Product.fromFirestore(doc.data(), doc.id)).toList();
    }).handleError((_) {
      return _dummyProducts; // Fallback if no network or unconfigured
    });
  }
}
