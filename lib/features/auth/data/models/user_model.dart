import 'package:isar/isar.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// User model for Isar database
@Collection()
class UserModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String uid;

  @Index()
  late String email;

  String? displayName;
  String? photoUrl;
  String? phoneNumber;
  late String provider;
  late bool isEmailVerified;
  late bool isPremium;
  DateTime? premiumExpiryDate;
  DateTime? createdAt;
  DateTime? lastLoginAt;

  // Empty constructor for Isar
  UserModel();

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
    return UserModel()
      ..uid = entity.id
      ..email = entity.email
      ..displayName = entity.displayName
      ..photoUrl = entity.photoUrl
      ..phoneNumber = entity.phoneNumber
      ..provider = entity.provider.name
      ..isEmailVerified = entity.isEmailVerified
      ..isPremium = entity.isPremium
      ..premiumExpiryDate = entity.premiumExpiryDate
      ..createdAt = entity.createdAt
      ..lastLoginAt = entity.lastLoginAt;
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
    return UserModel()
      ..uid = uid
      ..email = email
      ..displayName = displayName
      ..photoUrl = photoUrl
      ..phoneNumber = phoneNumber
      ..provider = provider ?? 'email'
      ..isEmailVerified = isEmailVerified ?? false
      ..isPremium = false
      ..premiumExpiryDate = null
      ..createdAt = createdAt
      ..lastLoginAt = lastLoginAt;
  }

  /// Parse provider string to enum
  static AuthProvider _parseProvider(String provider) {
    return AuthProvider.values.firstWhere(
      (e) => e.name == provider,
      orElse: () => AuthProvider.email,
    );
  }
}
