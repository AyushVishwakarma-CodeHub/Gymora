import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/admin_repository.dart';
import '../../data/models/dashboard_overview.dart';
import 'dart:ui';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminRepository _repository = AdminRepository();
  late Future<DashboardOverview?> _overviewFuture;

  @override
  void initState() {
    super.initState();
    _overviewFuture = _repository.getSystemOverview();
  }

  Future<void> _refresh() async {
    setState(() {
      _overviewFuture = _repository.getSystemOverview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: CustomScrollView(
        slivers: [
          // Elegant Header
          SliverAppBar(
            backgroundColor: AppTheme.primaryDark,
            elevation: 0,
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shield_rounded, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Super Admin',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primary.withOpacity(0.8),
                      AppTheme.primaryDark,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
                onPressed: _refresh,
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppTheme.textSecondary),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Main Content
          SliverToBoxAdapter(
            child: FutureBuilder<DashboardOverview?>(
              future: _overviewFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final data = snapshot.data;
                if (data == null) {
                  return _buildErrorState('No data available');
                }

                return Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('System Metrics'),
                      const SizedBox(height: 16),
                      // Responsive Grid for Metrics
                      LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                          return GridView.count(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            shrinkWrap: true,
                            childAspectRatio: 1.1,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildMetricCard(
                                'Total Revenue',
                                '\$${data.totalRevenue.toStringAsFixed(0)}',
                                Icons.attach_money_rounded,
                                [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
                              ),
                              _buildMetricCard(
                                'Active Gyms',
                                '${data.totalGyms}',
                                Icons.fitness_center_rounded,
                                [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
                              ),
                              _buildMetricCard(
                                'Members',
                                '${data.activeMembers}',
                                Icons.people_alt_rounded,
                                [const Color(0xFF7b4397), const Color(0xFFdc2430)],
                              ),
                              _buildMetricCard(
                                'Pending Approvals',
                                '${data.pendingGyms}',
                                Icons.pending_actions_rounded,
                                [const Color(0xFFf12711), const Color(0xFFf5af19)],
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 32),
                      _buildSectionHeader('Revenue Trends (30 Days)'),
                      const SizedBox(height: 16),
                      _buildChartCard(),

                      const SizedBox(height: 32),
                      _buildSectionHeader('Action Items'),
                      const SizedBox(height: 16),
                      _buildActionItem(
                        'Review Gym Applications',
                        '${data.pendingGyms} gyms waiting for approval',
                        Icons.store_rounded,
                        AppTheme.accent,
                      ),
                      _buildActionItem(
                        'Expiring Memberships',
                        '${data.expiringMemberships} members expiring this week',
                        Icons.warning_amber_rounded,
                        AppTheme.error,
                      ),
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, List<Color> gradient) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
             AppTheme.surface.withOpacity(0.8),
             AppTheme.surface.withOpacity(0.4),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '\$${value.toInt()}k',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 10,
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3),
                FlSpot(1, 4),
                FlSpot(2, 3.5),
                FlSpot(3, 5),
                FlSpot(4, 7),
                FlSpot(5, 6),
                FlSpot(6, 9),
              ],
              isCurved: true,
              color: AppTheme.accent,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accent.withOpacity(0.5),
                    AppTheme.accent.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary),
        onTap: () {},
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.warning_amber_rounded, size: 60, color: AppTheme.error.withOpacity(0.8)),
            const SizedBox(height: 16),
            const Text(
              'Dashboard Unavailable',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            )
          ],
        ),
      ),
    );
  }
}
