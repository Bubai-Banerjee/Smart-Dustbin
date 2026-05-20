import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/colors.dart';
import '../../models/dustbin_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dustbin_provider.dart';
import '../../widgets/glass_card.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _statusFilter = 'ALL'; // ALL, OVERFLOWING, SMELL, OFFLINE

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    ref.read(authProvider.notifier).logout();
    context.go('/roles');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final totalBins = ref.watch(totalBinsProvider);
    final overloadedBins = ref.watch(overloadedBinsProvider);
    final smellAlerts = ref.watch(smellAlertsProvider);
    final collectedWeight = ref.watch(wasteCollectedCountProvider);
    final bins = ref.watch(dustbinsProvider);

    // Apply search and status filters
    final filteredBins = bins.where((bin) {
      final matchesSearch = bin.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bin.dustbinId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bin.wasteType.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      switch (_statusFilter) {
        case 'OVERFLOWING':
          return bin.fillPercentage >= 80.0;
        case 'SMELL':
          return bin.badSmellDetected;
        case 'OFFLINE':
          return !bin.sensorActive;
        default:
          return true;
      }
    }).toList();

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
              // SCI-FI Top Bar
              _buildTopBar(user?.name ?? 'Admin Portal'),

              // Real-time Overview Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                child: SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildMetricCard(
                        title: 'MONITORED NODES',
                        value: '$totalBins',
                        subtitle: '25 Active Locs',
                        icon: Icons.hub_rounded,
                        color: AppColors.electricCyan,
                        glowColor: AppColors.borderGlowCyan,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        title: 'OVERLOAD WARNING',
                        value: '$overloadedBins',
                        subtitle: 'Fill Level > 80%',
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.warningRed,
                        glowColor: AppColors.borderGlowRed,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        title: 'SMELL ALERTS',
                        value: '$smellAlerts',
                        subtitle: 'Gas Sensor Peak',
                        icon: Icons.sensors_rounded,
                        color: AppColors.alertOrange,
                        glowColor: AppColors.borderGlowRed,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        title: 'WASTE RECOVERED',
                        value: '${collectedWeight}kg',
                        subtitle: 'Simulated Today',
                        icon: Icons.delete_sweep_rounded,
                        color: AppColors.neonGreen,
                        glowColor: AppColors.borderGlowGreen,
                      ),
                    ],
                  ),
                ),
              ),

              // Glass Tab Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderGlowDefault),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.neonGreen,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.neonGreen,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                    tabs: const [
                      Tab(text: 'TELEMETRY MONITOR'),
                      Tab(text: 'ANALYTICAL METRICS'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Telemetry List view
                    _buildTelemetryTab(filteredBins),
                    // Tab 2: FL_Chart Analytics view
                    _buildAnalyticsTab(bins),
                  ],
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
                  color: AppColors.neonGreen,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(alpha: 0.4),
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
                    'SECURITY LEVEL: 01',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neonGreen,
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
            tooltip: 'Terminate Link',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color glowColor,
  }) {
    return SizedBox(
      width: 165,
      child: GlassCard(
        borderColor: glowColor.withValues(alpha: 0.25),
        glowColor: color,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Icon(icon, color: color, size: 16),
                ],
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                  shadows: [
                    Shadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 10,
                    )
                  ],
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryTab(List<DustbinModel> filteredBins) {
    return Column(
      children: [
        // Search & Filter controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Search Location or Waste Type...',
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 18),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.tune_rounded, color: AppColors.electricCyan),
                tooltip: 'Select Filter Status',
                color: AppColors.bgGradientStart,
                onSelected: (val) {
                  setState(() {
                    _statusFilter = val;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'ALL', child: Text('All Bins', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'OVERFLOWING', child: Text('Critical (>=80%)', style: TextStyle(color: AppColors.warningRed))),
                  const PopupMenuItem(value: 'SMELL', child: Text('Smell Alerts', style: TextStyle(color: AppColors.alertOrange))),
                  const PopupMenuItem(value: 'OFFLINE', child: Text('Sensor Offline', style: TextStyle(color: AppColors.textMuted))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // List
        Expanded(
          child: filteredBins.isEmpty
              ? const Center(
                  child: Text(
                    'NO CORRESPONDING IOT NODES FOUND.',
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
                  itemCount: filteredBins.length,
                  itemBuilder: (context, index) {
                    final bin = filteredBins[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildTelemetryListTile(bin),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTelemetryListTile(DustbinModel bin) {
    Color statusColor = AppColors.neonGreen;
    if (!bin.sensorActive) {
      statusColor = AppColors.textMuted;
    } else if (bin.fillPercentage >= 85.0) {
      statusColor = AppColors.warningRed;
    } else if (bin.fillPercentage >= 70.0 || bin.badSmellDetected) {
      statusColor = AppColors.alertOrange;
    }

    return InkWell(
      onTap: () {
        context.push('/dustbin/${bin.dustbinId}');
      },
      borderRadius: BorderRadius.circular(16),
      child: GlassCard(
        borderColor: statusColor.withValues(alpha: 0.15),
        glowColor: statusColor.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          bin.dustbinId,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        bin.location,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    bin.wasteType.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'FILL TELEMETRY: ${bin.fillPercentage}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            Text(
                              bin.sensorActive ? 'ONLINE' : 'OFFLINE',
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold,
                                color: bin.sensorActive ? AppColors.neonGreen : AppColors.warningRed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: bin.fillPercentage / 100.0,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.thermostat_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Text(bin.temperature, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(width: 14),
                      const Icon(Icons.battery_charging_full_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Text(bin.battery, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                  if (bin.badSmellDetected)
                    Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: AppColors.alertOrange, size: 14),
                        SizedBox(width: 2),
                        Text(
                          'ODOR DETECTED',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.alertOrange),
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

  Widget _buildAnalyticsTab(List<DustbinModel> allBins) {
    // Generate simulated aggregates for fl_chart
    int plasticCount = allBins.where((b) => b.wasteType == 'Plastic').length;
    int organicCount = allBins.where((b) => b.wasteType == 'Organic').length;
    int paperCount = allBins.where((b) => b.wasteType == 'Paper').length;
    int otherCount = allBins.length - (plasticCount + organicCount + paperCount);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Graphic 1: Pie Chart Breakdown
          GlassCard(
            borderColor: AppColors.borderGlowCyan.withValues(alpha: 0.15),
            glowColor: AppColors.electricCyan.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WASTE STREAM MIX',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppColors.electricCyan,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 30,
                        sections: [
                          PieChartSectionData(
                            color: AppColors.neonGreen,
                            value: organicCount.toDouble(),
                            title: 'Org ($organicCount)',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          PieChartSectionData(
                            color: AppColors.electricCyan,
                            value: plasticCount.toDouble(),
                            title: 'Plast ($plasticCount)',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          PieChartSectionData(
                            color: AppColors.alertOrange,
                            value: paperCount.toDouble(),
                            title: 'Paper ($paperCount)',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          PieChartSectionData(
                            color: Colors.purpleAccent,
                            value: otherCount.toDouble(),
                            title: 'Misc ($otherCount)',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Graphic 2: Bar Chart Trends
          GlassCard(
            borderColor: AppColors.borderGlowGreen.withValues(alpha: 0.15),
            glowColor: AppColors.neonGreen.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WEEKLY DISPOSAL METRICS (KG)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppColors.neonGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                if (value >= 0 && value < days.length) {
                                  return Text(
                                    days[value.toInt()],
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 65, color: AppColors.neonGreen, width: 12, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 82, color: AppColors.electricCyan, width: 12, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 45, color: AppColors.neonGreen, width: 12, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 90, color: AppColors.warningRed, width: 12, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 70, color: AppColors.electricCyan, width: 12, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 30, color: AppColors.neonGreen, width: 12, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 55, color: AppColors.alertOrange, width: 12, borderRadius: BorderRadius.circular(4))]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
