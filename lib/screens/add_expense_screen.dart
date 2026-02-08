import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add to pubspec.yaml or remove formatting if not needed
import '../services/mock_data_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final MockDataService _service = MockDataService();

  // Input State
  final TextEditingController _descController = TextEditingController();

  // "AI Detected" State (Defaults)
  double _amount = 0.0;
  String _selectedCategoryId = '1'; // Default to first category
  DateTime _selectedDate = DateTime.now();
  String? _selectedGroupId; // null = Personal

  @override
  void initState() {
    super.initState();
    if (_service.categories.isNotEmpty) {
      _selectedCategoryId = _service.categories.first.id;
    }
    // Auto-select group if we are currently in a group view
    _selectedGroupId = _service.currentGroupContext.value;
  }

  // --- Logic Helpers ---

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
        itemCount: _service.categories.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (ctx, index) {
          final cat = _service.categories[index];
          return ListTile(
            leading: Icon(cat.icon, color: cat.color),
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
            subtitle: const Text('Only visible to you'),
            trailing: _selectedGroupId == null ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: () {
              setState(() => _selectedGroupId = null);
              Navigator.pop(ctx);
            },
          ),
          const Divider(),
          ..._service.groups.map((group) => ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.groups, color: Colors.white)),
            title: Text(group.name),
            subtitle: Text('Shared with ${group.memberCount} members'),
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

  void _saveExpense() {
    if (_amount > 0 && _descController.text.isNotEmpty) {
      _service.addExpense(Expense(
        id: DateTime.now().toString(),
        description: _descController.text,
        amount: _amount,
        date: _selectedDate,
        categoryId: _selectedCategoryId,
        groupId: _selectedGroupId,
        userId: 'current_user',
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a description and amount.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current Category and Group objects for display
    final displayCategory = _service.categories.firstWhere(
            (c) => c.id == _selectedCategoryId,
        orElse: () => _service.categories.first
    );

    final displayGroupName = _selectedGroupId == null
        ? 'Personal'
        : _service.groups.firstWhere((g) => g.id == _selectedGroupId, orElse: () => Group(id: '', name: 'Unknown', memberCount: 0)).name;

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

            // Voice Input
            Center(
              child: FloatingActionButton.large(
                onPressed: () {
                  // Simulate AI Parsing
                  setState(() {
                    _descController.text = "Groceries at Walmart";
                    _amount = 250.0;
                    _selectedCategoryId = '1'; // Food
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Simulating AI extraction...")),
                  );
                },
                elevation: 2,
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: const Icon(Icons.mic, size: 40),
              ),
            ),
            const SizedBox(height: 32),

            // AI Preview Section
            const Text('AI Detected Details', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    // 1. Amount
                    _buildInteractiveField(
                      label: 'Amount',
                      value: _amount == 0 ? 'Tap to set' : '\$${_amount.toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      onTap: _showAmountDialog,
                      isHighlight: _amount == 0,
                    ),
                    const Divider(height: 1, indent: 56),

                    // 2. Category
                    _buildInteractiveField(
                      label: 'Category',
                      value: displayCategory.name,
                      icon: displayCategory.icon,
                      iconColor: displayCategory.color,
                      onTap: _showCategoryPicker,
                    ),
                    const Divider(height: 1, indent: 56),

                    // 3. Group / Context (NEW)
                    _buildInteractiveField(
                      label: 'Expense For',
                      value: displayGroupName,
                      icon: _selectedGroupId == null ? Icons.person : Icons.groups,
                      iconColor: _selectedGroupId == null ? Colors.blue : Colors.orange,
                      onTap: _showGroupPicker,
                    ),
                    const Divider(height: 1, indent: 56),

                    // 4. Date
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

            // Buttons
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