import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../services/api_service.dart';
import '../models/api_models.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final DataService _dataService = DataService();
  final TextEditingController _descController = TextEditingController();

  // State
  double _amount = 0.0;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String? _selectedGroupId;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    if (_dataService.categories.isNotEmpty) {
      _selectedCategoryId = _dataService.categories.first.id;
    }
    _selectedGroupId = _dataService.currentGroupContext.value;
  }

  // --- Logic Helpers ---

  Future<void> _analyzeWithAi() async {
    // 1. Get text directly from the main input field
    final text = _descController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please type a description first (e.g., 'Lunch 15').")),
      );
      return;
    }

    setState(() => _isAnalyzing = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AI is analyzing...")));

    try {
      // 2. Call API
      final result = await ApiService().parseExpense(text, groupId: _selectedGroupId);

      if (!mounted) return;

      setState(() {
        _amount = result.amount;
        _descController.text = result.description; // 3. Replace text with AI refined version

        // 4. Smart Category Matching
        try {
          final match = _dataService.categories.firstWhere(
                (c) => c.name.toLowerCase() == result.categoryName.toLowerCase(),
            orElse: () => _dataService.categories.firstWhere(
                  (c) => c.name.toLowerCase().contains(result.categoryName.toLowerCase()),
            ),
          );
          _selectedCategoryId = match.id;
        } catch (_) {
          // Keep default if no match found
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated details from AI!")));

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("AI Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _showAmountDialog() {
    final controller = TextEditingController(text: _amount == 0 ? '' : _amount.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Amount'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(prefixText: '\$ ', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() => _amount = double.tryParse(controller.text) ?? 0.0);
              Navigator.pop(ctx);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _dataService.categories.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (ctx, index) {
          final cat = _dataService.categories[index];
          // Safe color parsing
          Color catColor;
          try { catColor = Color(int.parse(cat.color.replaceFirst('#', '0xFF'))); } catch(_) { catColor = Colors.grey; }

          return ListTile(
            leading: Text(cat.icon, style: const TextStyle(fontSize: 24)),
            title: Text(cat.name),
            onTap: () {
              setState(() => _selectedCategoryId = cat.id);
              Navigator.pop(ctx);
            },
            trailing: _selectedCategoryId == cat.id ? const Icon(Icons.check, color: Colors.green) : null,
          );
        },
      ),
    );
  }

  void _showGroupPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Who is this expense for?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
            title: const Text('Personal'),
            trailing: _selectedGroupId == null ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: () {
              setState(() => _selectedGroupId = null);
              Navigator.pop(ctx);
            },
          ),
          const Divider(),
          ..._dataService.groups.map((group) => ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.groups, color: Colors.white)),
            title: Text(group.name),
            trailing: _selectedGroupId == group.id ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: () {
              setState(() => _selectedGroupId = group.id);
              Navigator.pop(ctx);
            },
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _saveExpense() async {
    if (_amount > 0 && _selectedCategoryId != null) {
      final expenseData = {
        "amount": _amount,
        "description": _descController.text.isEmpty ? "Untitled" : _descController.text,
        "category": _selectedCategoryId,
        "expense_date": DateFormat('yyyy-MM-dd').format(_selectedDate),
        "group": _selectedGroupId
      };

      if (_selectedGroupId == null) expenseData.remove("group");

      try {
        final success = await ApiService().createExpense(expenseData);
        if (success) {
          // Force refresh
          await DataService().fetchExpenses();
          if (mounted) Navigator.pop(context);
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to save")));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter amount and category.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safe lookup for display
    final displayCategory = _dataService.categories.firstWhere(
            (c) => c.id == _selectedCategoryId,
        orElse: () => Category(id: '0', name: 'Select', icon: '❓', color: '#808080')
    );

    final displayGroupName = _selectedGroupId == null
        ? 'Personal'
        : _dataService.groups.firstWhere((g) => g.id == _selectedGroupId, orElse: () => Group(id: '', name: 'Unknown')).name;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Large Input
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'e.g., Paid 250 for groceries at Walmart',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // AI Action Button (Modified to trigger directly)
            Center(
              child: FloatingActionButton.large(
                onPressed: _isAnalyzing ? null : _analyzeWithAi,
                elevation: 2,
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: _isAnalyzing
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.auto_awesome, size: 40), // Changed icon to indicate magic/AI
              ),
            ),
            const SizedBox(height: 10),
            const Center(child: Text("Type above & tap to Autofill", style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 32),

            // Details Section
            const Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    _buildInteractiveField(
                      label: 'Amount',
                      value: _amount == 0 ? 'Tap to set' : '\$${_amount.toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      onTap: _showAmountDialog,
                      isHighlight: _amount == 0,
                    ),
                    const Divider(height: 1, indent: 56),

                    // Category
                    InkWell(
                      onTap: _showCategoryPicker,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text(displayCategory.icon, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Category', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(displayCategory.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 56),

                    _buildInteractiveField(
                      label: 'Expense For',
                      value: displayGroupName,
                      icon: _selectedGroupId == null ? Icons.person : Icons.groups,
                      iconColor: _selectedGroupId == null ? Colors.blue : Colors.orange,
                      onTap: _showGroupPicker,
                    ),
                    const Divider(height: 1, indent: 56),

                    _buildInteractiveField(
                      label: 'Date',
                      value: DateFormat('MMM dd, yyyy').format(_selectedDate),
                      icon: Icons.calendar_today,
                      onTap: _pickDate,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveExpense,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Save Expense'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.grey,
    bool isHighlight = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isHighlight ? Colors.blue : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}