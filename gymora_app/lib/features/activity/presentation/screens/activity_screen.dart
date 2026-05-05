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
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Row(
                children: [
                  const Text('Activity', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add_rounded, color: AppTheme.accent, size: 18),
                        const SizedBox(width: 4),
                        const Text('Log', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.accent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppTheme.primaryDark,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Weight'),
                  Tab(text: 'Calories'),
                  Tab(text: 'BMI'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Chart Area
            Expanded(
              child: TabBarView(
                controller: _tabController,
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
          return const Center(child: Text('No weight data yet', style: TextStyle(color: AppTheme.textSecondary)));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Weight Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Weight', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppTheme.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          '${(data.last['weight'] as double).toStringAsFixed(1)} kg',
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.trending_down_rounded, color: AppTheme.accent, size: 16),
                          SizedBox(width: 4),
                          Text('-2.5 kg', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.accent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text('30-Day Trend', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 16),

              // Chart
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(color: AppTheme.divider.withOpacity(0.3), strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 7,
                          getTitlesWidget: (value, meta) {
                            return Text('W${(value / 7).ceil()}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.textTertiary));
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.textTertiary));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['weight'] as double))).toList(),
                        isCurved: true,
                        color: AppTheme.accent,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [AppTheme.accent.withOpacity(0.3), AppTheme.accent.withOpacity(0.0)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
