import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/routes.dart';
import '../providers/auth_provider.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

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
  final _addressController = TextEditingController();
  
  // Trainer Specific
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedinController = TextEditingController();
  int? _selectedGymId;
  List<dynamic> _gyms = [];
  bool _isLoadingGyms = false;

  bool _obscurePassword = true;
  String _selectedRole = 'CUSTOMER';

  final List<Map<String, dynamic>> _roles = [
    {'label': 'Member', 'value': 'CUSTOMER', 'icon': Icons.person_rounded, 'color': AppTheme.accent},
    {'label': 'Trainer', 'value': 'TRAINER', 'icon': Icons.sports_gymnastics_rounded, 'color': AppTheme.secondary},
    {'label': 'Gym Owner', 'value': 'GYM_ADMIN', 'icon': Icons.business_rounded, 'color': AppTheme.warning},
  ];

  @override
  void initState() {
    super.initState();
    _fetchGyms();
  }

  Future<void> _fetchGyms() async {
    setState(() => _isLoadingGyms = true);
    try {
      final response = await ApiClient().dio.get(ApiConstants.activeGyms);
      if (response.data['success']) {
        setState(() {
          _gyms = response.data['data'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching gyms: $e');
    } finally {
      setState(() => _isLoadingGyms = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _certificationsController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == 'TRAINER' && _selectedGymId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gym to enroll in'), backgroundColor: Colors.orange),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    
    // Format social links as JSON or string
    final socialLinks = 'Instagram: ${_instagramController.text}, LinkedIn: ${_linkedinController.text}';

    final success = await authProvider.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      role: _selectedRole,
      address: _addressController.text.trim(),
      gymId: _selectedRole == 'TRAINER' ? _selectedGymId : null,
      specialization: _selectedRole == 'TRAINER' ? _specializationController.text.trim() : null,
      experienceYears: _selectedRole == 'TRAINER' ? int.tryParse(_experienceController.text) : null,
      bio: _selectedRole == 'TRAINER' ? _bioController.text.trim() : null,
      certifications: _selectedRole == 'TRAINER' ? _certificationsController.text.trim() : null,
      socialLinks: _selectedRole == 'TRAINER' ? socialLinks : null,
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
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
                const Text('I am joining as a',
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
                              color: isSelected ? role['color'] : AppTheme.divider.withOpacity(0.1),
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

                const SizedBox(height: 32),

                // Base Fields
                _buildField(_nameController, 'Full Name', Icons.person_outline_rounded, 'Name is required'),
                const SizedBox(height: 20),
                _buildField(_emailController, 'Email', Icons.email_outlined, 'Email is required', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildField(_phoneController, 'Phone', Icons.phone_outlined, null, keyboardType: TextInputType.phone),
                const SizedBox(height: 20),
                _buildField(_passwordController, 'Password', Icons.lock_outline_rounded, 'Password required', isPassword: true),
                const SizedBox(height: 20),
                _buildField(_addressController, 'Address', Icons.location_on_outlined, 'Address is required'),

                // Trainer Specific Fields
                if (_selectedRole == 'TRAINER') ...[
                  const SizedBox(height: 32),
                  const Divider(color: AppTheme.divider),
                  const SizedBox(height: 24),
                  const Text('Trainer Credentials',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('These details help the gym owner verify your application',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppTheme.textSecondary)),
                  
                  const SizedBox(height: 24),
                  _buildLabel('Select Gym to Join'),
                  const SizedBox(height: 8),
                  _buildGymDropdown(),
                  
                  const SizedBox(height: 20),
                  _buildField(_specializationController, 'Specialization', Icons.workspace_premium_outlined, 'Required (e.g. Yoga, Strength)'),
                  const SizedBox(height: 20),
                  _buildField(_experienceController, 'Years of Experience', Icons.history_rounded, 'Required', keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  _buildLabel('Professional Certifications'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _certificationsController,
                    maxLines: 2,
                    style: const TextStyle(fontFamily: 'Inter', color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'e.g. ACE Certified, Yoga Alliance RYT-200',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildField(_instagramController, 'Instagram Handle', Icons.camera_alt_outlined, null),
                  const SizedBox(height: 20),
                  _buildField(_linkedinController, 'LinkedIn Profile', Icons.link_rounded, null),
                  const SizedBox(height: 20),
                  _buildLabel('Brief Biography'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    style: const TextStyle(fontFamily: 'Inter', color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Tell us about your fitness background...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Bio is required' : null,
                  ),
                ],

                const SizedBox(height: 40),

                // Error Message
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.errorMessage != null && auth.state == AuthState.error) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                        ),
                        child: auth.state == AuthState.loading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primaryDark))
                            : const Text('Submit Application', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, String? errorText, {TextInputType? keyboardType, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          keyboardType: keyboardType,
          style: const TextStyle(fontFamily: 'Inter', color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter your $label',
            prefixIcon: Icon(icon, color: AppTheme.textTertiary, size: 22),
            suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppTheme.textTertiary, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          ),
          validator: errorText != null ? (v) => (v == null || v.isEmpty) ? errorText : null : null,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary));
  }

  Widget _buildGymDropdown() {
    if (_isLoadingGyms) {
      return const Center(child: LinearProgressIndicator(color: AppTheme.accent));
    }
    
    if (_gyms.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: const Text('No approved gyms found. Please contact admin.', style: TextStyle(color: AppTheme.error, fontSize: 13)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.divider.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedGymId,
          isExpanded: true,
          dropdownColor: AppTheme.surface,
          hint: const Text('Select a Gym', style: TextStyle(color: AppTheme.textTertiary, fontSize: 14)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textTertiary),
          items: _gyms.map<DropdownMenuItem<int>>((gym) {
            return DropdownMenuItem<int>(
              value: gym['id'],
              child: Text(gym['name'] ?? 'Unknown Gym', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedGymId = val),
        ),
      ),
    );
  }
}

