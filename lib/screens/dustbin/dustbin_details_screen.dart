import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../models/dustbin_model.dart';
import '../../providers/dustbin_provider.dart';
import '../../widgets/glass_card.dart';

class DustbinDetailsScreen extends ConsumerWidget {
  final String dustbinId;

  const DustbinDetailsScreen({
    super.key,
    required this.dustbinId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bins = ref.watch(dustbinsProvider);
    final binIndex = bins.indexWhere((b) => b.dustbinId == dustbinId);

    if (binIndex == -1) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.bgGradientStart, AppColors.bgGradientEnd],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'NODE RESOLUTION FAILED',
                  style: TextStyle(fontFamily: 'Courier', fontSize: 16, color: AppColors.warningRed, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Return to Gateway'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bin = bins[binIndex];

    Color statusColor = AppColors.neonGreen;
    if (!bin.sensorActive) {
      statusColor = AppColors.textMuted;
    } else if (bin.fillPercentage >= 85.0) {
      statusColor = AppColors.warningRed;
    } else if (bin.fillPercentage >= 70.0 || bin.badSmellDetected) {
      statusColor = AppColors.alertOrange;
    }

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
              _buildTopBar(context, bin.dustbinId, statusColor),

              // Scrollable Details
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Location Card
                      _buildLocationHeaderCard(bin, statusColor),
                      const SizedBox(height: 18),

                      // Gauge Panels
                      _buildFillLevelGaugeCard(bin, statusColor),
                      const SizedBox(height: 18),

                      // Sensor Grid Details
                      Row(
                        children: [
                          Expanded(
                            child: _buildSensorTelemetryCard(
                              title: 'OPERATING TEMP',
                              value: bin.temperature,
                              desc: bin.tempValue > 40.0 ? 'CRITICAL THERMAL' : 'NOMINAL RANGE',
                              icon: Icons.thermostat_rounded,
                              color: bin.tempValue > 40.0 ? AppColors.warningRed : AppColors.neonGreen,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildSensorTelemetryCard(
                              title: 'BATTERY POWER',
                              value: bin.battery,
                              desc: bin.batteryLevel < 0.20 ? 'CRITICAL DISCHARGE' : 'STABLE SOURCE',
                              icon: Icons.battery_charging_full_rounded,
                              color: bin.batteryLevel < 0.20 ? AppColors.warningRed : AppColors.electricCyan,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Gas sensor card
                      _buildGasSensorCard(bin),
                      const SizedBox(height: 24),

                      // Simulation Commands
                      const Text(
                        'SIMULATION PROTOCOLS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.neonGreen,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                ref.read(dustbinServiceProvider).collectWaste(bin.dustbinId);
                                ref.read(wasteCollectedCountProvider.notifier).increment(30);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.neonGreen,
                                    content: Text('CLEARED NODE ${bin.dustbinId} SECURE COMPARTMENTS.'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.cleaning_services_rounded, size: 18),
                              label: const Text('MANUAL CLEAR', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white10,
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white24),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                ref.read(dustbinServiceProvider).rebootSensor(bin.dustbinId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.electricCyan,
                                    content: Text('REBOOTED NODE ${bin.dustbinId} IOT TRANSCEIVER.'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.restart_alt_rounded, size: 18),
                              label: const Text('REBOOT SENSOR', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String id, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
          Text(
            'TELEMETRY CORE: $id',
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 48), // balance back button space
        ],
      ),
    );
  }

  Widget _buildLocationHeaderCard(DustbinModel bin, Color statusColor) {
    return GlassCard(
      borderColor: statusColor.withValues(alpha: 0.25),
      glowColor: statusColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bin.wasteType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: statusColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bin.sensorActive ? AppColors.neonGreen.withValues(alpha: 0.1) : AppColors.warningRed.withValues(alpha: 0.1),
                    border: Border.all(color: bin.sensorActive ? AppColors.neonGreen.withValues(alpha: 0.3) : AppColors.warningRed.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    bin.sensorActive ? 'ONLINE' : 'MALFUNCTION',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: bin.sensorActive ? AppColors.neonGreen : AppColors.warningRed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              bin.location,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'LAST SYNC POINT: ${bin.lastCollected}',
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'Courier',
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillLevelGaugeCard(DustbinModel bin, Color statusColor) {
    return GlassCard(
      borderColor: statusColor.withValues(alpha: 0.2),
      glowColor: statusColor.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'LIVE FILL TELEMETRY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Big circular fill level simulation
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: bin.fillPercentage / 100.0,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    strokeWidth: 10,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${bin.fillPercentage}%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        shadows: [
                          Shadow(color: statusColor.withValues(alpha: 0.4), blurRadius: 10),
                        ],
                      ),
                    ),
                    const Text(
                      'CAPACITY',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              bin.status.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorTelemetryCard({
    required String title,
    required String value,
    required String desc,
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
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                Icon(icon, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGasSensorCard(DustbinModel bin) {
    Color gasColor = bin.badSmellDetected ? AppColors.alertOrange : AppColors.neonGreen;

    return GlassCard(
      borderColor: gasColor.withValues(alpha: 0.2),
      glowColor: gasColor.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: gasColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.waves_rounded, color: gasColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GAS SENSOR (ODOR DETECTION)',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bin.badSmellDetected ? 'CRITICAL BAD SMELL DETECTED' : 'GAS LEVEL IN NOMINAL PARAMETERS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: gasColor),
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
