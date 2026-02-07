import 'package:flutter/material.dart';
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

  // Pages for the bottom nav
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
    // We only show the FAB on the dashboard (index 0) or expense list (index 1)
    final bool showFab = _selectedIndex == 0 || _selectedIndex == 1;

    return Scaffold(
      body: _pages[_selectedIndex],
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
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.indigo,
            child: Text('JD', style: TextStyle(color: Colors.white)),
          ),
        ),
        title: const Text('October 2023'),
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
                    const Text('Total Spent This Month', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    const Text('\$1,250.00',
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Text('Budget: \$2,000', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.625,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category Overview
            const Text('Category Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                // Placeholder for Pie Chart using standard widgets
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 30, color: Colors.indigo.shade100),
                  ),
                  child: const Center(child: Text('65%', style: TextStyle(fontWeight: FontWeight.bold))),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recent Expenses List
            const Text('Recent Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade50,
                      child: const Icon(Icons.shopping_bag, color: Colors.indigo),
                    ),
                    title: const Text('Groceries'),
                    subtitle: const Text('Today, 10:30 AM'),
                    trailing: const Text('-\$45.00', style: TextStyle(fontWeight: FontWeight.bold)),
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