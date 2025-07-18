import 'package:flutter/material.dart';
import 'package:flutter_django_recipes_frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SetNewPassword extends StatefulWidget {
  const SetNewPassword({super.key, required this.email});
  final String email;

  @override
  SetNewPasswordState createState() => SetNewPasswordState();
}

class SetNewPasswordState extends State<SetNewPassword> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPassword = true;
  bool _isPassword2 = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _updatePassword() async {
    if (_passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final csrfData = await AuthService.getCsrfToken();
      if (csrfData == null) {
        setState(() {
          _errorMessage = 'Failed to get CSRF token';
          _isLoading = false;
        });
        return;
      }

      final client = http.Client();
      final response = await client.post(
        Uri.parse('${AuthService.baseUrl}/updatePassword/'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRFToken': csrfData['csrfToken'],
          'Cookie': csrfData['csrfCookie'],
        },
        body: json.encode({
          'email': widget.email,
          'new_password': _passwordController.text,
        }),
      );

      final responseData = json.decode(response.body);
      client.close();
      
      if (response.statusCode == 200) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Failed to update password';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Set a new password",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                Padding(padding: EdgeInsets.all(3.0)),
                Text(
                  "Create a new password. Ensure it differs from previous ones for security",
                  style: TextStyle(fontSize: 16.0),
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                
                Text(
                  "Password",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Padding(padding: EdgeInsets.all(2.0)),
                TextField(
                  controller: _passwordController,
                  obscureText: _isPassword,
                  decoration: InputDecoration(
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: IconButton(
                        icon: Icon(
                          _isPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _isPassword = !_isPassword),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        width: 2.0,
                        color: const Color.fromARGB(255, 184, 183, 183),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        width: 2.0,
                        color: const Color.fromARGB(255, 184, 183, 183),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(width: 2.0, color: Colors.black54),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(5.0)),
          
                Text(
                  "Confirm Password",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Padding(padding: EdgeInsets.all(2.0)),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _isPassword2,
                  decoration: InputDecoration(
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: IconButton(
                        icon: Icon(
                          _isPassword2 ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _isPassword2 = !_isPassword2),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        width: 2.0,
                        color: const Color.fromARGB(255, 184, 183, 183),
                    ),),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        width: 2.0,
                        color: const Color.fromARGB(255, 184, 183, 183),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(width: 2.0, color: Colors.black54),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _isLoading ? Colors.blue[200] : Colors.blue,
                    minimumSize: Size(double.infinity, 60.0),
                    side: BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  onPressed: _isLoading ? null : _updatePassword,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Update Password",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}