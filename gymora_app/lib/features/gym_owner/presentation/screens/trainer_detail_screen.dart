import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/gym_owner_provider.dart';

class TrainerDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trainer;

  const TrainerDetailScreen({super.key, required this.trainer});

  @override
  Widget build(BuildContext context) {
    final bool isApproved = trainer['isApproved'] ?? false;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Trainer Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.accent.withOpacity(0.1),
                    child: Text(
                      (trainer['fullName'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.accent),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    trainer['fullName'] ?? 'Unknown',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isApproved ? AppTheme.accent.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isApproved ? 'ACTIVE' : 'PENDING APPROVAL',
                      style: TextStyle(
                        fontSize: 12, 
                        color: isApproved ? AppTheme.accent : Colors.orange, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Details Section
            _buildDetailItem(Icons.work_rounded, 'Specialization', trainer['specialization'] ?? 'Fitness Coach'),
            _buildDetailItem(Icons.history_rounded, 'Experience', '${trainer['experienceYears'] ?? 0} Years'),
            _buildDetailItem(Icons.email_rounded, 'Email', trainer['email'] ?? 'No email provided'),
            _buildDetailItem(Icons.verified_user_rounded, 'Certifications', trainer['certifications'] ?? 'No certifications listed'),
            _buildDetailItem(Icons.share_rounded, 'Social Profiles', trainer['socialLinks'] ?? 'No social profiles linked'),
            
            const SizedBox(height: 24),
            const Text(
              'Biography',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              trainer['bio'] ?? 'No biography provided for this trainer.',
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
            ),

            const SizedBox(height: 40),

            // Approval Button (Only if pending)
            if (!isApproved)
              _buildApproveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildApproveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          final success = await context.read<GymOwnerProvider>().approveTrainer(trainer['id']);
          if (context.mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trainer approved successfully!'), backgroundColor: Colors.green),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to approve trainer.'), backgroundColor: Colors.red),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Approve Trainer',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accent, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
