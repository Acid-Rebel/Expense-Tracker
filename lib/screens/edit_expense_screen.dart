import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';

class EditExpenseScreen extends StatefulWidget {
  const EditExpenseScreen({super.key});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  // Controllers
  final _descController = TextEditingController(text: 'Lunch at Subway');
  final _amountController = TextEditingController(text: '12.50');

  // State for dropdowns
  String? _selectedCategoryId;
  String? _selectedGroupId;
  final MockDataService _service = MockDataService();

  @override
  void initState() {
    super.initState();
    // Initialize with existing data (mocked for now)
    _selectedCategoryId = _service.categories.first.id;
    _selectedGroupId = null; // Personal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Description
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Group Switcher (Existing Logic)
            DropdownButtonFormField<String?>(
              value: _selectedGroupId,
              decoration: const InputDecoration(labelText: 'Expense For', border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem(value: null, child: Text('Personal')),
                ..._service.groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name)))
              ],
              onChanged: (val) => setState(() => _selectedGroupId = val),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: _service.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
            ),
            const SizedBox(height: 16),

            // Date Picker (Static for now)
            TextFormField(
              initialValue: '2023-10-24',
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 40),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  // Update logic would go here
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Update Expense'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  // Delete logic would go here
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Delete Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}