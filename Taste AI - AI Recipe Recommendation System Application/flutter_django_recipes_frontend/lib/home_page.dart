import 'package:flutter/material.dart';
import 'package:flutter_django_recipes_frontend/add_edit_recipe_page.dart';
import 'package:flutter_django_recipes_frontend/login_page.dart';
import 'package:flutter_django_recipes_frontend/recipe_detail_page.dart';
import 'package:flutter_django_recipes_frontend/services/recipe_service.dart';
import 'package:flutter_django_recipes_frontend/ingredients_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> recipes = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    
    try {
      final loadedRecipes = await RecipeService.getRecipes();
      setState(() {
        recipes = loadedRecipes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
      _showErrorSnackbar('Failed to load recipes: $e');
    }
  }

  Future<void> _handleAddRecipe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditRecipePage(
          availableIngredients: availableIngredients,
        ),
      ),
    );
    
    if (result != null) {
      try {
        setState(() => isLoading = true);
        final newRecipe = await RecipeService.addRecipe(
          name: result['name'],
          description: result['description'],
          ingredients: result['ingredients'],
        );
        setState(() {
          recipes.add(newRecipe);
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
        _showErrorSnackbar('Failed to add recipe: $e');
      }
    }
  }

  Future<void> _handleEditRecipe(Map<String, dynamic> recipe, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditRecipePage(
          recipe: recipe,
          availableIngredients: availableIngredients,
        ),
      ),
    );
    
    if (result != null) {
      try {
        setState(() => isLoading = true);
        final updatedRecipe = await RecipeService.updateRecipe(
          id: recipe['id'],
          name: result['name'],
          description: result['description'],
          ingredients: result['ingredients'],
        );
        setState(() {
          recipes[index] = updatedRecipe;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
        _showErrorSnackbar('Failed to update recipe: $e');
      }
    }
  }

  Future<void> _handleDeleteRecipe(int index) async {
    final recipe = recipes[index];
    try {
      setState(() => isLoading = true);
      await RecipeService.deleteRecipe(recipe['id']);
      setState(() {
        recipes.removeAt(index);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackbar('Failed to delete recipe: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _viewRecipeDetails(Map<String, dynamic> recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(recipe: recipe),
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Widget _buildRecipeList() {
    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecipes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (recipes.isEmpty) {
      return const Center(
        child: Text('No recipes found. Add your first recipe!'),
      );
    }

    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final ingredients = (recipe['ingredients'] as List<dynamic>)
            .map<String>((i) => i['name'] as String)
            .join(', ');

        return Card(
          margin: const EdgeInsets.all(8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              recipe['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe['description']),
                const SizedBox(height: 4),
                Text(
                  'Ingredients: $ingredients',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            onTap: () => _viewRecipeDetails(recipe),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _handleEditRecipe(recipe, index);
                if (value == 'delete') _handleDeleteRecipe(index);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _handleAddRecipe,
            tooltip: 'Add Recipe',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRecipes,
              child: _buildRecipeList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddRecipe,
        child: const Icon(Icons.add),
      ),
    );
  }

}
