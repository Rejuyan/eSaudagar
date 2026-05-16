import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:esaudagar/l10n/app_localizations.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/fade_in_route.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/wishlist_provider.dart';

import '../product/product_detail_screen.dart';
import '../../widgets/empty_state.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myWishlist),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: wishlist.isEmpty
          ? EmptyStateWidget(
              icon: Icons.favorite_border,
              title: l10n.wishlistEmpty,
              description: 'Items you love will appear here.',
              onActionPressed: () {
                ref.read(navigationProvider.notifier).setIndex(0);
              },
              actionLabel: 'Start Exploring',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final product = wishlist[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      FadeInRoute(page: ProductDetailScreen(product: product)),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.softShadows,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: product.images.isNotEmpty ? product.images.first : '',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey, width: 80, height: 80),
                            errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '৳${product.price.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            ref.read(wishlistProvider.notifier).toggleWishlist(product);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
