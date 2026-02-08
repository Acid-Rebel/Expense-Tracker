import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _service = MockDataService();

  @override
  Widget build(BuildContext context) {
    // 1. Get filtered expenses
    final expenses = _service.getFilteredExpenses();

    return Scaffold(
      appBar: AppBar(title: const Text('All Expenses')),
      body: Column(
        children: [
          // Top Controls (Unchanged)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search expenses...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.filter_list)),
              ],
            ),
          ),

          // Expense List
          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text("No expenses found."))
                : ListView.separated(
              itemCount: expenses.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final expense = expenses[index];
                final category = _service.getCategoryById(expense.categoryId);

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: category.color.withOpacity(0.1),
                      child: Icon(category.icon, color: category.color),
                    ),
                    title: Text(expense.description),
                    subtitle: Text(
                      // Show Group Name if we are in "All Expenses" view (if you implemented that)
                      // Or just date for now.
                      '${expense.date.month}/${expense.date.day} • ${category.name}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('-\$${expense.amount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        // Show small badge if it's a group expense
                        if (expense.groupId != null)
                          Icon(Icons.group, size: 14, color: Colors.grey.shade400)
                      ],
                    ),
                    onTap: () => Navigator.pushNamed(context, '/edit_expense'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}