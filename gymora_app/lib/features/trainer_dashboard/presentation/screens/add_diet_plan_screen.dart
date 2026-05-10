import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/trainer_provider.dart';

class AddDietPlanScreen extends StatefulWidget {
  final Map<String, dynamic> trainee;

  const AddDietPlanScreen({super.key, required this.trainee});

  @override
  State<AddDietPlanScreen> createState() => _AddDietPlanScreenState();
}

class _AddDietPlanScreenState extends State<AddDietPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _caloriesController = TextEditingController(text: '2000');
  
  final List<Map<String, dynamic>> _meals = [
    {'meal': 'Breakfast', 'time': '08:00 AM', 'items': [''], 'cal': 400}
  ];

  void _addMeal() {
    setState(() {
      _meals.add({'meal': '', 'time': '', 'items': [''], 'cal': 400});
    });
  }

  void _removeMeal(int index) {
    if (_meals.length > 1) {
      setState(() {
        _meals.removeAt(index);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final planData = {
      'customerId': widget.trainee['id'],
      'title': _titleController.text,
      'description': _descController.text,
      'meals': jsonEncode(_meals),
      'targetCalories': int.tryParse(_caloriesController.text) ?? 2000,
      'startDate': DateTime.now().toIso8601String().split('T')[0],
      'isActive': true,
    };

    final success = await context.read<TrainerProvider>().createDietPlan(planData);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diet plan created successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create plan'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add Diet Plan', style: TextStyle(fontFamily: 'Poppins')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('General Info'),
              const SizedBox(height: 12),
              _buildTextField(_titleController, 'Plan Name (e.g. Weight Loss)', (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              _buildTextField(_caloriesController, 'Total Daily Calorie Goal', (v) => v!.isEmpty ? 'Required' : null, keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Daily Meals'),
                  TextButton.icon(
                    onPressed: _addMeal,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Meal'),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _meals.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('Meal Name (e.g. Lunch)'),
                                initialValue: _meals[index]['meal'],
                                onChanged: (v) => _meals[index]['meal'] = v,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: AppTheme.error),
                              onPressed: () => _removeMeal(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('Time'),
                                initialValue: _meals[index]['time'],
                                onChanged: (v) => _meals[index]['time'] = v,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('Calories'),
                                initialValue: _meals[index]['cal'].toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (v) => _meals[index]['cal'] = int.tryParse(v) ?? 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Items (Simple comma separated for now)
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Items (comma separated)'),
                          initialValue: _meals[index]['items'].join(', '),
                          onChanged: (v) => _meals[index]['items'] = v.split(',').map((e) => e.trim()).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9F43),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Save Diet Plan', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, String? Function(String?)? validator, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: Colors.black.withOpacity(0.2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.accent, width: 1)),
    );
  }
}
