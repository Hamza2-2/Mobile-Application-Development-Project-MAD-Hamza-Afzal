import 'package:flutter/material.dart';
import 'package:flutter_django_recipes_frontend/services/recipe_service.dart';
import 'package:flutter_django_recipes_frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ingredients_list.dart';

class ConstraintsRecipe extends StatefulWidget {
  const ConstraintsRecipe({super.key});

  @override
  _ConstraintsRecipeState createState() => _ConstraintsRecipeState();
}

class _ConstraintsRecipeState extends State<ConstraintsRecipe> {
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController fatController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController cholesterolController = TextEditingController();
  final TextEditingController sodiumController = TextEditingController();
  final TextEditingController fiberController = TextEditingController();

  List<String> selectedIngredients = [];
  List<Map<String, dynamic>> recommendations = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> getRecommendations() async {
    if (selectedIngredients.isEmpty) {
      setState(() => errorMessage = 'Please select at least one ingredient');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      recommendations = [];
    });

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${RecipeService.baseUrl}/recipes/recommend_calorie_based/'),
        headers: headers,
        body: jsonEncode({
          'calories': caloriesController.text.isEmpty ? 0 : double.parse(caloriesController.text),
          'fat': fatController.text.isEmpty ? 0 : double.parse(fatController.text),
          'carbs': carbsController.text.isEmpty ? 0 : double.parse(carbsController.text),
          'protein': proteinController.text.isEmpty ? 0 : double.parse(proteinController.text),
          'cholesterol': cholesterolController.text.isEmpty ? 0 : double.parse(cholesterolController.text),
          'sodium': sodiumController.text.isEmpty ? 0 : double.parse(sodiumController.text),
          'fiber': fiberController.text.isEmpty ? 0 : double.parse(fiberController.text),
          'ingredients': selectedIngredients,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          recommendations = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to get recommendations: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

    Future<void> _saveRecipe(Map<String, dynamic> recipe) async {
    try {
      final recipeName = recipe['recipe_name'] ?? recipe['name'] ?? 'Unnamed Recipe';
      
      List<String> ingredients = [];
      if (recipe['ingredients_list'] != null) {
        if (recipe['ingredients_list'] is String) {
          String ingredientsStr = recipe['ingredients_list'].toString();
          ingredientsStr = ingredientsStr
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll("'", "");
          ingredients = ingredientsStr.split(',').map((e) => e.trim()).toList();
        } else if (recipe['ingredients_list'] is List) {
          ingredients = (recipe['ingredients_list'] as List)
              .map((e) => e.toString().trim())
              .toList();
        }
      }

      final savedRecipe = await RecipeService.addRecipe(
        name: recipeName,
        description: 'Calorie-optimized recipe',
        ingredients: ingredients,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved ${savedRecipe['name']} to your recipes!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save recipe: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewRecipeDetails(Map<String, dynamic> recipe) {

    
    List<Map<String, String>> ingredientsList = [];
    
    if (recipe['ingredients_list'] != null) {
      if (recipe['ingredients_list'] is String) {
        String ingredientsStr = recipe['ingredients_list'].toString();
        ingredientsStr = ingredientsStr
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll("'", "");
        ingredientsList = ingredientsStr
            .split(',')
            .map((ingredient) => {'name': ingredient.trim()})
            .toList();
      } else if (recipe['ingredients_list'] is List) {
        ingredientsList = (recipe['ingredients_list'] as List)
            .map((ingredient) => {'name': ingredient.toString().trim()})
            .toList();
      }
    }
  }
  Widget buildIngredientSelection() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: const Text(
            'Ingredients:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedIngredients.map((ingredient) {
            return Chip(
              label: Text(ingredient),
              onDeleted: () => setState(() {
                selectedIngredients.remove(ingredient);
              }),
              deleteIcon: const Icon(Icons.close, size: 18),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        
        SizedBox(
          height: screenHeight * 0.4,
          child: Card(
            elevation: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Available Ingredients',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: availableIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = availableIngredients[index];
                      final isSelected = selectedIngredients.contains(ingredient);
                      return CheckboxListTile(
                        title: Text(ingredient),
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              selectedIngredients.add(ingredient);
                            } else {
                              selectedIngredients.remove(ingredient);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie-Based Recipes'),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),

            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nutrition Constraints',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    buildTextField('Calories (kcal)', caloriesController, TextInputType.number),
                    buildTextField('Fat (g)', fatController, TextInputType.number),
                    buildTextField('Carbs (g)', carbsController, TextInputType.number),
                    buildTextField('Protein (g)', proteinController, TextInputType.number),
                    buildTextField('Cholesterol (mg)', cholesterolController, TextInputType.number),
                    buildTextField('Sodium (mg)', sodiumController, TextInputType.number),
                    buildTextField('Fiber (g)', fiberController, TextInputType.number),
                  ],
                ),
              ),
            ),

            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: buildIngredientSelection(),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isLoading ? null : getRecommendations,
                child: isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Get Recommendations',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Recommended Recipes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            buildRecommendationList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  Widget buildRecommendationList() {
    if (recommendations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'No recommendations yet. Adjust your constraints and try again.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final recipe = recommendations[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _viewRecipeDetails(recipe),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        recipe['recipe_name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () => _saveRecipe(recipe),
                        tooltip: 'Save Recipe',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (recipe['ingredients_list'] is String 
                        ? recipe['ingredients_list'].toString()
                            .replaceAll('[', '')
                            .replaceAll(']', '')
                            .replaceAll("'", "")
                        : (recipe['ingredients_list'] as List).join(', ')),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}