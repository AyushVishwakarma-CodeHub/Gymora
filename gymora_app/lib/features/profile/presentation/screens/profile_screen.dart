import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/routes.dart';
import '../providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Consumer2<ProfileProvider, AuthProvider>(
        builder: (context, profileProvider, authProvider, _) {
          final profile = profileProvider.profileData;
          final membership = profileProvider.membershipData;

          return CustomScrollView(
            slivers: [
              // Gradient Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                  decoration: const BoxDecoration(
                    gradient: AppTheme.headerGradient,
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)],
                        ),
                        child: Center(
                          child: Text(
                            (profile['fullName'] ?? 'A')[0].toUpperCase(),
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile['fullName'] ?? 'User',
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile['email'] ?? '',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      // Body Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatPill('Height', '${profile['height'] ?? '-'} cm'),
                          _buildStatPill('Weight', '${profile['weight'] ?? '-'} kg'),
                          _buildStatPill('BMI', '${profile['bmi'] ?? '-'}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Membership Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF334155)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.card_membership_rounded, color: AppTheme.accent, size: 22),
                            const SizedBox(width: 8),
                            const Text('Membership', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Text(
                                membership['status'] ?? 'N/A',
                                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.accent),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          membership['planName'] ?? 'No Plan',
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (membership['progress'] as double?) ?? 0,
                            backgroundColor: AppTheme.accent.withOpacity(0.15),
                            color: AppTheme.accent,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${membership['daysRemaining'] ?? 0} days remaining',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: (membership['daysRemaining'] ?? 0) <= 5 ? AppTheme.warning : AppTheme.textSecondary,
                                fontWeight: (membership['daysRemaining'] ?? 0) <= 5 ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Expires: ${membership['endDate'] ?? '-'}',
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppTheme.textTertiary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Settings List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSettingTile(Icons.person_outline_rounded, 'Edit Profile', null),
                    _buildSettingTile(Icons.notifications_outlined, 'Notifications', null),
                    _buildSettingTile(Icons.dark_mode_outlined, 'Dark Mode', Switch(
                      value: true,
                      onChanged: (_) {},
                      activeColor: AppTheme.accent,
                    )),
                    _buildSettingTile(Icons.language_rounded, 'Language', const Text('English', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppTheme.textTertiary))),
                    _buildSettingTile(Icons.help_outline_rounded, 'Help & Support', null),
                    _buildSettingTile(Icons.info_outline_rounded, 'About Gymora', null),
                    const SizedBox(height: 16),
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, AppRoutes.login);
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                        label: const Text('Logout', style: TextStyle(color: AppTheme.error, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.error, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, Widget? trailing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.divider.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.textSecondary, size: 22),
        title: Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppTheme.textPrimary)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        onTap: () {},
      ),
    );
  }
}
