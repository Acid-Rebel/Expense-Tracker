import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Use 10.0.2.2 for Android Emulator, localhost for iOS
  static const String _baseUrl = "http://10.0.2.2:8000/api";
  String? _authToken;

  // --- Auth Helpers ---
  Future<Map<String, String>> _getHeaders() async {
    if (_authToken == null) {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('jwt_token');
    }
    return {
      "Content-Type": "application/json",
      if (_authToken != null) "Authorization": "Bearer $_authToken",
    };
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Handle empty bodies (like 204 No Content)
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized: Please login again.");
    } else {
      // Try to extract a specific error message if available
      try {
        final err = jsonDecode(response.body);
        throw Exception(err.toString());
      } catch (_) {
        throw Exception("Error ${response.statusCode}: ${response.body}");
      }
    }
  }

  // --- 🔐 Authentication ---

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _authToken = data['access'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', _authToken!);
      return true;
    }
    return false;
  }

  // ✅ UPDATED SIGNUP METHOD
  Future<bool> signup(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/signup/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username, // Match API field
        "email": email,
        "password": password
      }),
    );

    if (response.statusCode == 201) {
      // AUTO-LOGIN: Store tokens immediately from the response
      final data = jsonDecode(response.body);
      _authToken = data['access']; // Extract access token

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', _authToken!);
      // You can also store 'refresh' token here if you implement refresh logic later

      return true;
    }
    return false;
  }

  // ... (Rest of the methods: getGroups, getCategories, createExpense, etc. remain unchanged) ...

  // For completeness, here are the other required methods referenced previously:
  Future<List<Group>> getGroups() async {
    final response = await http.get(Uri.parse('$_baseUrl/groups/'), headers: await _getHeaders());
    final List data = await _handleResponse(response);
    return data.map((e) => Group.fromJson(e)).toList();
  }

  Future<List<Category>> getCategories({String? groupId}) async {
    String url = '$_baseUrl/categories/';
    if (groupId != null) url += '?group=$groupId';
    final response = await http.get(Uri.parse(url), headers: await _getHeaders());
    final List data = await _handleResponse(response);
    return data.map((e) => Category.fromJson(e)).toList();
  }

  Future<List<Expense>> getExpenses({String? groupId}) async {
    String url = '$_baseUrl/expenses/';
    if (groupId != null) url += '?group=$groupId';

    final response = await http.get(Uri.parse(url), headers: await _getHeaders());

    // Debug print to see what backend actually returns
    print("GET Expenses Response: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Expense.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<bool> createExpense(Map<String, dynamic> expenseData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/expenses/'),
      headers: await _getHeaders(),
      body: jsonEncode(expenseData),
    );
    return response.statusCode == 201;
  }

  // ✏️ Update Expense
  Future<bool> updateExpense(String expenseId, Map<String, dynamic> expenseData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/expenses/$expenseId/'), // Endpoint: /api/expenses/{id}/
      headers: await _getHeaders(),
      body: jsonEncode(expenseData),
    );
    return response.statusCode == 200;
  }

  // ❌ Delete Expense
  Future<bool> deleteExpense(String expenseId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/expenses/$expenseId/'), // Endpoint: /api/expenses/{id}/
      headers: await _getHeaders(),
    );
    return response.statusCode == 204; // 204 No Content = Success
  }

  Future<AiParseResult> parseExpense(String text, {String? groupId}) async {
    final body = {"text": text, if (groupId != null) "group": groupId};
    final response = await http.post(
      Uri.parse('$_baseUrl/ai/parse-expense/'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    final data = await _handleResponse(response);
    return AiParseResult.fromJson(data);
  }

  Future<double> getMonthlyTotal({String? groupId}) async {
    String url = '$_baseUrl/insights/total/';
    if (groupId != null) url += '?group=$groupId';
    final response = await http.get(Uri.parse(url), headers: await _getHeaders());
    final data = await _handleResponse(response);
    return (data['total'] ?? 0.0).toDouble();
  }
}