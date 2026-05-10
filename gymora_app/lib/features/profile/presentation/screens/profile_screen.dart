import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/routes.dart';
import '../providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gym_owner/presentation/providers/gym_owner_provider.dart';

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
      final authProvider = context.read<AuthProvider>();
      context.read<ProfileProvider>().loadProfile();
      if (authProvider.isGymAdmin) {
        context.read<GymOwnerProvider>().loadDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Consumer3<ProfileProvider, AuthProvider, GymOwnerProvider>(
        builder: (context, profileProvider, authProvider, gymOwnerProvider, _) {
          final profile = profileProvider.profileData;
          final membership = profileProvider.membershipData;
          final isOwner = authProvider.isGymAdmin;
          
          final gymData = isOwner 
            ? (gymOwnerProvider.gymProfile ?? profileProvider.gymData)
            : profileProvider.gymData;

          if (profileProvider.isLoading || (isOwner && gymOwnerProvider.isLoading)) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
          }

          final memberCount = gymData['customerCount']?.toString() ?? 
                            (isOwner ? gymOwnerProvider.members.length.toString() : '0');
          final trainerCount = gymData['trainerCount']?.toString() ?? 
                             (isOwner ? gymOwnerProvider.trainers.length.toString() : '0');

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── Header ───
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                  decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: isOwner ? const LinearGradient(colors: [Color(0xFF1D2671), Color(0xFFC33764)]) : AppTheme.accentGradient,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: (isOwner ? const Color(0xFFC33764) : AppTheme.accent).withOpacity(0.3), blurRadius: 16)],
                        ),
                        child: Center(
                          child: Text(
                            (profile['fullName'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile['fullName'] ?? 'User',
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isOwner ? 'Gym Business Owner' : (profile['email'] ?? ''),
                              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Stats Row ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: isOwner 
                    ? Row(
                        children: [
                          _buildStatCard('👥', memberCount, '', 'Members'),
                          const SizedBox(width: 10),
                          _buildStatCard('👨‍🏫', trainerCount, '', 'Trainers'),
                          const SizedBox(width: 10),
                          _buildStatCard('📈', '4.9', '', 'Rating'),
                        ],
                      )
                    : Row(
                        children: [
                          _buildStatCard('🏋️', '${profile['weight'] ?? '-'}', 'kg', 'Weight'),
                          const SizedBox(width: 10),
                          _buildStatCard('📏', '${profile['height'] ?? '-'}', 'cm', 'Height'),
                          const SizedBox(width: 10),
                          _buildStatCard('💪', '${profile['bmi'] ?? '-'}', '', 'BMI'),
                        ],
                      ),
                ),
              ),

              // ─── Card Section (Business vs Membership) ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: isOwner 
                    ? _buildBusinessCard(gymData)
                    : _buildMembershipCard(profile, membership),
                ),
              ),

              // ─── Actions ───
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildActionTile(Icons.person_outline_rounded, isOwner ? 'Gym Details' : 'Edit Profile', isOwner ? 'Manage your gym profile' : 'Update your info', () {
                      if (isOwner) {
                        Navigator.pushNamed(context, AppRoutes.gymOwnerDashboard);
                      } else {
                        _showComingSoon(context);
                      }
                    }),
                    if (isOwner) _buildActionTile(Icons.people_outline_rounded, 'Manage Members', 'View and add members', () {
                      Navigator.pushNamed(context, AppRoutes.gymMembers);
                    }),
                    if (isOwner) _buildActionTile(Icons.sports_martial_arts_rounded, 'Manage Trainers', 'View and assign trainers', () {
                      Navigator.pushNamed(context, AppRoutes.gymTrainers);
                    }),
                    if (isOwner) _buildActionTile(Icons.credit_card_rounded, 'Subscription', 'Platform billing & plans', () {
                      Navigator.pushNamed(context, AppRoutes.subscription);
                    }),
                    _buildActionTile(Icons.notifications_outlined, 'Notifications', 'Manage alerts', () {
                      Navigator.pushNamed(context, AppRoutes.notifications);
                    }),
                    _buildActionTile(Icons.help_outline_rounded, 'Help & Support', 'Get assistance', () {
                      _showComingSoon(context);
                    }),
                    const SizedBox(height: 24),
                    // Logout
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton.icon(
                        onPressed: () async {
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, AppRoutes.login);
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF6B6B), size: 20),
                        label: const Text('Log Out', style: TextStyle(color: Color(0xFFFF6B6B), fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600)),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Feature coming soon!', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: AppTheme.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String unit, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                text: value,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                children: [
                  TextSpan(
                    text: unit.isNotEmpty ? ' $unit' : '',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppTheme.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.textTertiary)),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipCard(Map<String, dynamic> profile, Map<String, dynamic> membership) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.fitness_center_rounded, color: AppTheme.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile['gymName'] ?? 'No Gym', style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text(membership['planName'] ?? 'No Plan', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.6))),
                    ],
                  ),
                ),
                _buildStatusBadge(membership['status'] ?? 'INACTIVE'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (membership['progress'] as num?)?.toDouble() ?? 0,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    color: AppTheme.accent,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${membership['daysRemaining'] ?? 0} days left', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.5))),
                    const Spacer(),
                    Text('Expires ${membership['endDate'] ?? '-'}', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.35))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withOpacity(0.08)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: Row(
              children: [
                _buildInfoChip(Icons.person_rounded, profile['trainerName'] ?? 'No Trainer'),
                const SizedBox(width: 10),
                _buildInfoChip(Icons.track_changes_rounded, _formatGoal(profile['goal'] ?? '')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(Map<String, dynamic> gym) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D2671), Color(0xFFC33764)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.business_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gym['name'] ?? 'My Gym Business', style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Business Account', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.7))),
                    ],
                  ),
                ),
                _buildStatusBadge(gym['status'] ?? 'PENDING'),
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildBusinessInfoRow(Icons.location_on_rounded, gym['address'] ?? 'No Address'),
                const SizedBox(height: 12),
                _buildBusinessInfoRow(Icons.phone_rounded, gym['phone'] ?? 'No Phone'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status == 'ACTIVE' || status == 'APPROVED';
    final color = isActive ? AppTheme.accent : const Color(0xFFFF6B6B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(status, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.accent),
            const SizedBox(width: 8),
            Flexible(child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.75)), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessInfoRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider.withOpacity(0.1))),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppTheme.accent, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppTheme.textTertiary)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 20),
        onTap: onTap,
      ),
    );
  }

  String _formatGoal(String goal) {
    if (goal.isEmpty) return 'No Goal';
    return goal.replaceAll('_', ' ').split(' ').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}').join(' ');
  }
}
