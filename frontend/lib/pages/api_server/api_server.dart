import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:8080/api';

  // Метод для входа
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

  // Валидация email при регистрации
  static Future<http.Response> registration_emailValidation(String email) async {
    return await http.post(
      Uri.parse('$_baseUrl/registration_emailvalidation'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );
  }

  // Валидация кода подтверждения
  static Future<http.Response> registration_codeValidation(String email, String code) async {
    return await http.post(
      Uri.parse('$_baseUrl/registration_codevalidation'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'code': code
      }),
    );
  }

  // Установка пароля
  static Future<http.Response> registration_password(String email, String password) async {
    return await http.post(
      Uri.parse('$_baseUrl/registration_password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password
      }),
    );
  }
}