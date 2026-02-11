import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/api_models.dart';
import '../services/data_service.dart';
import '../services/api_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense; // REQUIRED: The expense to edit

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  final DataService _dataService = DataService();

  late String _selectedCategoryId;
  late DateTime _selectedDate;
  String? _selectedGroupId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 1. Pre-fill form with existing data
    _descController.text = widget.expense.description;
    _amountController.text = widget.expense.amount.toString();
    _selectedCategoryId = widget.expense.categoryId;
    _selectedDate = widget.expense.date;
    _selectedGroupId = widget.expense.groupId;

    // Fallback if category ID from backend doesn't exist locally
    if (!_dataService.categories.any((c) => c.id == _selectedCategoryId)) {
      if (_dataService.categories.isNotEmpty) {
        _selectedCategoryId = _dataService.categories.first.id;
      }
    }
  }

  Future<void> _updateExpense() async {
    if (_descController.text.isEmpty || _amountController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final expenseData = {
      "amount": double.tryParse(_amountController.text) ?? 0.0,
      "description": _descController.text,
      "category": _selectedCategoryId,
      "expense_date": DateFormat('yyyy-MM-dd').format(_selectedDate),
      "group": _selectedGroupId
    };

    if (_selectedGroupId == null) expenseData.remove("group");

    try {
      // 2. Call Update API
      final success = await ApiService().updateExpense(widget.expense.id, expenseData);

      if (success) {
        await DataService().fetchExpenses(); // Refresh list
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update failed")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteExpense() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Expense?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      // 3. Call Delete API
      final success = await ApiService().deleteExpense(widget.expense.id);

      if (success) {
        await DataService().fetchExpenses(); // Refresh list
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Delete failed")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Group Dropdown
            DropdownButtonFormField<String?>(
              value: _selectedGroupId,
              decoration: const InputDecoration(labelText: 'Expense For', border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem(value: null, child: Text('Personal')),
                ..._dataService.groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name)))
              ],
              onChanged: (val) => setState(() => _selectedGroupId = val),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: _dataService.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val!),
            ),
            const SizedBox(height: 16),

            // Date Picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 40),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _updateExpense,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Update Expense'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isLoading ? null : _deleteExpense,
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