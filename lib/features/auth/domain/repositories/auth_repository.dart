import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Get current user
  UserEntity? get currentUser;

  /// Get auth state stream
  Stream<UserEntity?> get authStateChanges;

  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmail(
    String email,
    String password,
  );

  /// Sign up with email and password
  Future<Either<Failure, UserEntity>> signUpWithEmail(
    String email,
    String password,
    String displayName,
  );

  /// Sign in with Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign in with Apple
  Future<Either<Failure, UserEntity>> signInWithApple();

  /// Sign out
  Future<Either<Failure, Unit>> signOut();

  /// Send password reset email
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email);

  /// Send email verification
  Future<Either<Failure, Unit>> sendEmailVerification();

  /// Reload user
  Future<Either<Failure, UserEntity>> reloadUser();

  /// Delete account
  Future<Either<Failure, Unit>> deleteAccount();

  /// Get cached user
  Future<Either<Failure, UserEntity?>> getCachedUser();
}
