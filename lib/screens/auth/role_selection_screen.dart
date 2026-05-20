import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../models/user_model.dart';
import '../../widgets/glass_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Futuristic header
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.electricCyan,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.electricCyan.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'SECURITY GATEWAY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: AppColors.electricCyan,
                          ),
                        ),
                        Text(
                          'ECOTRACK NETWORK',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'SELECT ACCESS PROTOCOL',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose your authorization tier to interface with the campus real-time systems.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Role Options list
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildRoleCard(
                        context: context,
                        role: UserRole.admin,
                        title: 'CAMPUS ADMIN',
                        subtitle: 'Tier-1 Control',
                        desc: 'Access real-time sensor dashboards, track crews, manage reports, and review AI analytics.',
                        icon: Icons.admin_panel_settings_rounded,
                        primaryColor: AppColors.neonGreen,
                        glowColor: AppColors.borderGlowGreen,
                        codeName: 'SEC-LVL: 01 // OVERSEER',
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context: context,
                        role: UserRole.collector,
                        title: 'WASTE COLLECTOR',
                        subtitle: 'Tier-2 Operation',
                        desc: 'View optimized collection routes, scan bin QRs, update pickup records, and view maps.',
                        icon: Icons.local_shipping_rounded,
                        primaryColor: AppColors.electricCyan,
                        glowColor: AppColors.borderGlowCyan,
                        codeName: 'SEC-LVL: 02 // FIELD UNIT',
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context: context,
                        role: UserRole.citizen,
                        title: 'STUDENT / CITIZEN',
                        subtitle: 'Tier-3 Public Access',
                        desc: 'Locate clean bins, report overflow issues, upload cleanup images, and track complaints.',
                        icon: Icons.people_alt_rounded,
                        primaryColor: AppColors.alertOrange,
                        glowColor: AppColors.borderGlowRed,
                        codeName: 'SEC-LVL: 03 // VISITOR',
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required UserRole role,
    required String title,
    required String subtitle,
    required String desc,
    required IconData icon,
    required Color primaryColor,
    required Color glowColor,
    required String codeName,
  }) {
    return InkWell(
      onTap: () {
        context.push('/login/${role.name}');
      },
      borderRadius: BorderRadius.circular(16),
      child: GlassCard(
        borderColor: glowColor,
        glowColor: primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtitle.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: primaryColor,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    codeName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'INITIALIZE LINK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: primaryColor,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
