import 'package:flutter/material.dart';
import '../services/data_service.dart';
import 'edit_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _service = DataService();

  @override
  Widget build(BuildContext context) {
    final expenses = _service.expenses;

    return Scaffold(
      appBar: AppBar(title: const Text('All Expenses')),
      body: Column(
        children: [
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

                Color catColor;
                try { catColor = Color(int.parse(category.color.replaceFirst('#', '0xFF'))); } catch(_) { catColor = Colors.grey; }

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: catColor.withOpacity(0.1),
                      child: Text(category.icon, style: const TextStyle(fontSize: 20)),
                    ),
                    title: Text(expense.description),
                    subtitle: Text(
                      '${expense.date.month}/${expense.date.day} • ${category.name}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('-\$${expense.amount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        if (expense.groupId != null)
                          Icon(Icons.group, size: 14, color: Colors.grey.shade400)
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditExpenseScreen(expense: expense), // Pass the object
                        ),
                      );
                    },
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