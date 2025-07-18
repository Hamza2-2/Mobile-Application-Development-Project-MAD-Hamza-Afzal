import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class RecipeService {
  static const String baseUrl = 'http://10.0.2.2:9091';

  static Future<List<dynamic>> getRecipes() async {
    final client = http.Client();
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl/recipes/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load recipes (${response.statusCode})');
      }
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> addRecipe({
    required String name,
    required String description,
    required List<String> ingredients,
  }) async {
    final client = http.Client();
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl/recipes/'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'description': description,
          'ingredients': ingredients,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add recipe (${response.statusCode})');
      }
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> updateRecipe({
    required int id,
    required String name,
    required String description,
    required List<String> ingredients,
  }) async {
    final client = http.Client();
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await client.put(
        Uri.parse('$baseUrl/recipes/$id/'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'description': description,
          'ingredients': ingredients,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update recipe (${response.statusCode})');
      }
    } finally {
      client.close();
    }
  }

  static Future<void> deleteRecipe(int id) async {
    final client = http.Client();
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await client.delete(
        Uri.parse('$baseUrl/recipes/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete recipe (${response.statusCode})');
      }
    } finally {
      client.close();
    }
  }
}