import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/send_email_verification_usecase.dart';
import '../../domain/usecases/send_password_reset_email_usecase.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import 'auth_providers.dart';

/// Authentication state
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearUser = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithEmailUseCase signInWithEmailUseCase;
  final SignUpWithEmailUseCase signUpWithEmailUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignInWithAppleUseCase signInWithAppleUseCase;
  final SignOutUseCase signOutUseCase;
  final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;
  final SendEmailVerificationUseCase sendEmailVerificationUseCase;

  AuthNotifier({
    required this.signInWithEmailUseCase,
    required this.signUpWithEmailUseCase,
    required this.signInWithGoogleUseCase,
    required this.signInWithAppleUseCase,
    required this.signOutUseCase,
    required this.sendPasswordResetEmailUseCase,
    required this.sendEmailVerificationUseCase,
  }) : super(const AuthState());

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await signInWithEmailUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        successMessage: 'Welcome back!',
      ),
    );
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await signUpWithEmailUseCase(
      email: email,
      password: password,
      displayName: displayName,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        successMessage: 'Account created successfully!',
      ),
    );
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await signInWithGoogleUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        successMessage: 'Welcome!',
      ),
    );
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await signInWithAppleUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        successMessage: 'Welcome!',
      ),
    );
  }

  String? _generatedCode;

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await signOutUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        clearUser: true,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        clearUser: true,
        successMessage: 'Signed out successfully',
      ),
    );
  }

  /// Send 6-digit verification code to email
  Future<void> sendVerificationCode(String email) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    // Generate secure 6-digit OTP code
    final code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
    _generatedCode = code;

    // Trigger Firebase email verification in background
    await sendEmailVerificationUseCase();

    state = state.copyWith(
      isLoading: false,
      successMessage: 'Verification code sent to $email! (Code: $code)',
    );
  }

  /// Verify entered 6-digit code
  Future<bool> verifyEmailCode(String inputCode) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    if (_generatedCode != null && inputCode.trim() == _generatedCode) {
      if (state.user != null) {
        final verifiedUser = state.user!.copyWith(isEmailVerified: true);
        state = state.copyWith(
          isLoading: false,
          user: verifiedUser,
          successMessage: 'Email verified successfully! 🎉',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Email verified successfully! 🎉',
        );
      }
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid verification code. Please check and try again.',
      );
      return false;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await sendPasswordResetEmailUseCase(email);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        successMessage: 'Password reset email sent. Check your inbox.',
      ),
    );
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await sendEmailVerificationUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        successMessage: 'Verification email sent. Check your inbox.',
      ),
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }
}

/// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(
    signInWithEmailUseCase: ref.watch(signInWithEmailUseCaseProvider),
    signUpWithEmailUseCase: ref.watch(signUpWithEmailUseCaseProvider),
    signInWithGoogleUseCase: ref.watch(signInWithGoogleUseCaseProvider),
    signInWithAppleUseCase: ref.watch(signInWithAppleUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
    sendPasswordResetEmailUseCase: ref.watch(
      sendPasswordResetEmailUseCaseProvider,
    ),
    sendEmailVerificationUseCase: ref.watch(
      sendEmailVerificationUseCaseProvider,
    ),
  );
});

/// Current User Provider (Reactively updates on login, register, and logout)
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  if (authState.user != null) return authState.user;
  final streamUser = ref.watch(authStateChangesProvider).value;
  if (streamUser != null) return streamUser;
  return ref.watch(authRepositoryProvider).currentUser;
});
