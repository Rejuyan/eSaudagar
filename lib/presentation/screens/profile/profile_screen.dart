import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';
import 'edit_profile_screen.dart';
import '../../../core/utils/fade_in_route.dart';
import 'package:esaudagar/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final profile = ref.watch(userProfileProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            profile.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? l10n.notLoggedIn,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.accountInformation,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.softShadows,
            ),
            child: Column(
              children: [
                _buildProfileItem(
                  context,
                  icon: Icons.email_outlined,
                  title: l10n.email,
                  subtitle: user?.email ?? l10n.notLoggedIn,
                ),
                const Divider(height: 32),
                _buildProfileItem(
                  context,
                  icon: Icons.location_on_outlined,
                  title: l10n.shippingAddress,
                  subtitle: profile.address,
                ),
                const Divider(height: 32),
                _buildProfileItem(
                  context,
                  icon: Icons.phone_outlined,
                  title: l10n.phoneNumber,
                  subtitle: profile.phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                FadeInRoute(page: const OrdersScreen()),
              );
            },
            icon: const Icon(Icons.inventory_2_outlined),
            label: Text(l10n.myOrders),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                FadeInRoute(page: const WishlistScreen()),
              );
            },
            icon: const Icon(Icons.favorite_outline),
            label: Text(l10n.myWishlist),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.settings,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.softShadows,
            ),
            child: Column(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final settings = ref.watch(settingsProvider);
                    return SwitchListTile(
                      title: Text(l10n.darkMode),
                      secondary: const Icon(Icons.dark_mode_outlined),
                      value: settings.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).toggleTheme();
                      },
                    );
                  },
                ),
                const Divider(),
                Consumer(
                  builder: (context, ref, child) {
                    final settings = ref.watch(settingsProvider);
                    final isBn = settings.locale.languageCode == 'bn';
                    return SwitchListTile(
                      title: Text(l10n.language),
                      secondary: const Icon(Icons.language_outlined),
                      value: isBn,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).setLocale(value ? 'bn' : 'en');
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                FadeInRoute(page: const EditProfileScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(l10n.editProfile),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
