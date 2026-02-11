import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/api_models.dart';
import 'expense_list_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';
import 'edit_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {}); // Rebuild UI when data updates
  }

  final List<Widget> _pages = [
    const HomeDashboard(),
    const ExpenseListScreen(),
    const InsightsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final bool showFab = _selectedIndex == 0 || _selectedIndex == 1;

    return Scaffold(
      body: _dataService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add_expense');
          // Refresh data when returning from Add Screen to show new entries immediately
          _dataService.loadInitialData();
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final service = DataService();
    // Use Real Data
    final totalSpent = service.monthlyTotal;
    final expenses = service.expenses;

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.indigo,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
        // Group Switcher Connected to Real Groups
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: service.currentGroupContext.value,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            hint: const Text('Personal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Personal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              ...service.groups.map((g) => DropdownMenuItem(
                value: g.id,
                child: Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ))
            ],
            onChanged: (val) {
              service.setGroupContext(val);
            },
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => service.loadInitialData(),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.currentGroupContext.value == null ? 'Total Spent This Month' : 'Group Total This Month',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text('\$${totalSpent.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Text('Budget: \$2,000', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (totalSpent / 2000).clamp(0.0, 1.0),
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Expenses List
            const Text('Recent Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (expenses.isEmpty)
              const Padding(padding: EdgeInsets.all(16), child: Text("No expenses here yet."))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expenses.take(3).length,
                itemBuilder: (context, index) {
                  final e = expenses[index];
                  final cat = service.getCategoryById(e.categoryId);

                  // Helper to parse hex color
                  Color catColor;
                  try {
                    catColor = Color(int.parse(cat.color.replaceFirst('#', '0xFF')));
                  } catch(_) { catColor = Colors.grey; }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditExpenseScreen(expense: e), // 'e' is the expense variable from the loop
                          ),
                        );
                        // Refresh data
                        DataService().loadInitialData();
                      },
                      leading: CircleAvatar(
                        backgroundColor: catColor.withOpacity(0.1),
                        child: Text(cat.icon, style: const TextStyle(fontSize: 20)), // Display Emoji
                      ),
                      title: Text(e.description),
                      subtitle: Text('${e.date.month}/${e.date.day} • ${cat.name}'),
                      trailing: Text('-\$${e.amount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}