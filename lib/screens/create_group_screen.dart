import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert'; // If you need to map manually, but ApiService handles logic

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

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
                onPressed: _isLoading
                    ? null
                    : () async {
                  if (_nameController.text.isNotEmpty) {
                    setState(() => _isLoading = true);
                    // Note: You need to implement createGroup in ApiService if it's not there.
                    // Assuming endpoint POST /groups/ exists.
                    // For now, if your ApiService doesn't have createGroup, you must add it.
                    // await ApiService().createGroup(_nameController.text);
                    Navigator.pop(context);
                  }
                },
                child: _isLoading ? const CircularProgressIndicator() : const Text('Create Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}