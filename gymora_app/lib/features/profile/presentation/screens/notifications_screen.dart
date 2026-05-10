import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationTile(
            Icons.new_releases_rounded,
            'New Member Joined',
            'Rahul Sharma has registered at Gymora Fitness Hub.',
            '2 hours ago',
            true,
          ),
          _buildNotificationTile(
            Icons.payments_rounded,
            'Subscription Renewed',
            'Your monthly business plan has been renewed successfully.',
            '1 day ago',
            false,
          ),
          _buildNotificationTile(
            Icons.system_update_rounded,
            'System Update',
            'Gymora version 2.1 is now live with better analytics.',
            '3 days ago',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(IconData icon, String title, String body, String time, bool isNew) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNew ? AppTheme.accent.withOpacity(0.05) : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isNew ? AppTheme.accent.withOpacity(0.2) : AppTheme.divider.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.accent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(time, style: const TextStyle(color: AppTheme.textTertiary, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
