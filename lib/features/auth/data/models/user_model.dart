import '../../domain/entities/user_entity.dart';

/// User model for local storage
class UserModel {
  String uid;
  String email;
  String? displayName;
  String? photoUrl;
  String? phoneNumber;
  String provider;
  bool isEmailVerified;
  bool isPremium;
  DateTime? premiumExpiryDate;
  DateTime? createdAt;
  DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.provider = 'email',
    this.isEmailVerified = false,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.createdAt,
    this.lastLoginAt,
  });

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      provider: _parseProvider(provider),
      isEmailVerified: isEmailVerified,
      isPremium: isPremium,
      premiumExpiryDate: premiumExpiryDate,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  /// Create from domain entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      phoneNumber: entity.phoneNumber,
      provider: entity.provider.name,
      isEmailVerified: entity.isEmailVerified,
      isPremium: entity.isPremium,
      premiumExpiryDate: entity.premiumExpiryDate,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
    );
  }

  /// Create from Firebase User JSON
  factory UserModel.fromFirebase({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? provider,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      provider: provider ?? 'email',
      isEmailVerified: isEmailVerified ?? false,
      isPremium: false,
      premiumExpiryDate: null,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  /// Convert to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'provider': provider,
      'isEmailVerified': isEmailVerified,
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  /// Create from JSON Map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      provider: json['provider'] as String? ?? 'email',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      premiumExpiryDate: json['premiumExpiryDate'] != null
          ? DateTime.parse(json['premiumExpiryDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  /// Parse provider string to enum
  static AuthProvider _parseProvider(String provider) {
    return AuthProvider.values.firstWhere(
      (e) => e.name == provider,
      orElse: () => AuthProvider.email,
    );
  }
}
