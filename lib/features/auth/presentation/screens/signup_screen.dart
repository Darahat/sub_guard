import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/layout/responsive_layout.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_notifier.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  double _passwordStrength = 0.0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final text = _passwordController.text;
    double strength = 0.0;
    if (text.length >= 8) strength += 0.25;
    if (text.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (text.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (text.contains(RegExp(r'[!@#\$&*~]'))) strength += 0.25;
    setState(() => _passwordStrength = strength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordStrength);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    HapticFeedback.lightImpact();
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authNotifierProvider.notifier)
        .signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
  }

  Future<void> _handleGoogleSignIn() async {
    HapticFeedback.lightImpact();
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  Future<void> _handleAppleSignIn() async {
    HapticFeedback.lightImpact();
    await ref.read(authNotifierProvider.notifier).signInWithApple();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Listen for auth state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
      if (next.successMessage != null && next.user != null) {
        ref.read(syncServiceProvider).syncAll(userId: next.user!.id);
        context.go('/dashboard');
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Breakpoints.isTablet(context) ? 480 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Breakpoints.isTablet(context) ? 32 : 24,
                vertical: 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo with glowing frosted container
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: HeroIcon(
                            HeroIcons.shieldCheck,
                            size: 38,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Title
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: AppColors.textPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Get started with SubGuard',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),

                    // Grouped Form Inputs
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Name field
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'Enter your name',
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(12),
                                child: HeroIcon(
                                  HeroIcons.user,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                            ),
                            validator: Validators.name,
                            enabled: !authState.isLoading,
                          ),
                          Divider(
                            height: 1,
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.1),
                          ),
                          // Email field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(12),
                                child: HeroIcon(
                                  HeroIcons.envelope,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                            ),
                            validator: Validators.email,
                            enabled: !authState.isLoading,
                          ),
                          Divider(
                            height: 1,
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.1),
                          ),
                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Create a password',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(12),
                                child: HeroIcon(
                                  HeroIcons.lockClosed,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: HeroIcon(
                                  _obscurePassword
                                      ? HeroIcons.eyeSlash
                                      : HeroIcons.eye,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                            ),
                            validator: Validators.password,
                            enabled: !authState.isLoading,
                          ),
                          // Live Password Strength Meter
                          if (_passwordController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ).copyWith(bottom: 12.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: 0,
                                    end: _passwordStrength,
                                  ),
                                  duration: const Duration(milliseconds: 250),
                                  builder: (context, value, _) {
                                    return LinearProgressIndicator(
                                      value: value,
                                      minHeight: 4,
                                      backgroundColor: Theme.of(
                                        context,
                                      ).dividerColor.withValues(alpha: 0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        value <= 0.25
                                            ? Colors.red
                                            : value <= 0.75
                                            ? Colors.amber
                                            : Colors.green,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          Divider(
                            height: 1,
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.1),
                          ),
                          // Confirm Password field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              hintText: 'Re-enter your password',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(12),
                                child: HeroIcon(
                                  HeroIcons.lockClosed,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: HeroIcon(
                                  _obscureConfirmPassword
                                      ? HeroIcons.eyeSlash
                                      : HeroIcons.eye,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                ),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                            ),
                            validator: (value) => Validators.confirmPassword(
                              value,
                              _passwordController.text,
                            ),
                            enabled: !authState.isLoading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign up button
                    FilledButton(
                      onPressed: authState.isLoading ? null : _handleSignUp,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: authState.isLoading
                            ? const Text(
                                'Creating Account...',
                                key: ValueKey('loading'),
                                style: TextStyle(fontSize: 16),
                              )
                            : const Text(
                                'Sign Up',
                                key: ValueKey('ready'),
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Clean OAuth Pills
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.1),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            onPressed: authState.isLoading
                                ? null
                                : _handleGoogleSignIn,
                            icon: SvgPicture.asset(
                              'assets/icons/logos/google.svg',
                              height: 24,
                              width: 24,
                            ),
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                        if (Platform.isIOS) ...[
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.1),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : _handleAppleSignIn,
                              icon: SvgPicture.asset(
                                'assets/icons/logos/apple.svg',
                                height: 24,
                                width: 24,
                              ),
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: authState.isLoading
                              ? null
                              : () => context.pop(),
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
