import 'package:flutter/material.dart';
import '../services/mock_data_service.dart'; // Import service
import 'expense_list_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Need to rebuild body when group context changes
  // We wrap the body in a ValueListenableBuilder inside the methods below?
  // Easier: Wrap the Scaffold body or just the dashboard part.

  final List<Widget> _pages = [
    const HomeDashboard(),
    const ExpenseListScreen(),
    const InsightsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only show FAB on Dashboard (0) or List (1)
    final bool showFab = _selectedIndex == 0 || _selectedIndex == 1;

    return Scaffold(
      body: ValueListenableBuilder<String?>(
        valueListenable: MockDataService().currentGroupContext,
        builder: (context, currentGroupId, child) {
          // This ensures the entire shell rebuilds if the group context changes
          // effectively refreshing the child pages that depend on the data service.
          return _pages[_selectedIndex];
        },
      ),
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
        onPressed: () => Navigator.pushNamed(context, '/add_expense'),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}

// ---------------------------------------------------------
// Internal Widget: Dashboard Content (Tab 0)
// ---------------------------------------------------------
class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MockDataService();
    // Get filtered expenses based on current context
    final expenses = service.getFilteredExpenses();
    final totalSpent = expenses.fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.indigo,
            child: Text('JD', style: TextStyle(color: Colors.white)),
          ),
        ),
        // --- UPDATED TITLE: Group Switcher ---
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: service.currentGroupContext.value,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Personal Expenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              ...service.groups.map((g) => DropdownMenuItem(
                value: g.id,
                child: Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ))
            ],
            onChanged: (val) {
              service.currentGroupContext.value = val;
            },
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
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

            // Recent Expenses List (Mocked subset)
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
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cat.color.withOpacity(0.1),
                        child: Icon(cat.icon, color: cat.color),
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