import 'package:flutter/material.dart';

class TrainerDashboardScreen extends StatelessWidget {
  const TrainerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Dashboard'),
      ),
      body: const Center(
        child: Text('Trainer Dashboard Screen'),
      ),
    );
  }
}
