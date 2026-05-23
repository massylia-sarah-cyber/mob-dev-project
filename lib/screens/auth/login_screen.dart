import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/glass_card.dart';
import '../../core/services/firebase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuthService.instance.signIn(email, password);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Authentication failed.');
    } catch (e) {
      _showError('An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Melody Brand Logo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                      )
                    ],
                  ),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBswimh3ZDNbPv8mvE1TzxbYPV_QM12tVna_5VFmbN16XJ8gRV9MPLZdwR5mVyAMJ6EziDOnKiDWlhr-mRn6YeSCDbRvDwsh5-foJKcMs8Uqr_VyPtc7i1OsfGyMuFaCRKTYYJBAHJdt_V_LBFnv_Ks1zWAr6aueEdE0nFVQmfdQAE_uE597guuH2BtI2UWT4XAtg3hvj1AkoG_j5g6oBegueItZEHM5KLgoMBedZoBekoHI8h0XeFOaJYYld-CMgiwBJtQIvGVyeo',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 32),
                Text('Welcome Back',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                Text('Enter the sanctuary of sound.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 48),

                GlassCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email
                      Text('Email Address',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                  letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'name@example.com',
                          hintStyle: TextStyle(
                              color: AppColors.outline.withValues(alpha: 0.5)),
                          prefixIcon: const Icon(Icons.mail_outline,
                              color: AppColors.outline),
                          filled: true,
                          fillColor: AppColors.surfaceContainerHigh,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                                color: AppColors.secondary.withValues(alpha: 0.3)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Password row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Password',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 12,
                                      letterSpacing: 0.5)),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, '/forgot_password'),
                            child: Text('Forgot Password?',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                        color: AppColors.secondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppColors.onSurface),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(
                              color: AppColors.outline.withValues(alpha: 0.5)),
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppColors.outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.outline,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceContainerHigh,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                                color: AppColors.secondary.withValues(alpha: 0.3)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.primaryContainer
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10)),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: AppColors.onPrimaryFixed,
                                    strokeWidth: 2,
                                  )
                                : const Text('Sign In',
                                    style: TextStyle(
                                        color: AppColors.onPrimaryFixed,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/signup'),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: AppColors.onSurfaceVariant),
                              children: const [
                                TextSpan(
                                  text: 'Create an account',
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                            height: 1,
                            color:
                                AppColors.outlineVariant.withValues(alpha: 0.3))),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR CONTINUE WITH',
                          style: TextStyle(
                              color: AppColors.outline,
                              fontSize: 12,
                              letterSpacing: 1.5)),
                    ),
                    Expanded(
                        child: Container(
                            height: 1,
                            color:
                                AppColors.outlineVariant.withValues(alpha: 0.3))),
                  ],
                ),

                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                        child: GlassCard(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            child: const Center(
                                child: Icon(Icons.g_mobiledata, size: 28)))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: GlassCard(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            child: const Center(
                                child: Icon(Icons.apple, size: 28)))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: GlassCard(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            child: const Center(
                                child: Icon(Icons.facebook, size: 28)))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
