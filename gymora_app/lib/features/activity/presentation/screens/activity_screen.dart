import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/activity_provider.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadActivityData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingMd),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Track your progress',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Logic to open logging bottom sheet or screen
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_rounded, color: AppTheme.primaryDark, size: 20),
                          const SizedBox(width: 6),
                          const Text(
                            'Log',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppTheme.accent,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Weight'),
                  Tab(text: 'Calories'),
                  Tab(text: 'BMI'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Chart Area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildWeightChart(),
                  _buildCalorieChart(),
                  _buildBMICard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, _) {
        final data = provider.weightHistory;
        if (data.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monitor_weight_outlined, size: 64, color: AppTheme.surfaceLight),
                SizedBox(height: 16),
                Text('No weight data recorded yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
              ],
            ),
          );
        }

        final currentWeight = data.last['weight'] as double;
        final firstWeight = data.first['weight'] as double;
        final trend = currentWeight - firstWeight;
        final isTrendDown = trend <= 0;

        // Calculate min/max for better chart scaling
        double minWeight = data.map((e) => e['weight'] as double).reduce((a, b) => a < b ? a : b);
        double maxWeight = data.map((e) => e['weight'] as double).reduce((a, b) => a > b ? a : b);
        double range = maxWeight - minWeight;
        double padding = range < 1 ? 2.0 : range * 0.2;
        double minY = (minWeight - padding).floorToDouble();
        double maxY = (maxWeight + padding).ceilToDouble();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Weight Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Weight', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: currentWeight.toStringAsFixed(1),
                                style: const TextStyle(fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                              ),
                              const TextSpan(
                                text: ' kg',
                                style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: (isTrendDown ? AppTheme.accent : AppTheme.error).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: (isTrendDown ? AppTheme.accent : AppTheme.error).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isTrendDown ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                            color: isTrendDown ? AppTheme.accent : AppTheme.error,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${trend > 0 ? "+" : ""}${trend.toStringAsFixed(1)} kg',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isTrendDown ? AppTheme.accent : AppTheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('30-Day Trend', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  Text(
                    'Last 30 days',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppTheme.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chart with padding for labels
              Container(
                height: 220,
                width: double.infinity,
                padding: const EdgeInsets.only(right: 16),
                child: LineChart(
                  LineChartData(
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (maxY - minY) / 4,
                      getDrawingHorizontalLine: (value) => FlLine(color: AppTheme.divider.withOpacity(0.2), strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: data.length > 7 ? (data.length / 4).ceilToDouble() : 1,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < data.length) {
                              String dateStr = data[index]['date'] as String;
                              // Just show day if it's many points
                              try {
                                DateTime dt = DateTime.parse(dateStr);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text('${dt.day}/${dt.month}', style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppTheme.textTertiary)),
                                );
                              } catch (e) {
                                return const Text('');
                              }
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 38,
                          getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}', style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppTheme.textTertiary));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['weight'] as double))).toList(),
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: AppTheme.accent,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: index == data.length - 1 ? 6 : 0,
                            color: AppTheme.accent,
                            strokeWidth: 2,
                            strokeColor: AppTheme.primaryDark,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [AppTheme.accent.withOpacity(0.2), AppTheme.accent.withOpacity(0.0)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => AppTheme.surfaceLight,
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                          '${s.y.toStringAsFixed(1)} kg',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        )).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              // Quick Stats
              Row(
                children: [
                  _buildQuickStat('Min', '${minWeight.toStringAsFixed(1)} kg', Icons.arrow_downward_rounded),
                  const SizedBox(width: 16),
                  _buildQuickStat('Max', '${maxWeight.toStringAsFixed(1)} kg', Icons.arrow_upward_rounded),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textTertiary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppTheme.textTertiary)),
                Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieChart() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, _) {
        final data = provider.calorieHistory;
        if (data.isEmpty) {
          return const Center(child: Text('No calorie data yet', style: TextStyle(color: AppTheme.textSecondary)));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weekly Calories', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildLegend('Consumed', AppTheme.secondary),
                  const SizedBox(width: 16),
                  _buildLegend('Burned', AppTheme.accent),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 240,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 2800,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 700,
                      getDrawingHorizontalLine: (value) => FlLine(color: AppTheme.divider.withOpacity(0.3), strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}', style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppTheme.textTertiary));
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < data.length) {
                              return Text(data[value.toInt()]['day'], style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.textTertiary));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: data.asMap().entries.map((e) {
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: (e.value['consumed'] as int).toDouble(),
                            color: AppTheme.secondary,
                            width: 12,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                          BarChartRodData(
                            toY: (e.value['burned'] as int).toDouble(),
                            color: AppTheme.accent,
                            width: 12,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBMICard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                const Text('Your BMI', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                const Text('23.7', style: TextStyle(fontFamily: 'Poppins', fontSize: 48, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: const Text('Normal Weight', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.accent)),
                ),
                const SizedBox(height: 24),
                // BMI Scale
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 12,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF22C55E), Color(0xFFF59E0B), Color(0xFFEF4444)],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('16', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.textTertiary)),
                    Text('18.5', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.textTertiary)),
                    Text('25', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.textTertiary)),
                    Text('30', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.textTertiary)),
                    Text('40', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}
