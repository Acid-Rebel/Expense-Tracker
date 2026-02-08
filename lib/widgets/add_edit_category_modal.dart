import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';

class AddEditCategoryModal extends StatefulWidget {
  final Category? category; // If null, we are adding
  const AddEditCategoryModal({super.key, this.category});

  @override
  State<AddEditCategoryModal> createState() => _AddEditCategoryModalState();
}

class _AddEditCategoryModalState extends State<AddEditCategoryModal> {
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = Colors.blue;

  final List<IconData> _icons = [
    Icons.fastfood, Icons.directions_bus, Icons.bolt, Icons.shopping_bag,
    Icons.movie, Icons.flight, Icons.medical_services, Icons.pets,
    Icons.school, Icons.fitness_center, Icons.work, Icons.home,
  ];

  final List<Color> _colors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.teal, Colors.green,
    Colors.orange, Colors.deepOrange, Colors.brown, Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.category == null ? 'New Category' : 'Edit Category',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Pick an Icon', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _icons.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _icons[index] == _selectedIcon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = _icons[index]),
                  child: CircleAvatar(
                    backgroundColor: isSelected ? _selectedColor.withOpacity(0.2) : Colors.grey.shade100,
                    child: Icon(_icons[index], color: isSelected ? _selectedColor : Colors.grey),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text('Pick a Color', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _colors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _colors[index] == _selectedColor;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = _colors[index]),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _colors[index],
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(width: 3, color: Colors.black) : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                // Save logic
                final newCat = Category(
                  id: widget.category?.id ?? DateTime.now().toString(),
                  name: _nameController.text,
                  icon: _selectedIcon,
                  color: _selectedColor,
                  isCustom: true,
                );

                if (widget.category == null) {
                  MockDataService().addCategory(newCat);
                } else {
                  // Edit logic would go here (update existing object)
                }
                Navigator.pop(context, true);
              }
            },
            child: const Text('Save Category'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}