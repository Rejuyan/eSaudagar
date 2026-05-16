import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    Product(
      productId: '5',
      title: 'Men\'s Casual Denim Jacket',
      description: 'Classic denim jacket with a modern fit. Durable and perfect for all seasons.',
      price: 3500,
      stockCount: 80,
      category: 'Fashion',
      images: [
        'https://images.unsplash.com/photo-1576871333021-d5d4469d7b4a?q=80&w=1000&auto=format&fit=crop',
      ],
      searchTags: ['jacket', 'denim', 'fashion', 'men'],
      rating: 4.6,
      reviewCount: 215,
    ),
    Product(
      productId: '6',
      title: 'Pro Leather Basketball',
      description: 'Official size and weight basketball for indoor and outdoor play. Superior grip and control.',
      price: 2500,
      stockCount: 100,
      category: 'Sports',
      images: [
        'https://images.unsplash.com/photo-1519861531473-9200262188bf?q=80&w=1000&auto=format&fit=crop',
      ],
      searchTags: ['basketball', 'sports', 'ball', 'fitness'],
      rating: 4.7,
      reviewCount: 156,
    ),
    Product(
      productId: '7',
      title: '"The Flutter Apprentice" Book',
      description: 'Master Flutter and Dart with this comprehensive guide to mobile development.',
      price: 4500,
      stockCount: 30,
      category: 'Books',
      images: [
        'https://images.unsplash.com/photo-1589998059171-988d887df646?q=80&w=1000&auto=format&fit=crop',
      ],
      searchTags: ['book', 'flutter', 'programming', 'dart'],
      rating: 4.9,
      reviewCount: 45,
    ),
    Product(
      productId: '8',
      title: 'Summer Floral Dress',
      description: 'Lightweight and breathable floral dress for the perfect summer look.',
      price: 2800,
      stockCount: 60,
      category: 'Fashion',
      images: [
        'https://images.unsplash.com/photo-1515377905703-c4788e51af15?q=80&w=1000&auto=format&fit=crop',
      ],
      searchTags: ['dress', 'summer', 'fashion', 'women'],
      rating: 4.4,
      reviewCount: 89,
    ),
    Product(
      productId: '9',
      title: 'Yoga Starter Kit',
      description: 'Complete kit including a non-slip mat, blocks, and a strap for your yoga practice.',
      price: 5200,
      stockCount: 25,
      category: 'Sports',
      images: [
        'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=1000&auto=format&fit=crop',
      ],
      searchTags: ['yoga', 'fitness', 'mat', 'sports'],
      rating: 4.8,
      reviewCount: 72,
    ),
    Product(
      productId: '10',
      title: 'Luxury Silk Saree',
      description: 'Exquisite hand-woven silk saree with intricate gold zari work. Perfect for weddings and special occasions.',
      price: 25000,
      stockCount: 10,
      category: 'Dress',
      images: [
        'https://images.unsplash.com/photo-1610030469983-98e550d6193c?q=80&w=1000&auto=format&fit=crop',
      ],
      searchTags: ['saree', 'silk', 'dress', 'traditional', 'wedding'],
      rating: 4.9,
      reviewCount: 28,
    ),
    Product(
      productId: '11',
      title: 'Casual Summer T-Shirt',
      description: '100% organic cotton T-shirt, breathable and soft for everyday wear.',
      price: 1200,
      stockCount: 150,
      category: 'Dress',
      images: [
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=1000&auto=format&fit=crop',
      ],
      searchTags: ['tshirt', 'casual', 'cotton', 'dress', 'summer'],
      rating: 4.5,
      reviewCount: 142,
    ),
    Product(
      productId: '12',
      title: 'Matte Liquid Lipstick',
      description: 'Long-lasting, smudge-proof matte lipstick with a velvet finish. Available in various shades.',
      price: 1800,
      stockCount: 200,
      category: 'Cosmetics',
      images: [
        'https://images.unsplash.com/photo-1586776977607-310e9c725c37?q=80&w=1000&auto=format&fit=crop',
      ],
      searchTags: ['lipstick', 'makeup', 'cosmetics', 'matte'],
      rating: 4.7,
      reviewCount: 310,
    ),
    Product(
      productId: '13',
      title: 'Organic Face Serum',
      description: 'Hydrating face serum with Vitamin C and Hyaluronic acid for a glowing complexion.',
      price: 3200,
      stockCount: 45,
      category: 'Cosmetics',
      images: [
        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?q=80&w=1000&auto=format&fit=crop',
      ],
      searchTags: ['serum', 'skincare', 'cosmetics', 'organic'],
      rating: 4.8,
      reviewCount: 85,
    ),
    Product(
      productId: '14',
      title: 'Premium Basmati Rice',
      description: 'Long-grain, aromatic basmati rice aged for 2 years for the finest taste.',
      price: 850,
      stockCount: 500,
      category: 'Groceries',
      images: [
        'https://images.unsplash.com/photo-1586201327693-866199f12179?q=80&w=1000&auto=format&fit=crop',
      ],
      searchTags: ['rice', 'groceries', 'food', 'basmati'],
      rating: 4.6,
      reviewCount: 120,
    ),
    Product(
      productId: '15',
      title: 'Raw Organic Honey',
      description: '100% pure, unfiltered raw honey collected from organic wild-flower hives.',
      price: 1500,
      stockCount: 75,
      category: 'Groceries',
      images: [
        'https://images.unsplash.com/photo-1587049352846-4a222e784d38?q=80&w=1000&auto=format&fit=crop',
      ],
      searchTags: ['honey', 'groceries', 'organic', 'food'],
      rating: 4.9,
      reviewCount: 64,
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
      debugPrint('Error seeding database: $e');
    }
  }

  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        debugPrint('Firestore products collection is empty. Using dummy data fallback.');
        return _dummyProducts;
      }
      return snapshot.docs.map((doc) => Product.fromFirestore(doc.data(), doc.id)).toList();
    }).handleError((error) {
      debugPrint('Error fetching products from Firestore: $error');
      return _dummyProducts;
    });
  }
}
