import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

class TrainerManagementScreen extends StatefulWidget {
  const TrainerManagementScreen({super.key});

  @override
  State<TrainerManagementScreen> createState() => _TrainerManagementScreenState();
}

class _TrainerManagementScreenState extends State<TrainerManagementScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _trainers = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTrainers();
  }

  Future<void> _loadTrainers() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await _apiClient.dio.get(ApiConstants.trainers);
      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          _trainers = response.data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() { _error = 'Failed to load trainers'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Connection error'; _isLoading = false; });
    }
  }

  List<dynamic> get _filteredTrainers {
    if (_searchQuery.isEmpty) return _trainers;
    return _trainers.where((t) =>
      (t['fullName'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (t['specialization'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text(
          'Trainer Management',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadTrainers,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadTrainers, child: const Text('Try Again')),
          ],
        ),
      );
    }
    if (_filteredTrainers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded, color: AppTheme.textTertiary, size: 48),
            SizedBox(height: 16),
            Text('No trainers found', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: _filteredTrainers.length,
      itemBuilder: (context, index) => _buildTrainerCard(_filteredTrainers[index]),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      style: const TextStyle(color: AppTheme.textPrimary),
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search trainers...',
        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textTertiary),
        filled: true,
        fillColor: AppTheme.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTrainerCard(dynamic trainer) {
    final name = trainer['fullName'] ?? trainer['name'] ?? 'Unknown';
    final specialty = trainer['specialization'] ?? 'General Fitness';
    final gymName = trainer['gymName'] ?? 'Unassigned';
    final isActive = trainer['active'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.divider.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.accent.withOpacity(0.1),
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                Text(
                  specialty,
                  style: const TextStyle(fontSize: 13, color: AppTheme.accent),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.fitness_center_rounded, size: 12, color: AppTheme.textTertiary),
                    const SizedBox(width: 4),
                    Text(gymName, style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isActive ? AppTheme.accent : Colors.orangeAccent).withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              isActive ? 'ACTIVE' : 'INACTIVE',
              style: TextStyle(
                color: isActive ? AppTheme.accent : Colors.orangeAccent,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
