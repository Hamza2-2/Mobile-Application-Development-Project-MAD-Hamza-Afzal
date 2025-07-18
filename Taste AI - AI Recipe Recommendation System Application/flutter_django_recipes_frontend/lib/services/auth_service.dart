import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:9091';
  static String? sessionCookie;
  static String? csrfToken;

  static Map<String, String> _extractCookies(Map<String, String> headers) {
    final setCookie = headers['set-cookie'] ?? '';
    final cookies = setCookie.split(',');

    String? session;
    String? csrf;

    for (var cookie in cookies) {
      if (cookie.contains('sessionid=')) {
        session = cookie.split(';')[0].trim().split('=').last;
      } else if (cookie.contains('csrftoken=')) {
        csrf = cookie.split(';')[0].trim().split('=').last;
      }
    }

    return {
      if (session != null) 'sessionid': session,
      if (csrf != null) 'csrftoken': csrf,
    };
  }

  static Future<Map<String, dynamic>?> getCsrfToken() async {
    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/gettingcsrftoken/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final cookies = _extractCookies(response.headers);
        csrfToken = cookies['csrftoken'];
        sessionCookie = cookies['sessionid'];
        return {
          'csrfToken': csrfToken,
          'csrfCookie': 'csrftoken=$csrfToken; sessionid=$sessionCookie',
        };
      }
      return null;
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final csrfData = await getCsrfToken();
    if (csrfData == null) {
      return {'success': false, 'message': 'Failed to get CSRF token'};
    }

    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRFToken': csrfData['csrfToken']!,
          'Cookie': csrfData['csrfCookie']!,
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['success']) {
          final cookies = _extractCookies(response.headers);
          sessionCookie = cookies['sessionid'] ?? sessionCookie;
          return {'success': true, 'message': 'Login successful'};
        } 
        return {'success': false, 'message': 'Invalid credentials'};
      } else {
        return {'success': false, 'message': 'Invalid credentials'};
      }
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final csrfData = await getCsrfToken();
    if (csrfData == null) {
      return {'success': false, 'message': 'Failed to get CSRF token'};
    }

    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/register/'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRFToken': csrfData['csrfToken']!,
          'Cookie': csrfData['csrfCookie'] ?? '',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['success']){
          final cookies = _extractCookies(response.headers);
        sessionCookie = cookies['sessionid'] ?? sessionCookie;
        csrfToken = cookies['csrftoken'] ?? csrfToken;
        return {'success': true, 'message': 'Registration successful'};
        }
        return {'success': false, 'message': 'Registration failed'};
        
      } else {
        return {'success': false, 'message': 'Registration failed'};
      }
    } finally {
      client.close();
    }
  }

  static Future<bool?> sendResetPasswordEmail(String email) async {
    final client = http.Client();
    final csrfData = await getCsrfToken();
    if (csrfData == null) {
      print("Failed to get CSRF token");
      return null;
    }

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/resetPassword/'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRFToken': csrfData['csrfToken']!,
          'Cookie': '${csrfData['csrfCookie']}; ${sessionCookie ?? ''}',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['success'] as bool?;
      } else {
        print('Failed with status: ${response.statusCode}');
        return null;
      }
    } finally {
      client.close();
    }
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    if (csrfToken == null || sessionCookie == null) {
      await getCsrfToken();
    }
    return {
      'Content-Type': 'application/json',
      'X-CSRFToken': csrfToken ?? '',
      'Cookie': 'csrftoken=$csrfToken; sessionid=$sessionCookie',
    };
  }
}
