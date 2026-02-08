import 'package:flutter/material.dart';
import 'category_management_screen.dart';
import 'group_management_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header (Unchanged)
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('John Doe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('john.doe@example.com', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            // --- NEW: Management Section ---
            _buildSectionHeader('Management'),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.indigo),
              title: const Text('Manage Categories'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoryManagementScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.groups, color: Colors.indigo),
              title: const Text('My Groups'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GroupManagementScreen()),
                );
              },
            ),
            const Divider(),

            // Settings List (Previous items preserved)
            _buildSectionHeader('Preferences'),
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Currency'),
              trailing: const Text('USD', style: TextStyle(color: Colors.grey)),
            ),
            // ... (Rest of existing UI)
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              trailing: Switch(value: false, onChanged: (_) {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.indigo,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}