import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:someone_talking/config/api_config.dart';

class LoginViewModel extends ChangeNotifier {
  String email = '';
  String senha = '';
  bool isLoading = false;
  String? errorMessage;

  String? jwtToken;
  String? userId;

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setSenha(String value) {
    senha = value;
    notifyListeners();
  }

  Future<bool> login() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final body = {
        'email': email,
        'password': senha,
      };

      final headers = {
        'Content-Type': 'application/json',
        if (jwtToken != null) 'Authorization': 'Bearer $jwtToken',
      };

      final response = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: headers,
        body: jsonEncode(body),
      );
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        jwtToken = data['access_token'];

        if (jwtToken == null) {
          errorMessage = 'Token não recebido da API.';
          isLoading = false;
          notifyListeners();
          return false;
        }

        Map<String, dynamic> payload = JwtDecoder.decode(jwtToken!);
        userId = payload['sub'];
        debugPrint('User ID extraído do token: $userId');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwtToken', jwtToken!);
        await prefs.setString('userId', userId!);

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Email ou senha inválidos';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      errorMessage = 'Erro ao fazer login: $e';
      notifyListeners();
      return false;
    }
  }
}
