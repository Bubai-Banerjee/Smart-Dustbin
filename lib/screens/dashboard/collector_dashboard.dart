import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../models/dustbin_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dustbin_provider.dart';
import '../../widgets/glass_card.dart';

class CollectorDashboard extends ConsumerStatefulWidget {
  const CollectorDashboard({super.key});

  @override
  ConsumerState<CollectorDashboard> createState() => _CollectorDashboardState();
}

class _CollectorDashboardState extends ConsumerState<CollectorDashboard> {
  void _handleLogout() {
    ref.read(authProvider.notifier).logout();
    context.go('/roles');
  }

  void _triggerSimulatedQrScan(BuildContext context, String dustbinId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassCard(
          borderRadius: 24,
          borderColor: AppColors.electricCyan.withValues(alpha: 0.3),
          glowColor: AppColors.electricCyan,
          child: Container(
            height: 340,
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                const SizedBox(height: 20),
                const Text(
                  'QR COLLECT PROTOCOL',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: AppColors.electricCyan,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // QR Scanning mock graphic
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      border: Border.all(color: AppColors.borderGlowDefault),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, size: 70, color: AppColors.electricCyan.withValues(alpha: 0.8)),
                          Container(
                            width: 120,
                            height: 2,
                            color: AppColors.electricCyan,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricCyan,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    // Update state using service
                    ref.read(dustbinServiceProvider).collectWaste(dustbinId);
                    ref.read(wasteCollectedCountProvider.notifier).increment(45); // add 45kg
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.neonGreen.withValues(alpha: 0.9),
                        content: Text(
                          'NODE $dustbinId CLEARED SUCCESSFULLY. SYSTEM RE-CALIBRATED.',
                          style: const TextStyle(fontFamily: 'Courier', color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                  child: const Text('CONFIRM NODE COLLECTION'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final bins = ref.watch(dustbinsProvider);

    // Filter bins that require attention (critical and alert levels)
    final urgentBins = bins.where((b) => b.fillPercentage >= 75.0 || b.badSmellDetected).toList();

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              _buildTopBar(user?.name ?? 'Field Unit'),

              // Operational Dashboard overview cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildOperatorCard(
                        title: 'PENDING ACTION',
                        value: '${urgentBins.length}',
                        subtitle: 'Requires Cleanup',
                        icon: Icons.assignment_late_rounded,
                        color: AppColors.warningRed,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildOperatorCard(
                        title: 'SYSTEM STATUS',
                        value: 'NOMINAL',
                        subtitle: '6 Operations Active',
                        icon: Icons.task_alt_rounded,
                        color: AppColors.neonGreen,
                      ),
                    ),
                  ],
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: Text(
                  'CRITICAL ALERTS & PENDING PICKS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.electricCyan,
                  ),
                ),
              ),

              // Dynamic Urgent List
              Expanded(
                child: urgentBins.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_circle_outline_rounded, size: 50, color: AppColors.neonGreen),
                              SizedBox(height: 12),
                              Text(
                                'ALL LOCATIONS CLEAN & CALIBRATED',
                                style: TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neonGreen,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'No bins on campus are currently overflowing.',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: urgentBins.length,
                        itemBuilder: (context, index) {
                          final bin = urgentBins[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildCollectorTile(bin),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.electricCyan,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricCyan.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SECURITY LEVEL: 02',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.electricCyan,
                    ),
                  ),
                  Text(
                    name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, color: AppColors.warningRed),
            onPressed: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      borderColor: color.withValues(alpha: 0.2),
      glowColor: color.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                Icon(icon, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(color: color.withValues(alpha: 0.4), blurRadius: 10),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectorTile(DustbinModel bin) {
    Color cardColor = bin.fillPercentage >= 85.0 ? AppColors.warningRed : AppColors.alertOrange;

    return GlassCard(
      borderColor: cardColor.withValues(alpha: 0.2),
      glowColor: cardColor.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          bin.dustbinId,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: cardColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bin.location,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Type: ${bin.wasteType}  |  Last: ${bin.lastCollected.split(" ")[1]} ${bin.lastCollected.split(" ")[2]}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.1),
                    border: Border.all(color: cardColor.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${bin.fillPercentage}%',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: cardColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                if (bin.badSmellDetected)
                  Row(
                    children: const [
                      Icon(Icons.sentiment_very_dissatisfied_rounded, color: AppColors.alertOrange, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'ODOR ALERT',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.alertOrange),
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                Row(
                  children: [
                    const Icon(Icons.thermostat_rounded, color: AppColors.textSecondary, size: 15),
                    const SizedBox(width: 2),
                    Text(bin.temperature, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => _triggerSimulatedQrScan(context, bin.dustbinId),
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                  label: const Text('DISPOSE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
