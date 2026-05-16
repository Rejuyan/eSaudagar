import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/shared_prefs_provider.dart';

class UserProfile {
  final String name;
  final String phone;
  final String address;

  UserProfile({required this.name, required this.phone, required this.address});

  UserProfile copyWith({String? name, String? phone, String? address}) {
    return UserProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'phone': phone, 'address': address};
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? 'Rejuyan',
      phone: map['phone'] ?? '+880 1234 567890',
      address:
          map['address'] ??
          'House 12, Road 5, Block C\nBanani, Dhaka-1213\nBangladesh',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(
  () {
    return UserProfileNotifier();
  },
);

class UserProfileNotifier extends Notifier<UserProfile> {
  static const _key = 'user_profile';

  @override
  UserProfile build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final data = prefs.getString(_key);
    if (data != null) {
      try {
        return UserProfile.fromJson(data);
      } catch (e) {
        // Fallback if data is corrupted
      }
    }
    return UserProfile(
      name: 'Rejuyan',
      phone: '+880 1234 567890',
      address: 'House 12, Road 5, Block C\nBanani, Dhaka-1213\nBangladesh',
    );
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    final prefs = ref.read(sharedPrefsProvider);
    state = state.copyWith(name: name, phone: phone, address: address);
    await prefs.setString(_key, state.toJson());
  }
}
