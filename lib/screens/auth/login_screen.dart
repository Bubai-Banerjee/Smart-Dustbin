import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final UserRole role;

  const LoginScreen({
    super.key,
    required this.role,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Pre-populate mock accounts for ease of testing
    switch (widget.role) {
      case UserRole.admin:
        _emailController.text = 'admin@greentech.edu';
        break;
      case UserRole.collector:
        _emailController.text = 'collector@greentech.edu';
        break;
      case UserRole.citizen:
        _emailController.text = 'citizen@greentech.edu';
        break;
    }
    _passwordController.text = 'password123';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Color get _themeColor {
    switch (widget.role) {
      case UserRole.admin:
        return AppColors.neonGreen;
      case UserRole.collector:
        return AppColors.electricCyan;
      case UserRole.citizen:
        return AppColors.alertOrange;
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).loginWithEmail(
            _emailController.text,
            _passwordController.text,
            widget.role,
          );

      if (success && mounted) {
        _navigateHome();
      }
    }
  }

  void _navigateHome() {
    switch (widget.role) {
      case UserRole.admin:
        context.go('/admin');
        break;
      case UserRole.collector:
        context.go('/collector');
        break;
      case UserRole.citizen:
        context.go('/citizen');
        break;
    }
  }

  void _showBiometricAuth() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _BiometricScanSheet(
          role: widget.role,
          themeColor: _themeColor,
          onSuccess: () {
            Navigator.pop(context);
            _navigateHome();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgGradientStart,
              AppColors.bgGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back navigation
                    Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderGlowDefault),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'CREDENTIAL GATEWAY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: _themeColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.role.displayName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please verify your security credentials.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),

                    // Login Card Form
                    GlassCard(
                      borderColor: _themeColor.withOpacity(0.15),
                      glowColor: _themeColor,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (authState.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.warningRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.warningRed.withOpacity(0.3)),
                                ),
                                child: Text(
                                  authState.errorMessage!,
                                  style: const TextStyle(color: AppColors.warningRed, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Email input
                            const Text(
                              'IDENTITY EMAIL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.alternate_email_rounded, color: AppColors.textSecondary),
                                hintText: 'operator@greentech.edu',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password input
                            const Text(
                              'ACCESS TOKEN (PASSWORD)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                                hintText: '••••••••',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Remember Me & Forgot password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: _themeColor,
                                        checkColor: Colors.black,
                                        side: const BorderSide(color: AppColors.textSecondary),
                                        onChanged: (val) {
                                          setState(() {
                                            _rememberMe = val ?? true;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Remember ID',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Text(
                                    'Recover Access?',
                                    style: TextStyle(
                                      color: _themeColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Submit Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _themeColor,
                                shadowColor: _themeColor.withOpacity(0.4),
                              ),
                              onPressed: authState.isLoading ? null : _handleLogin,
                              child: authState.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text('AUTHENTICATE CLIENT'),
                                        SizedBox(width: 8),
                                        Icon(Icons.vpn_key_rounded, size: 18),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Biometrics option
                    const Text(
                      'SECURE ALTERNATIVES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBiometricBtn(
                          icon: Icons.fingerprint_rounded,
                          label: 'Touch ID',
                          onTap: _showBiometricAuth,
                        ),
                        const SizedBox(width: 20),
                        _buildBiometricBtn(
                          icon: Icons.face_retouching_natural_rounded,
                          label: 'Face ID',
                          onTap: _showBiometricAuth,
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

  Widget _buildBiometricBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderGlowDefault),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.02),
        ),
        child: Row(
          children: [
            Icon(icon, color: _themeColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Biometric Simulation Sheet
class _BiometricScanSheet extends ConsumerStatefulWidget {
  final UserRole role;
  final Color themeColor;
  final VoidCallback onSuccess;

  const _BiometricScanSheet({
    required this.role,
    required this.themeColor,
    required this.onSuccess,
  });

  @override
  ConsumerState<_BiometricScanSheet> createState() => _BiometricScanSheetState();
}

class _BiometricScanSheetState extends ConsumerState<_BiometricScanSheet> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  late Animation<double> _scanLineAnimation;
  String _status = "WAITING FOR BIOMETRIC LINK...";
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );

    _startSimulatedScan();
  }

  void _startSimulatedScan() async {
    // Stage 1: Initiating scan
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _status = "SCANNING SECURE COMPARTMENT...";
    });

    // Stage 2: Validating credentials
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _status = "MATCHING LOCAL AUTH PROFILE...";
    });

    // Invoke actual Riverpod auth trigger
    final success = await ref.read(authProvider.notifier).loginWithBiometrics(widget.role);
    
    if (success && mounted) {
      setState(() {
        _isSuccess = true;
        _status = "ACCESS GRANTED. SYNCING NODE...";
      });
      await Future.delayed(const Duration(milliseconds: 800));
      widget.onSuccess();
    } else if (mounted) {
      setState(() {
        _status = "SECURE MATCH FAILED. RESET KEY.";
      });
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 24,
      borderColor: widget.themeColor.withOpacity(0.3),
      glowColor: widget.themeColor,
      blur: 25,
      child: Container(
        height: 380,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tech indicator line
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'BIOMETRIC PROTOCOL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Pulsing scan area
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: widget.themeColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.themeColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      widget.role == UserRole.citizen
                          ? Icons.face_retouching_natural_rounded
                          : Icons.fingerprint_rounded,
                      color: _isSuccess ? AppColors.neonGreen : widget.themeColor,
                      size: 60,
                    ),
                  ),
                  // Animated glowing horizontal line
                  if (!_isSuccess)
                    AnimatedBuilder(
                      animation: _scannerController,
                      builder: (context, child) {
                        return Positioned(
                          top: 10 + (_scanLineAnimation.value * 90),
                          left: 10,
                          right: 10,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: widget.themeColor,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.themeColor,
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Status text
            Text(
              _status,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Progress dots
            if (!_isSuccess)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: widget.themeColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
