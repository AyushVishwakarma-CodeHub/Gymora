import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/home_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../workout/presentation/screens/workout_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Consumer2<HomeProvider, AuthProvider>(
          builder: (context, homeProvider, authProvider, _) {
            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good ${_getTimeGreeting()} 👋',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authProvider.user?['fullName'] ?? 'Athlete',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Notification Bell
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(Icons.notifications_outlined, color: AppTheme.textSecondary, size: 24),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Center(
                            child: Text(
                              (authProvider.user?['fullName'] ?? 'A')[0].toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Today's Workout Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                ),
                                child: const Text(
                                  "🔥 Today's Workout",
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            homeProvider.todayWorkout?['title'] ?? 'No workout planned',
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildWorkoutStat(Icons.fitness_center_rounded, '${homeProvider.todayWorkout?['exercises'] ?? 0} exercises'),
                              const SizedBox(width: 24),
                              _buildWorkoutStat(Icons.timer_outlined, homeProvider.todayWorkout?['duration'] ?? '0 min'),
                              const SizedBox(width: 24),
                              _buildWorkoutStat(Icons.local_fire_department_rounded, '${homeProvider.todayWorkout?['calories'] ?? 0} kcal'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (homeProvider.fullWorkoutPlan != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WorkoutDetailsScreen(plan: homeProvider.fullWorkoutPlan!),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please wait while we load your workout...')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF16A34A),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                              ),
                              child: const Text('Start Workout', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Quick Stats Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                    child: Row(
                      children: [
                        _buildQuickStat(
                          'Calories',
                          '${homeProvider.todayStats?['caloriesBurned'] ?? 0}',
                          '/ ${homeProvider.todayStats?['caloriesGoal'] ?? 0}',
                          Icons.local_fire_department_rounded,
                          AppTheme.error,
                          (homeProvider.todayStats?['caloriesBurned'] ?? 0) / (homeProvider.todayStats?['caloriesGoal'] ?? 1),
                        ),
                        const SizedBox(width: 12),
                        _buildQuickStat(
                          'Steps',
                          '${homeProvider.todayStats?['stepsWalked'] ?? 0}',
                          '/ ${homeProvider.todayStats?['stepsGoal'] ?? 0}',
                          Icons.directions_walk_rounded,
                          AppTheme.secondary,
                          (homeProvider.todayStats?['stepsWalked'] ?? 0) / (homeProvider.todayStats?['stepsGoal'] ?? 1),
                        ),
                        const SizedBox(width: 12),
                        _buildQuickStat(
                          'Water',
                          '${((homeProvider.todayStats?['waterMl'] ?? 0) / 1000).toStringAsFixed(1)}L',
                          '/ ${((homeProvider.todayStats?['waterGoal'] ?? 0) / 1000).toStringAsFixed(0)}L',
                          Icons.water_drop_rounded,
                          const Color(0xFF06B6D4),
                          (homeProvider.todayStats?['waterMl'] ?? 0) / (homeProvider.todayStats?['waterGoal'] ?? 1),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Section Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                    child: Row(
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Recent Activities
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= homeProvider.recentActivities.length) return null;
                        final activity = homeProvider.recentActivities[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: (activity['type'] == 'workout' ? AppTheme.accent : AppTheme.warning).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                                child: Icon(
                                  activity['type'] == 'workout' ? Icons.fitness_center_rounded : Icons.restaurant_rounded,
                                  color: activity['type'] == 'workout' ? AppTheme.accent : AppTheme.warning,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(activity['title'], style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                    const SizedBox(height: 2),
                                    Text(activity['time'], style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppTheme.textTertiary)),
                                  ],
                                ),
                              ),
                              Text(
                                '${activity['calories']} kcal',
                                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.accent),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: homeProvider.recentActivities.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWorkoutStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white70)),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value, String suffix, IconData icon, Color color, double progress) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            Text(suffix, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.textTertiary)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: color.withOpacity(0.15),
                color: color,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.textTertiary)),
          ],
        ),
      ),
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
