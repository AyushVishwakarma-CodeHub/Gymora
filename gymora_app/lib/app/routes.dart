import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/main_shell.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/activity/presentation/screens/activity_screen.dart';
import '../features/plans/presentation/screens/plans_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/trainer_dashboard/presentation/screens/trainer_dashboard_screen.dart';
import '../features/admin_dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../features/gym_owner/presentation/screens/gym_owner_dashboard_screen.dart';
import '../features/gym_owner/presentation/screens/gym_members_screen.dart';
import '../features/gym_owner/presentation/screens/gym_trainers_screen.dart';
import '../features/gym_owner/presentation/screens/subscription_screen.dart';
import '../features/profile/presentation/screens/notifications_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainShell = '/main';
  static const String home = '/home';
  static const String activity = '/activity';
  static const String plans = '/plans';
  static const String profile = '/profile';
  static const String trainerDashboard = '/trainer-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String gymOwnerDashboard = '/gym-owner-dashboard';
  static const String gymMembers = '/gym-members';
  static const String gymTrainers = '/gym-trainers';
  static const String subscription = '/subscription';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);
      case login:
        return _slideRoute(const LoginScreen(), settings);
      case register:
        return _slideRoute(const RegisterScreen(), settings);
      case mainShell:
        return _fadeRoute(const MainShell(), settings);
      case home:
        return _fadeRoute(const HomeScreen(), settings);
      case activity:
        return _slideRoute(const ActivityScreen(), settings);
      case plans:
        return _slideRoute(const PlansScreen(), settings);
      case profile:
        return _slideRoute(const ProfileScreen(), settings);
      case trainerDashboard:
        return _fadeRoute(const TrainerDashboardScreen(), settings);
      case adminDashboard:
        return _fadeRoute(const AdminDashboardScreen(), settings);
      case gymOwnerDashboard:
        return _fadeRoute(const GymOwnerDashboardScreen(), settings);
      case gymMembers:
        return _slideRoute(const GymMembersScreen(), settings);
      case gymTrainers:
        return _slideRoute(const GymTrainersScreen(), settings);
      case subscription:
        return _slideRoute(const SubscriptionScreen(), settings);
      case notifications:
        return _slideRoute(const NotificationsScreen(), settings);
      default:
        return _fadeRoute(const SplashScreen(), settings);
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
