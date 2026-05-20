import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  String _loadingText = "INITIALIZING CORE SYSTEM...";
  int _loadingStep = 0;
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Cycling loading text for futuristic IoT aesthetic
    _textTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) return;
      setState(() {
        _loadingStep = (_loadingStep + 1) % 4;
        switch (_loadingStep) {
          case 0:
            _loadingText = "CONNECTING TO CAMPUS IOT...";
            break;
          case 1:
            _loadingText = "READING DUSTBIN SENSORS...";
            break;
          case 2:
            _loadingText = "CALIBRATING AI SCHEDULER...";
            break;
          case 3:
            _loadingText = "SECURE SESSION READY...";
            break;
        }
      });
    });

    // Navigate to role selection screen after 3.5 seconds
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        context.go('/roles');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Stack(
          children: [
            // Tech-mesh scanlines or abstract nodes (using paint)
            Positioned.fill(
              child: CustomPaint(
                painter: TechGridPainter(),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo Container
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _opacityAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        // Hexagonal glowing logo placeholder
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonGreen.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: AppColors.electricCyan.withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                            gradient: const LinearGradient(
                              colors: [AppColors.neonGreen, AppColors.electricCyan],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.delete_sweep_rounded,
                            size: 55,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // App Name with gradient text
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppColors.neonGreen, AppColors.electricCyan],
                          ).createShader(bounds),
                          child: const Text(
                            'ECOTRACK',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Text(
                          'SMART WASTE SYSTEM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 4.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                  // Tech Loader
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        const LinearProgressIndicator(
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricCyan),
                          minHeight: 2,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _loadingText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'Courier', // Tech aesthetic font
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Institute text
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Column(
                children: const [
                  Text(
                    'DEVELOPED FOR',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'GREENTECH INSTITUTE OF TECHNOLOGY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for subtle background grid pattern
class TechGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 1.0;

    const double step = 30.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
