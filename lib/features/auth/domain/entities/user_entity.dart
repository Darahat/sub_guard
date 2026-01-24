import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

/// User entity representing authenticated user
@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    @Default(AuthProvider.email) AuthProvider provider,
    @Default(false) bool isEmailVerified,
    @Default(false) bool isPremium,
    DateTime? premiumExpiryDate,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) = _UserEntity;

  const UserEntity._();

  /// Check if user is on free tier
  bool get isFreeTier => !isPremium;

  /// Check if premium is active
  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumExpiryDate == null) return true; // Lifetime premium
    return premiumExpiryDate!.isAfter(DateTime.now());
  }

  /// Get user initials for avatar
  String get initials {
    if (displayName == null || displayName!.isEmpty) {
      return email[0].toUpperCase();
    }
    final parts = displayName!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName![0].toUpperCase();
  }
}

/// Authentication provider enum
enum AuthProvider { email, google, apple, facebook }
