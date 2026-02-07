import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Insights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AI Insight Card
            Card(
              color: Colors.deepPurple.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.deepPurple.shade700),
                        const SizedBox(width: 8),
                        Text('AI Analysis',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You spent 15% more on dining out this week compared to last month. Consider cooking at home to save ~Dollar50.',
                      style: TextStyle(color: Colors.deepPurple.shade900),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Weekly Spending Chart Placeholder
            const Text('Weekly Spending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar('Mon', 50),
                  _buildBar('Tue', 80),
                  _buildBar('Wed', 40),
                  _buildBar('Thu', 100),
                  _buildBar('Fri', 70),
                  _buildBar('Sat', 120),
                  _buildBar('Sun', 90),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Monthly Comparison
            const Text('Monthly Comparison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Text('Line Chart Placeholder', style: TextStyle(color: Colors.grey.shade400)),
              ),
            ),
            const SizedBox(height: 30),

            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              label: const Text('Generate New Insights'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            color: Colors.indigo,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}