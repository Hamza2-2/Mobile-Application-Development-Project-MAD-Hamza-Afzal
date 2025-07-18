import 'package:flutter/material.dart';
import 'package:flutter_django_recipes_frontend/recipe_detail_page.dart';
import 'package:flutter_django_recipes_frontend/services/recipe_service.dart';
import 'package:flutter_django_recipes_frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GenerateRecipePage extends StatefulWidget {
  const GenerateRecipePage({super.key});

  @override
  State<GenerateRecipePage> createState() => _GenerateRecipePageState();
}

class _GenerateRecipePageState extends State<GenerateRecipePage> {
  final List<String> paletteList = [
    'savory',
    'spicy',
    'sweet',
    'sour',
    'herby',
    'umami',
    'earthy',
    'fruity',
    'smoky',
    'neutral',
    'bitter',
  ];

  String? selectedPalette;
  List<Map<String, dynamic>> recommendedRecipes = [];
  bool isLoading = false;
  bool isGenerating = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserIngredients();
  }

  Future<void> _loadUserIngredients() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final ingredients = await _getUserTopIngredients();
      if (ingredients.isEmpty) {
        setState(() {
          errorMessage =
              'No ingredients found in your recipes. Add some recipes first.';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load your ingredients: $e';
        isLoading = false;
      });
      debugPrint('Error loading ingredients: $e');
    }
  }

  Future<List<String>> _getUserTopIngredients() async {
    final client = http.Client();
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await client.get(
        Uri.parse('${RecipeService.baseUrl}/recipes/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final recipes = jsonDecode(response.body) as List;

        if (recipes.isEmpty) return [];

        final ingredientCounts = <String, int>{};

        for (final recipe in recipes) {
          final ingredients = recipe['ingredients'] as List;
          for (final ing in ingredients) {
            final name = ing['name'].toString().toLowerCase().trim();
            ingredientCounts[name] = (ingredientCounts[name] ?? 0) + 1;
          }
        }

        final sortedIngredients =
            ingredientCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

        final topIngredients =
            sortedIngredients.take(4).map((e) => e.key).toList();
        return topIngredients;
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  Future<void> _generateRecipes() async {
    if (selectedPalette == null) {
      setState(() => errorMessage = 'Please select a palette');
      return;
    }

    setState(() {
      isGenerating = true;
      errorMessage = null;
      recommendedRecipes = [];
    });

    try {
      final ingredients = await _getUserTopIngredients();
      if (ingredients.isEmpty) {
        throw Exception('No ingredients found in your recipes');
      }

      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${RecipeService.baseUrl}/recipes/recommend/'),
        headers: headers,
        body: jsonEncode({
          'ingredients': ingredients,
          'palette': [selectedPalette],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          recommendedRecipes = List<Map<String, dynamic>>.from(data);
          isGenerating = false;
        });
      } else {
        throw Exception(
          'Failed to generate recipes: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to generate recipes: $e';
        isGenerating = false;
      });
    }
  }

  Future<void> _saveRecipe(Map<String, dynamic> recipe) async {
  try {
    final recipeName = recipe['recipe_name'] ?? recipe['name'] ?? 'Unnamed Recipe';
    
    List<String> ingredients = [];
    
    if (recipe['ingredients_list'] != null) {
      if (recipe['ingredients_list'] is String) {
        String ingredientsStr = recipe['ingredients_list'] as String;
        ingredientsStr = ingredientsStr
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll("'", "")
            .trim();
        
        if (ingredientsStr.isNotEmpty) {
          ingredients = ingredientsStr.split(',').map((e) => e.trim()).toList();
        }
      }

      else if (recipe['ingredients_list'] is List) {
        ingredients = (recipe['ingredients_list'] as List)
            .map((e) => e.toString().trim())
            .toList();
      }
    }
    else if (recipe['ingredients'] != null) {
      if (recipe['ingredients'] is String) {
        ingredients = (recipe['ingredients'] as String)
            .split(',')
            .map((e) => e.trim())
            .toList();
      } else if (recipe['ingredients'] is List) {
        ingredients = (recipe['ingredients'] as List)
            .map((e) => e.toString().trim())
            .toList();
      }
    }

    
    final savedRecipe = await RecipeService.addRecipe(
      name: recipeName,
      description: 'AI-generated $selectedPalette recipe',
      ingredients: ingredients,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved ${savedRecipe['name']} to your recipes!'),
        backgroundColor: Colors.green,
      ),
    );
    
    setState(() {
      recommendedRecipes.removeWhere((r) => 
        (r['recipe_name'] ?? r['name']) == recipeName);
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to save recipe: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
    debugPrint('Error saving recipe: $e');
  }
}

  void _viewRecipeDetails(Map<String, dynamic> recipe) {
  final recipeName = recipe['recipe_name'] ?? recipe['name'] ?? 'Unnamed Recipe';
  
  List<Map<String, dynamic>> ingredientsList = [];
  
  if (recipe['ingredients_list'] != null) {
    if (recipe['ingredients_list'] is String) {
      String ingredientsStr = recipe['ingredients_list'] as String;
      
      ingredientsStr = ingredientsStr
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll("'", "")
          .trim();
      
      if (ingredientsStr.isNotEmpty) {
        ingredientsList = ingredientsStr
            .split(',')
            .map((ingredient) => {'name': ingredient.trim()})
            .toList();
      }
    }
    else if (recipe['ingredients_list'] is List) {
      ingredientsList = (recipe['ingredients_list'] as List)
          .map((ingredient) => {'name': ingredient.toString().trim()})
          .toList();
    }
  } 
  else if (recipe['ingredients'] != null) {
    if (recipe['ingredients'] is String) {
      ingredientsList = (recipe['ingredients'] as String)
          .split(',')
          .map((ingredient) => {'name': ingredient.trim()})
          .toList();
    } else if (recipe['ingredients'] is List) {
      ingredientsList = (recipe['ingredients'] as List).map((ingredient) {
        if (ingredient is Map) {
          return {'name': ingredient['name']?.toString().trim() ?? 'Unknown'};
        } else {
          return {'name': ingredient.toString().trim()};
        }
      }).toList();
    }
  }

  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RecipeDetailPage(recipe: {
        'name': recipeName,
        'description': 'AI-generated $selectedPalette recipe with ${recipe['palette'] ?? selectedPalette ?? 'various'} flavors',
        'ingredients': ingredientsList,
      }),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Recipe Generator')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const Text(
                      'Select Flavor Palette:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          paletteList.map((palette) {
                            return ChoiceChip(
                              label: Text(palette.capitalize()),
                              selected: selectedPalette == palette,
                              onSelected: (selected) {
                                setState(() {
                                  selectedPalette = selected ? palette : null;
                                  errorMessage = null;
                                });
                              },
                              selectedColor: Colors.blue.shade300,
                              backgroundColor: Colors.grey.shade200,
                              labelStyle: TextStyle(
                                color:
                                    selectedPalette == palette
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: ElevatedButton(
                        onPressed: isGenerating ? null : _generateRecipes,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child:
                            isGenerating
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text('Generate Recipes'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (recommendedRecipes.isNotEmpty)
                      const Text(
                        'Recommended Recipes:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: recommendedRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = recommendedRecipes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                recipe['recipe_name'] ?? recipe['name'],
                              ),
                              subtitle: Text(
                                recipe['matched_palette'] ??
                                    'Flavor: $selectedPalette',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.save),
                                onPressed: () => _saveRecipe(recipe),
                                tooltip: 'Save Recipe',
                              ),
                              onTap: () => _viewRecipeDetails(recipe),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
