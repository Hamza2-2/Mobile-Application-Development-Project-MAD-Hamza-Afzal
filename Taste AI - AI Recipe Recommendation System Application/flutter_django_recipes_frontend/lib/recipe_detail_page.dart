import 'package:flutter/material.dart';


class RecipeDetailPage extends StatelessWidget {
  final Map recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe['name'])),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(recipe['description']),
            SizedBox(height: 16),
            Text(
              'Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              (recipe['ingredients'] as List)
                  .map((e) => e['name'] as String)
                  .join(', ')
            ),
          ],
        ),
      ),
    );
  }
}
