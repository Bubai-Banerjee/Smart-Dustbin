import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../models/dustbin_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dustbin_provider.dart';
import '../../widgets/glass_card.dart';

class CitizenDashboard extends ConsumerStatefulWidget {
  const CitizenDashboard({super.key});

  @override
  ConsumerState<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends ConsumerState<CitizenDashboard> {
  final _complaintController = TextEditingController();
  final _locationController = TextEditingController();
  int _userEcoPoints = 85;

  @override
  void dispose() {
    _complaintController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    ref.read(authProvider.notifier).logout();
    context.go('/roles');
  }

  void _showReportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: GlassCard(
            borderRadius: 24,
            borderColor: AppColors.alertOrange.withValues(alpha: 0.3),
            glowColor: AppColors.alertOrange,
            child: Container(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    'SUBMIT OVERFLOW REPORT',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppColors.alertOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _locationController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Location (e.g. Mechanical Workshop)...',
                      prefixIcon: Icon(Icons.location_on_rounded, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _complaintController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Describe issue (e.g., bin GT-004 is overflowing, plastic scattered)...',
                      prefixIcon: Icon(Icons.feedback_rounded, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.alertOrange,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      final loc = _locationController.text.trim();
                      final desc = _complaintController.text.trim();

                      if (loc.isNotEmpty && desc.isNotEmpty) {
                        _locationController.clear();
                        _complaintController.clear();
                        Navigator.pop(context);

                        // Trigger visual alert
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.alertOrange.withValues(alpha: 0.9),
                            content: const Text(
                              'REPORT DISPATCHED TO OPERATIONS. ECO-POINTS IN PROCESS.',
                              style: TextStyle(fontFamily: 'Courier', color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                        setState(() {
                          _userEcoPoints += 15; // award points for reporting!
                        });
                      }
                    },
                    child: const Text('DISPATCH REPORT', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
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

    // Filter clean/available bins (fill level < 60% & online) sorted by lowest fill first
    final cleanBins = bins.where((b) => b.fillPercentage < 60.0 && b.sensorActive).toList();
    cleanBins.sort((a, b) => a.fillPercentage.compareTo(b.fillPercentage));

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
              _buildTopBar(user?.name ?? 'EcoCitizen'),

              // Gamified Card Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                child: GlassCard(
                  borderColor: AppColors.borderGlowGreen.withValues(alpha: 0.15),
                  glowColor: AppColors.neonGreen.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ECO-CITIZEN STATUS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: AppColors.neonGreen,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'CAMPUS KEEPER',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Thanks for maintaining a clean campus!',
                              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'TOTAL SCORE',
                              style: TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_userEcoPoints pts',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neonGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Title bar & Report trigger button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CLEANEST DISPOSAL LOCATIONS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.electricCyan,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.alertOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onPressed: () => _showReportDialog(context),
                      icon: const Icon(Icons.report_problem_rounded, size: 14),
                      label: const Text('REPORT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // Bins listing
              Expanded(
                child: cleanBins.isEmpty
                    ? const Center(
                        child: Text(
                          'NO OPEN NODES DETECTED.',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: cleanBins.length,
                        itemBuilder: (context, index) {
                          final bin = cleanBins[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildCleanBinTile(bin),
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
                  color: AppColors.alertOrange,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.alertOrange.withValues(alpha: 0.4),
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
                    'SECURITY LEVEL: 03',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.alertOrange,
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

  Widget _buildCleanBinTile(DustbinModel bin) {
    // Determine quality color based on fill level
    Color levelColor = AppColors.neonGreen;
    if (bin.fillPercentage >= 40.0) {
      levelColor = AppColors.electricCyan;
    }

    return GlassCard(
      borderColor: levelColor.withValues(alpha: 0.15),
      glowColor: levelColor.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: levelColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: levelColor.withValues(alpha: 0.2)),
              ),
              child: Icon(
                bin.wasteType == 'Organic'
                    ? Icons.eco_rounded
                    : bin.wasteType == 'Plastic'
                        ? Icons.layers_rounded
                        : Icons.delete_outline_rounded,
                color: levelColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bin.location,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          bin.wasteType.toUpperCase(),
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.battery_charging_full_rounded, color: AppColors.textMuted, size: 12),
                      const SizedBox(width: 2),
                      Text(bin.battery, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${bin.fillPercentage}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: levelColor,
                  ),
                ),
                const Text(
                  'VACANT',
                  style: TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
