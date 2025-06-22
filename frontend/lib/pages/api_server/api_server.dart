import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:22025/api';

  // Метод для входа
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return true;
      } else {
        final data = jsonDecode(response.body);
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }

  // Валидация email при регистрации
  static Future<bool> registration_emailValidation(String email)async {
    try {
      final response = await http.post(
      Uri.parse('$_baseUrl/registration_emailvalidation'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return true;
      } else {
        final data = jsonDecode(response.body);
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }

  // Валидация кода подтверждения
  static Future<bool> registration_codeValidation(String email, String code)async {
    try {
      final response = await http.post(
      Uri.parse('$_baseUrl/registration_codevalidation'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'code': code
      }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return true;
      } else {
        final data = jsonDecode(response.body);
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }

  // Установка пароля
  static Future<bool> registration_password(String email, String password)async {
    try {
      final response = await http.post(
      Uri.parse('$_baseUrl/registration_password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password
      }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return true;
      } else {
        final data = jsonDecode(response.body);
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }

  // Запрос на восстановление пароля
  static Future<bool> forgot_password(String email) async {
    try {
      final response = await http.post(
      Uri.parse('$_baseUrl/forgot_password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return true;
      } else {
        final data = jsonDecode(response.body);
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }
  static Future<bool> resetPassword_codeValidation(String email, String code)async {
    try {
      final response = await http.post(
      Uri.parse('$_baseUrl/commit_code_reset_password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'code': code
      }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return true;
      } else {
        final data = jsonDecode(response.body);
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }
  static Future<bool> resetPassword_resetPassword(String email, String password)async {
    try {
      final response = await http.post(
      Uri.parse('$_baseUrl/reset_password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'newPassword': password
      }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return true;
      } else {
        final data = jsonDecode(response.body);
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }
}