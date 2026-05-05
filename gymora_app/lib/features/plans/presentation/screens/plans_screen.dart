import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/plans_provider.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlansProvider>().loadPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Consumer<PlansProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: const Text('My Plans', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  ),
                ),

                // Week Day Selector
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final dates = List.generate(7, (i) {
                          final now = DateTime.now();
                          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                          return startOfWeek.add(Duration(days: i));
                        });
                        final isSelected = provider.selectedDay == index;
                        final isToday = dates[index].day == DateTime.now().day;

                        return GestureDetector(
                          onTap: () => provider.setSelectedDay(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.accent : AppTheme.surface,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                              border: isToday && !isSelected
                                  ? Border.all(color: AppTheme.accent.withOpacity(0.5), width: 1.5)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  days[index],
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: isSelected ? AppTheme.primaryDark : AppTheme.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${dates[index].day}',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? AppTheme.primaryDark : AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Workout Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                    child: Row(
                      children: [
                        const Icon(Icons.fitness_center_rounded, color: AppTheme.accent, size: 20),
                        const SizedBox(width: 8),
                        const Text('Workouts', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Workout Cards
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= provider.workoutPlans.length) return null;
                        final plan = provider.workoutPlans[index];
                        final exercises = plan['exercises'] as List;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                                child: const Icon(Icons.fitness_center_rounded, color: AppTheme.accent, size: 22),
                              ),
                              title: Text(plan['title'], style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                              subtitle: Row(
                                children: [
                                  Text('${plan['duration']}', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppTheme.textTertiary)),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.secondary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                    ),
                                    child: Text(plan['difficulty'], style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.secondary)),
                                  ),
                                ],
                              ),
                              iconColor: AppTheme.textSecondary,
                              collapsedIconColor: AppTheme.textTertiary,
                              children: exercises.map<Widget>((exercise) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(exercise['name'], style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppTheme.textPrimary)),
                                      ),
                                      Text(exercise['sets'], style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.accent)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                      childCount: provider.workoutPlans.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Diet Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                    child: Row(
                      children: [
                        const Icon(Icons.restaurant_rounded, color: AppTheme.warning, size: 20),
                        const SizedBox(width: 8),
                        const Text('Meal Plan', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        const Spacer(),
                        Text(
                          '${provider.dietPlans.fold<int>(0, (sum, m) => sum + (m['calories'] as int))} kcal total',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Meal Cards
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= provider.dietPlans.length) return null;
                        final meal = provider.dietPlans[index];
                        final items = meal['items'] as List;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.warning.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                                child: const Icon(Icons.restaurant_rounded, color: AppTheme.warning, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(meal['meal'], style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                        const Spacer(),
                                        Text(meal['time'], style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppTheme.textTertiary)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ...items.map<Widget>((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: Text('• $item', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppTheme.textSecondary)),
                                    )),
                                    const SizedBox(height: 4),
                                    Text('${meal['calories']} kcal', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.warning)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: provider.dietPlans.length,
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
}
