import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'e.g., Summer Trip, Family',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    MockDataService().addGroup(Group(
                      id: DateTime.now().toString(),
                      name: _nameController.text,
                      memberCount: 1, // You are the first member
                    ));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}