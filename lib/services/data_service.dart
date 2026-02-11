import 'package:flutter/material.dart';
import '../models/api_models.dart';
import 'api_service.dart';

class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final ApiService _api = ApiService();

  // State
  ValueNotifier<String?> currentGroupContext = ValueNotifier<String?>(null);
  List<Category> categories = [];
  List<Group> groups = [];
  List<Expense> expenses = [];
  double monthlyTotal = 0.0;
  bool isLoading = false;

  // --- Actions ---

  // Initialize App Data (Called after Login)
  Future<void> loadInitialData() async {
    isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        fetchGroups(),
        fetchCategories(),
        fetchExpenses(),
        fetchInsights(),
      ]);
    } catch (e) {
      print("Error loading initial data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGroups() async {
    groups = await _api.getGroups();
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    categories = await _api.getCategories(groupId: currentGroupContext.value);
    notifyListeners();
  }

  Future<void> fetchExpenses() async {
    try {
      // 1. Fetch from API
      final fetchedExpenses = await _api.getExpenses(groupId: currentGroupContext.value);

      // 2. Update State
      expenses = fetchedExpenses;

      // 3. Recalculate Totals immediately for Dashboard
      _recalculateTotal();

      notifyListeners(); // <--- CRITICAL: Updates UI
    } catch (e) {
      //print("Error fetching expenses: $e");
      // Optional: expenses = []; // Clear on error?
      notifyListeners();
    }
  }

  void _recalculateTotal() {
    double total = 0.0;
    for (var e in expenses) {
      total += e.amount;
    }
    monthlyTotal = total;
  }

  Future<void> fetchInsights() async {
    monthlyTotal = await _api.getMonthlyTotal(groupId: currentGroupContext.value);
    notifyListeners();
  }

  // Switch Context (Personal <-> Group)
  void setGroupContext(String? groupId) {
    currentGroupContext.value = groupId;
    loadInitialData(); // Reload everything for the new context
  }

  // Helpers
  Category getCategoryById(String id) {
    return categories.firstWhere(
          (c) => c.id == id,
      orElse: () => Category(id: 'unknown', name: 'Unknown', icon: '❓', color: '#808080'),
    );
  }
}