import 'package:flutter/material.dart';
import '../services/data_service.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = DataService().monthlyTotal;

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Insights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.deepPurple.shade50,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Spending", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, color: Colors.deepPurple)),
                    const SizedBox(height: 8),
                    const Text("AI Insights coming soon via API..."),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}