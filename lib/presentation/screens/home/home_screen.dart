import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esaudagar/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/search_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/product_provider.dart';

import '../../widgets/shimmer_skeletons.dart';
import '../../widgets/empty_state.dart';
import '../../../core/utils/fade_in_route.dart';
import '../../../domain/models/product_model.dart';
import '../product/product_detail_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';

// Category icon and color mapping for visual richness
final _categoryMeta = <String, (IconData, Color)>{
  'Electronics': (Icons.devices_outlined, Color(0xFF3B82F6)),
  'Accessories': (Icons.watch_outlined, Color(0xFF8B5CF6)),
  'Furniture': (Icons.chair_outlined, Color(0xFF10B981)),
  'Fashion': (Icons.checkroom_outlined, Color(0xFFEC4899)),
  'Sports': (Icons.sports_soccer_outlined, Color(0xFFF59E0B)),
  'Books': (Icons.menu_book_outlined, Color(0xFF6366F1)),
  'Dress': (Icons.checkroom_outlined, Color(0xFFF43F5E)),
  'Cosmetics': (Icons.face_retouching_natural_outlined, Color(0xFFD946EF)),
  'Groceries': (Icons.shopping_basket_outlined, Color(0xFF10B981)),
};


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cartItems = ref.watch(cartProvider);
    final cartCount = cartItems.fold(0, (sum, item) => sum + item.quantity);
    final currentIndex = ref.watch(navigationProvider);

    final List<Widget> pages = [
      _buildHomeContent(context, ref),
      _buildSearchContent(context, ref),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 32,
          errorBuilder: (context, error, stackTrace) => Text(
            l10n.appTitle,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.noNotifications),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          return ref.refresh(productsProvider);
        },
        child: pages[currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            ref.read(navigationProvider.notifier).setIndex(index);
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.search_outlined),
              selectedIcon: const Icon(Icons.search),
              label: l10n.searchTab,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_cart),
              ),
              label: l10n.cart,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.softShadows,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcomeMessage,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.welcomeSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ─── FEATURE 3: Real Categories ───
        Text(
          l10n.topCategories,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildCategories(context, ref),
        const SizedBox(height: 24),

        // Section Header with active filter
        Consumer(
          builder: (context, ref, _) {
            final selected = ref.watch(selectedCategoryProvider);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selected ?? l10n.featuredProducts,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (selected != null)
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(selectedCategoryProvider.notifier).setCategory(null),
                    icon: const Icon(Icons.close, size: 16),
                    label: Text(l10n.clear),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        _buildSortSelector(context, ref),
        const SizedBox(height: 16),
        _buildProductGrid(context, ref),
      ],
    );
  }

  Widget _buildSortSelector(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(sortingProvider);

    final sortOptions = <ProductSort, String>{
      ProductSort.priceLowToHigh: 'Price: Low to High',
      ProductSort.priceHighToLow: 'Price: High to Low',
      ProductSort.ratingHighToLow: 'Highest Rated',
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Sort by: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        SizedBox(
          width: 160,
          child: DropdownButton<ProductSort>(
            value: currentSort,
            underline: const SizedBox(),
            isExpanded: true,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
            onChanged: (value) {
              if (value != null) {
                ref.read(sortingProvider.notifier).setSort(value);
              }
            },
            items: ProductSort.values.map((sort) {
              return DropdownMenuItem<ProductSort>(
                value: sort,
                child: Text(sortOptions[sort] ?? 'Unknown'),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─── FEATURE 3: Real clickable category chips ───
  Widget _buildCategories(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final meta = _categoryMeta[cat];
              final icon = meta?.$1 ?? Icons.category_outlined;
              final color = meta?.$2 ?? Theme.of(context).colorScheme.primary;
              final selected = ref.watch(selectedCategoryProvider) == cat;

              return GestureDetector(
                onTap: () {
                  final notifier = ref.read(selectedCategoryProvider.notifier);
                  notifier.setCategory(selected ? null : cat);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 88,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: selected ? color : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? color : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: AppTheme.softShadows,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon,
                          size: 30, color: selected ? Colors.white : color),
                      const SizedBox(height: 8),
                      Text(
                        cat,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  selected ? Colors.white : Colors.grey[700],
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) => const CategorySkeleton(),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildProductGrid(BuildContext context, WidgetRef ref) {
    // Uses the sorted provider so category selection and sorting auto-update the grid
    final productsAsync = ref.watch(sortedProductsProvider);
    final l10n = AppLocalizations.of(context)!;

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.category_outlined,
            title: l10n.noProductsInCategory,
            description: 'Explore other categories to find what you looking for.',
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(context, ref, product);
          },
        );
      },
      loading: () => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => const ProductSkeleton(),
      ),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildProductCard(BuildContext context, WidgetRef ref, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          FadeInRoute(page: ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadows,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Hero(
                  tag: 'product_image_${product.productId}',
                  child: CachedNetworkImage(
                    imageUrl: product.images.isNotEmpty
                        ? product.images.first
                        : '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '৳${product.price.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${product.rating}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(cartProvider.notifier)
                              .addProduct(product);
                          final l10n = AppLocalizations.of(context)!;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${product.title} ${l10n.addedToCart}'),
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: l10n.viewCart,
                                onPressed: () {
                                  ref.read(navigationProvider.notifier).setIndex(2);
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchContent(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(searchResultsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).updateQuery(value);
            },
            decoration: InputDecoration(
              hintText: l10n.searchProducts,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).updateQuery('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Expanded(
          child: searchResults.when(
            data: (products) {
              if (products.isEmpty) {
                final query = ref.read(searchQueryProvider);
                if (query.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search,
                    title: l10n.startTypingToSearch,
                    description: 'Search for a product by name or category.',
                  );
                }
                return EmptyStateWidget(
                  icon: Icons.search_off,
                  title: l10n.noProductsFound,
                  description: 'Try a different keyword or browse categories.',
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(context, ref, products[index]);
                },
              );
            },
            loading: () => GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => const ProductSkeleton(),
            ),
            error: (error, stack) =>
                Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }
}
