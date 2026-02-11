import 'package:flutter/material.dart';
import '../services/data_service.dart';
// import '../widgets/add_edit_category_modal.dart'; // Ensure this widget exists if you want to use it

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _service = DataService();

  void _showAddModal() async {
    // Implement Add Category using API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddModal,
        label: const Text('Add Category'),
        icon: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _service.categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final cat = _service.categories[index];
          Color catColor;
          try { catColor = Color(int.parse(cat.color.replaceFirst('#', '0xFF'))); } catch(_) { catColor = Colors.grey; }

          return Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: catColor.withOpacity(0.1),
                child: Text(cat.icon, style: const TextStyle(fontSize: 20)),
              ),
              title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: cat.isCustom
                  ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  // Implement Delete API call
                },
              )
                  : const Chip(label: Text('Default', style: TextStyle(fontSize: 10))),
            ),
          );
        },
      ),
    );
  }
}