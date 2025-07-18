import 'package:flutter/material.dart';

class AddEditRecipePage extends StatefulWidget {
  final Map? recipe;
  final List<String> availableIngredients;

  const AddEditRecipePage({
    super.key,
    this.recipe,
    required this.availableIngredients,
  });

  @override
  State<AddEditRecipePage> createState() => _AddEditRecipePageState();
}

class _AddEditRecipePageState extends State<AddEditRecipePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  List<String> _selectedIngredients = [];
  String? _nameError;
  String? _descError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipe?['name'] ?? '');
    _descController = TextEditingController(
      text: widget.recipe?['description'] ?? '',
    );

    if (widget.recipe != null && widget.recipe!['ingredients'] != null) {
      final ingredientsData = widget.recipe!['ingredients'];
      if (ingredientsData is List) {
        _selectedIngredients =
            ingredientsData.map<String>((e) => e['name'] as String).toList();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    setState(() {
      _nameError = _nameController.text.isEmpty ? 'Recipe name is required' : null;
      _descError = _descController.text.isEmpty ? 'Description is required' : null;
    });
    return _nameError == null && _descError == null;
  }

  void _saveRecipe() {
    if (_validateFields()) {
      Navigator.pop(context, {
        'name': _nameController.text,
        'description': _descController.text,
        'ingredients': _selectedIngredients,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'Add Recipe' : 'Edit Recipe'),
      ),
      body: SafeArea(
        child: ListView(
          
          padding: const EdgeInsets.all(16),
          children: [
            Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter recipe name',
                    errorText: _nameError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (_) {
                    if (_nameError != null) {
                      setState(() => _nameError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter recipe description',
                    errorText: _descError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (_) {
                    if (_descError != null) {
                      setState(() => _descError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Ingredients:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedIngredients.map((ingredient) {
                    return Chip(
                      label: Text(ingredient),
                      onDeleted: () => setState(() {
                        _selectedIngredients.remove(ingredient);
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
                            itemCount: widget.availableIngredients.length,
                            itemBuilder: (context, index) {
                              final ingredient = widget.availableIngredients[index];
                              final isSelected = _selectedIngredients.contains(ingredient);
                              return CheckboxListTile(
                                title: Text(ingredient),
                                value: isSelected,
                                onChanged: (selected) {
                                  setState(() {
                                    if (selected == true) {
                                      _selectedIngredients.add(ingredient);
                                    } else {
                                      _selectedIngredients.remove(ingredient);
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
                
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.recipe == null ? 'Add Recipe' : 'Save Changes',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}