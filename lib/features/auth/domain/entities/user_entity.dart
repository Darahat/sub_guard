/// User entity representing authenticated user
class UserEntity {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final AuthProvider provider;
  final bool isEmailVerified;
  final bool isPremium;
  final DateTime? premiumExpiryDate;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.provider = AuthProvider.email,
    this.isEmailVerified = false,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.createdAt,
    this.lastLoginAt,
  });

  /// Copy with updated fields
  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    AuthProvider? provider,
    bool? isEmailVerified,
    bool? isPremium,
    DateTime? premiumExpiryDate,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      provider: provider ?? this.provider,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

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
      return email.isNotEmpty ? email[0].toUpperCase() : 'U';
    }
    final parts = displayName!.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName![0].toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Authentication provider enum
enum AuthProvider { email, google, apple, facebook }
