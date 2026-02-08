import 'package:flutter/material.dart';

// --- Data Models ---
class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isCustom;

  Category({required this.id, required this.name, required this.icon, required this.color, this.isCustom = false});
}

class Group {
  final String id;
  final String name;
  final int memberCount;
  Group({required this.id, required this.name, required this.memberCount});
}

class Expense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? groupId; // null = Personal
  final String userId; // Who created it

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.groupId,
    required this.userId,
  });
}

// --- Mock Service (Singleton) ---
class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // State: Current View Context (Personal vs Specific Group)
  // null = Personal View. String ID = Group View.
  final ValueNotifier<String?> currentGroupContext = ValueNotifier<String?>(null);

  // Data Stores
  final List<Category> categories = [
    Category(id: '1', name: 'Food', icon: Icons.fastfood, color: Colors.orange),
    Category(id: '2', name: 'Transport', icon: Icons.directions_bus, color: Colors.blue),
    Category(id: '3', name: 'Utilities', icon: Icons.bolt, color: Colors.yellow.shade700),
  ];

  final List<Group> groups = [
    Group(id: 'g1', name: 'Family', memberCount: 4),
    Group(id: 'g2', name: 'Roommates', memberCount: 3),
  ];

  final List<Expense> expenses = [
    Expense(id: 'e1', description: 'Groceries', amount: 45.0, date: DateTime.now(), categoryId: '1', groupId: 'g1', userId: 'u1'),
    Expense(id: 'e2', description: 'Uber', amount: 15.0, date: DateTime.now(), categoryId: '2', groupId: null, userId: 'u1'),
  ];

  // Actions
  void addCategory(Category category) {
    categories.add(category);
  }

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id && c.isCustom);
  }

  void addGroup(Group group) {
    groups.add(group);
  }

  void addExpense(Expense expense) {
    expenses.insert(0, expense); // Add to top
  }

  // Helpers
  Category getCategoryById(String id) => categories.firstWhere((c) => c.id == id, orElse: () => categories[0]);

  List<Expense> getFilteredExpenses() {
    if (currentGroupContext.value == null) {
      // Show only personal expenses
      return expenses.where((e) => e.groupId == null).toList();
    } else {
      // Show expenses for specific group
      return expenses.where((e) => e.groupId == currentGroupContext.value).toList();
    }
  }
}