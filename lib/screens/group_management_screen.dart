import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';
import 'create_group_screen.dart';

class GroupManagementScreen extends StatefulWidget {
  const GroupManagementScreen({super.key});

  @override
  State<GroupManagementScreen> createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final groups = MockDataService().groups;

    return Scaffold(
      appBar: AppBar(title: const Text('My Groups')),
      body: groups.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_off_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No groups yet. Create one!'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _navToCreate(context),
              child: const Text('Create Group'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groups.length + 1, // +1 for the "Create New" card
        itemBuilder: (context, index) {
          if (index == groups.length) {
            return OutlinedButton.icon(
              onPressed: () => _navToCreate(context),
              icon: const Icon(Icons.add),
              label: const Text('Create New Group'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
              ),
            );
          }
          final group = groups[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.groups)),
              title: Text(group.name),
              subtitle: Text('${group.memberCount} members'),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }

  void _navToCreate(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    );
    setState(() {}); // Refresh list
  }
}