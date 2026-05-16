import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esaudagar/l10n/app_localizations.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../home/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isRegistering = false;
  // ─── FEATURE 2: Password visibility toggle ───
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ─── FEATURE 2: Clean, human-readable validation messages ───
  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.emailRequired;
    }
    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return l10n.invalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }
    if (value.length < 6) {
      return l10n.passwordTooShort;
    }
    return null;
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isRegistering) {
      await ref.read(authProvider.notifier).register(email, password);
      // Save additional profile info
      await ref.read(userProfileProvider.notifier).updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
    } else {
      await ref.read(authProvider.notifier).login(email, password);
    }

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.value != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (authState.hasError) {
      // ─── FEATURE 2: Map Firebase codes to clean messages ───
      final rawError = authState.error.toString();
      String friendlyMessage;
      final l10n = AppLocalizations.of(context)!;

      if (rawError.contains('user-not-found') ||
          rawError.contains('wrong-password') ||
          rawError.contains('invalid-credential')) {
        friendlyMessage = l10n.invalidCredentials;
      } else if (rawError.contains('email-already-in-use')) {
        friendlyMessage = l10n.emailAlreadyExists;
      } else if (rawError.contains('network-request-failed')) {
        friendlyMessage = l10n.noInternet;
      } else if (rawError.contains('too-many-requests')) {
        friendlyMessage =
            l10n.tooManyRequests;
      } else {
        friendlyMessage = l10n.genericError;
      }


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyMessage),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.shopping_bag,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _isRegistering ? l10n.register : l10n.login,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRegistering
                        ? l10n.createAccount
                        : l10n.signInToShop,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Name Field (Registration only)
                  if (_isRegistering) ...[
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: AppTheme.softShadows,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        validator: (v) => v == null || v.isEmpty ? l10n.nameRequired : null,
                        decoration: InputDecoration(
                          labelText: l10n.fullName,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email Field

                  Container(
                    decoration: BoxDecoration(
                      boxShadow: AppTheme.softShadows,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      validator: _validateEmail,
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone Field (Registration only)
                  if (_isRegistering) ...[
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: AppTheme.softShadows,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: l10n.phoneNumber,
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Address Field (Registration only)
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: AppTheme.softShadows,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: l10n.shippingAddress,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                        maxLines: 2,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ─── FEATURE 2: Password Field with Visibility Toggle ───

                  Container(
                    decoration: BoxDecoration(
                      boxShadow: AppTheme.softShadows,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      validator: _validatePassword,
                      obscureText: !_passwordVisible,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        // 👁️ The toggle button
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(
                                () => _passwordVisible = !_passwordVisible);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(_isRegistering ? l10n.register : l10n.login),
                  ),
                  const SizedBox(height: 16),

                  // Toggle Register/Login
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRegistering = !_isRegistering;
                        _formKey.currentState?.reset();
                      });
                    },
                    child: Text(
                      _isRegistering
                          ? 'Already have an account? ${l10n.login}'
                          : 'New user? ${l10n.register}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
