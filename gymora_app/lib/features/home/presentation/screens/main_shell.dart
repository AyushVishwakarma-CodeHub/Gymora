import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../activity/presentation/screens/activity_screen.dart';
import '../../../plans/presentation/screens/plans_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../admin_dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../../trainer_dashboard/presentation/screens/trainer_dashboard_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Define screens and nav items dynamically based on role
  List<Widget> _getScreens(String role) {
    if (role == 'SUPER_ADMIN' || role == 'GYM_ADMIN') {
      return const [
        AdminDashboardScreen(),
        Center(child: Text('Gyms Management (Coming Soon)', style: TextStyle(color: Colors.white))),
        Center(child: Text('Trainers Management (Coming Soon)', style: TextStyle(color: Colors.white))),
        ProfileScreen(),
      ];
    } else if (role == 'TRAINER') {
      return const [
        TrainerDashboardScreen(),
        Center(child: Text('Trainees List (Coming Soon)', style: TextStyle(color: Colors.white))),
        Center(child: Text('Chat (Coming Soon)', style: TextStyle(color: Colors.white))),
        ProfileScreen(),
      ];
    } else {
      // DEFAULT / CUSTOMER
      return const [
        HomeScreen(),
        ActivityScreen(),
        PlansScreen(),
        ProfileScreen(),
      ];
    }
  }

  List<Map<String, dynamic>> _getNavItems(String role) {
    if (role == 'SUPER_ADMIN' || role == 'GYM_ADMIN') {
      return [
        {'icon': Icons.dashboard_rounded, 'inactiveIcon': Icons.dashboard_outlined, 'label': 'Overview'},
        {'icon': Icons.fitness_center_rounded, 'inactiveIcon': Icons.fitness_center, 'label': 'Gyms'},
        {'icon': Icons.people_rounded, 'inactiveIcon': Icons.people_outline, 'label': 'Trainers'},
        {'icon': Icons.person_rounded, 'inactiveIcon': Icons.person_outline_rounded, 'label': 'Profile'},
      ];
    } else if (role == 'TRAINER') {
      return [
        {'icon': Icons.dashboard_rounded, 'inactiveIcon': Icons.dashboard_outlined, 'label': 'Dashboard'},
        {'icon': Icons.directions_run_rounded, 'inactiveIcon': Icons.directions_run_outlined, 'label': 'Trainees'},
        {'icon': Icons.chat_bubble_rounded, 'inactiveIcon': Icons.chat_bubble_outline_rounded, 'label': 'Chat'},
        {'icon': Icons.person_rounded, 'inactiveIcon': Icons.person_outline_rounded, 'label': 'Profile'},
      ];
    } else {
      // DEFAULT / CUSTOMER
      return [
        {'icon': Icons.home_rounded, 'inactiveIcon': Icons.home_outlined, 'label': 'Home'},
        {'icon': Icons.bar_chart_rounded, 'inactiveIcon': Icons.bar_chart_outlined, 'label': 'Activity'},
        {'icon': Icons.calendar_month_rounded, 'inactiveIcon': Icons.calendar_month_outlined, 'label': 'Plans'},
        {'icon': Icons.person_rounded, 'inactiveIcon': Icons.person_outline_rounded, 'label': 'Profile'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the auth provider for the current role
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.userRole;

    final screens = _getScreens(role);
    final navItems = _getNavItems(role);

    // Safeguard index if role changes dynamically
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.primary,
          border: Border(
            top: BorderSide(
              color: AppTheme.divider.withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                return _buildNavItem(
                  index,
                  item['icon'] as IconData,
                  item['inactiveIcon'] as IconData,
                  item['label'] as String,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppTheme.accent : AppTheme.textTertiary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
