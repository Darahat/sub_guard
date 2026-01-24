import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Firebase Authentication data source
abstract class FirebaseAuthDataSource {
  /// Get current user
  User? get currentUser;

  /// Get current user stream
  Stream<User?> get authStateChanges;

  /// Sign in with email and password
  Future<UserModel> signInWithEmail(String email, String password);

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String displayName,
  );

  /// Sign in with Google
  Future<UserModel> signInWithGoogle();

  /// Sign in with Apple (iOS only)
  Future<UserModel> signInWithApple();

  /// Sign out
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Reload user data
  Future<void> reloadUser();

  /// Delete account
  Future<void> deleteAccount();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn;

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapUserToModel(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(message: 'Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await userCredential.user!.updateDisplayName(displayName.trim());
      await userCredential.user!.reload();

      return _mapUserToModel(_firebaseAuth.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(message: 'Failed to sign up: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException(message: 'Google sign-in cancelled by user');
      }

      // Obtain auth details
      final googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return _mapUserToModel(userCredential.user!, provider: 'google');
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(message: 'Google sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      // Request Apple ID credentials
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );

      // Update display name if available
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
        }
      }

      return _mapUserToModel(userCredential.user!, provider: 'apple');
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } on SignInWithAppleAuthorizationException catch (e) {
      throw AuthException(
        message: 'Apple sign-in failed: ${e.message}',
        code: e.code.toString(),
      );
    } catch (e) {
      throw AuthException(message: 'Apple sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw AuthException(message: 'Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        message: 'Failed to send reset email: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        message: 'Failed to send verification: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } catch (e) {
      throw AuthException(message: 'Failed to reload user: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(message: 'Failed to delete account: ${e.toString()}');
    }
  }

  /// Map Firebase User to UserModel
  UserModel _mapUserToModel(User user, {String? provider}) {
    return UserModel.fromFirebase(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      provider: provider ?? 'email',
      isEmailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime,
      lastLoginAt: user.metadata.lastSignInTime,
    );
  }

  /// Handle Firebase Auth exceptions
  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email';
        break;
      case 'wrong-password':
        message = 'Incorrect password';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      case 'invalid-email':
        message = 'Email address is invalid';
        break;
      case 'user-disabled':
        message = 'This account has been disabled';
        break;
      case 'operation-not-allowed':
        message = 'Operation not allowed';
        break;
      case 'too-many-requests':
        message = 'Too many requests. Please try again later';
        break;
      case 'requires-recent-login':
        message = 'Please sign in again to continue';
        break;
      default:
        message = e.message ?? 'Authentication failed';
    }
    return AuthException(message: message, code: e.code);
  }
}
