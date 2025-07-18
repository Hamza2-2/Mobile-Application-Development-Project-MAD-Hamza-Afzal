import 'package:flutter/material.dart';
import 'package:flutter_django_recipes_frontend/home_page.dart';
import 'package:flutter_django_recipes_frontend/generate_recipe_page.dart';
import 'package:flutter_django_recipes_frontend/constraints_recipe.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    GenerateRecipePage(),
    ConstraintsRecipe(),
  ];

  @override
  void initState() {
    super.initState();
    _verifyAuthStatus();
  }

  Future<void> _verifyAuthStatus() async {
    setState(() => _isLoading = false);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'Generate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_mosaic),
            label: 'Constraints',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}