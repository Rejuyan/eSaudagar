import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/shared_prefs_provider.dart';

class UserProfile {
  final String name;
  final String phone;
  final String address;

  UserProfile({
    required this.name,
    required this.phone,
    required this.address,
  });

  UserProfile copyWith({
    String? name,
    String? phone,
    String? address,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? 'Rejuyan',
      phone: map['phone'] ?? '+880 1234 567890',
      address: map['address'] ?? 'House 12, Road 5, Block C\nBanani, Dhaka-1213\nBangladesh',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return UserProfileNotifier(prefs);
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final SharedPreferences _prefs;
  static const _key = 'user_profile';

  UserProfileNotifier(this._prefs) : super(_loadInitial(totalPrefs: _prefs));

  static UserProfile _loadInitial({required SharedPreferences totalPrefs}) {
    final data = totalPrefs.getString(_key);
    if (data != null) {
      return UserProfile.fromJson(data);
    }
    return UserProfile(
      name: 'Rejuyan',
      phone: '+880 1234 567890',
      address: 'House 12, Road 5, Block C\nBanani, Dhaka-1213\nBangladesh',
    );
  }

  Future<void> updateProfile({String? name, String? phone, String? address}) async {
    state = state.copyWith(
      name: name,
      phone: phone,
      address: address,
    );
    await _prefs.setString(_key, state.toJson());
  }
}
