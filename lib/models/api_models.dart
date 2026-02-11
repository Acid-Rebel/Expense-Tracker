class Category {
  final String id;
  final String name;
  final String icon; // API sends string (e.g., "⛽")
  final String color; // API sends hex (e.g., "#FF9800")
  final bool isCustom;

  Category({required this.id, required this.name, required this.icon, required this.color, this.isCustom = true});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed',
      icon: json['icon'] ?? '📁',
      color: json['color'] ?? '#000000',
      isCustom: json['is_custom'] ?? true,
    );
  }
}

class Group {
  final String id;
  final String name;

  Group({required this.id, required this.name});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
    );
  }
}




class AiParseResult {
  final double amount;
  final String categoryName;
  final String description;
  final double confidence;

  AiParseResult({required this.amount, required this.categoryName, required this.description, required this.confidence});

  factory AiParseResult.fromJson(Map<String, dynamic> json) {
    return AiParseResult(
      amount: (json['amount'] as num).toDouble(),
      categoryName: json['category'],
      description: json['description'],
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

class Expense {
  final String id;
  final double amount;
  final String description;
  final String categoryId; // We will store the ID or Name here
  final String categoryName; // Helper for UI
  final DateTime date;
  final String? groupId;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.date,
    this.groupId,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    // Handle "amount" being int or double or string
    double parsedAmount = 0.0;
    if (json['amount'] != null) {
      parsedAmount = double.tryParse(json['amount'].toString()) ?? 0.0;
    }

    // Handle "category" which might be an ID (String) or an Object
    String parsedCatId = '1';
    String parsedCatName = 'General';

    if (json['category'] is Map) {
      parsedCatId = json['category']['id']?.toString() ?? '1';
      parsedCatName = json['category']['name']?.toString() ?? 'General';
    } else if (json['category'] != null) {
      // If it's just a string/int ID
      parsedCatId = json['category'].toString();
      // We might need to look up the name later, or use ID as name temporarily
      parsedCatName = json['category_name']?.toString() ?? 'Category';
    }

    // Handle Date
    DateTime parsedDate = DateTime.now();
    if (json['date'] != null) {
      parsedDate = DateTime.tryParse(json['date'].toString()) ?? DateTime.now();
    } else if (json['expense_date'] != null) {
      // Checking alternative field name often used in Django
      parsedDate = DateTime.tryParse(json['expense_date'].toString()) ?? DateTime.now();
    }

    return Expense(
      id: json['id']?.toString() ?? '',
      amount: parsedAmount,
      description: json['description']?.toString() ?? 'No Description',
      categoryId: parsedCatId,
      categoryName: parsedCatName,
      date: parsedDate,
      groupId: json['group']?.toString(),
    );
  }
}