import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/routes.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedRole = 'CUSTOMER';

  final List<Map<String, dynamic>> _roles = [
    {'label': 'Customer', 'value': 'CUSTOMER', 'icon': Icons.person_rounded, 'color': AppTheme.accent},
    {'label': 'Trainer', 'value': 'TRAINER', 'icon': Icons.sports_gymnastics_rounded, 'color': AppTheme.secondary},
    {'label': 'Gym Admin', 'value': 'GYM_ADMIN', 'icon': Icons.business_rounded, 'color': AppTheme.warning},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _phoneController.text.trim(),
      _selectedRole,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join Gymora and start your fitness journey',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppTheme.textSecondary),
                ),

                const SizedBox(height: 32),

                // Role Selector
                const Text('I am a',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  children: _roles.map((role) {
                    final isSelected = _selectedRole == role['value'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = role['value']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? (role['color'] as Color).withOpacity(0.15) : AppTheme.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: isSelected ? role['color'] : AppTheme.divider,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(role['icon'], color: isSelected ? role['color'] : AppTheme.textTertiary, size: 28),
                              const SizedBox(height: 8),
                              Text(
                                role['label'],
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? role['color'] : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Name
                _buildLabel('Full Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontFamily: 'Inter', color: AppTheme.textPrimary),
                  decoration: const InputDecoration(hintText: 'Enter your full name', prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.textTertiary)),
                  validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                ),

                const SizedBox(height: 20),

                // Email
                _buildLabel('Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontFamily: 'Inter', color: AppTheme.textPrimary),
                  decoration: const InputDecoration(hintText: 'Enter your email', prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textTertiary)),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Phone
                _buildLabel('Phone'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontFamily: 'Inter', color: AppTheme.textPrimary),
                  decoration: const InputDecoration(hintText: 'Enter your phone number', prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.textTertiary)),
                ),

                const SizedBox(height: 20),

                // Password
                _buildLabel('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(fontFamily: 'Inter', color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textTertiary),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppTheme.textTertiary),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Error
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.errorMessage != null && auth.state == AuthState.error) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(auth.errorMessage!, style: const TextStyle(color: AppTheme.error, fontFamily: 'Inter', fontSize: 13))),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: auth.state == AuthState.loading ? null : _handleRegister,
                        child: auth.state == AuthState.loading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primaryDark))
                            : const Text('Create Account'),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(fontFamily: 'Inter', color: AppTheme.textSecondary, fontSize: 14)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Sign In', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14)),
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

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary));
  }
}
