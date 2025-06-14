import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:8080/api'; 

  static Future<http.Response> login(String email, String password) async {
    return await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email, 
        'password': password
      }),
    );
  }
}