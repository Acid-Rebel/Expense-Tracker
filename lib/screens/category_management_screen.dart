import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';
import '../widgets/add_edit_category_modal.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _service = MockDataService();

  void _showAddModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const AddEditCategoryModal(),
    );
    setState(() {}); // Refresh list
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
          return Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: cat.color.withOpacity(0.1),
                child: Icon(cat.icon, color: cat.color),
              ),
              title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: cat.isCustom
                  ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _service.deleteCategory(cat.id);
                  });
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