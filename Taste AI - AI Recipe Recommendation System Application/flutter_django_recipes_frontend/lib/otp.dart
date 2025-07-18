import 'package:flutter/material.dart';
import 'package:flutter_django_recipes_frontend/set_new_password.dart';
import 'package:flutter_django_recipes_frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key, required this.email});
  final String email;

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    for (var controller in _controllers) {
      controller.addListener(_checkIfAllFieldsFilled);
    }
  }

  void _checkIfAllFieldsFilled() {
    setState(() {
      _isButtonEnabled = _controllers.every(
        (controller) => controller.text.isNotEmpty,
      );
    });
  }

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final otp = _controllers.map((c) => c.text).join();
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
        Uri.parse('${AuthService.baseUrl}/verifyOTP/'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRFToken': csrfData['csrfToken'],
          'Cookie': csrfData['csrfCookie'],
        },
        body: json.encode({
          'email': widget.email,
          'otp': otp,
        }),
      );

      final responseData = json.decode(response.body);
      client.close();
      
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetNewPassword(email: widget.email),
          ),
        );
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Verification failed';
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

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await AuthService.sendResetPasswordEmail(widget.email);
      if (success != true) {
        setState(() {
          _errorMessage = 'Failed to resend OTP';
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
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Check your email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We sent a reset link to ${widget.email}\nEnter 5 digit code that is mentioned in the email',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                return SizedBox(
                  width: 50,
                  height: 50,
                  child: TextField(
                    controller: _controllers[index],
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 4) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isButtonEnabled && !_isLoading
                    ? _verifyOTP
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonEnabled && !_isLoading
                      ? Colors.blue
                      : Colors.grey[300],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Verify Code',
                        style: TextStyle(
                          fontSize: 16,
                          color: _isButtonEnabled && !_isLoading
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _isLoading ? null : _resendOTP,
                child: Text(
                  "Haven't got the email yet? Resend email",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}