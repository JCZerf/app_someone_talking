import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:someone_talking/config/api_config.dart';

import '../../models/UsersModel.dart';

class RegistrationViewModel extends ChangeNotifier {
  String nome = '';
  String senha = '';
  String email = '';
  DateTime? dataNascimento;
  String telefone = '';

  bool isLoading = false;
  String? errorMessage;

  String? jwtToken;

  void setJwtToken(String token) {
    jwtToken = token;
    notifyListeners();
  }

  Future<bool> register() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final String phoneClean = telefone.replaceAll(RegExp(r'\D'), '');
    debugPrint('Telefone enviado: $phoneClean');

    try {
      final user = User(
        name: nome,
        password: senha,
        email: email,
        birthDate: dataNascimento ?? DateTime.now(),
        phone: phoneClean,
      );

      final body = {
        'name': user.name,
        'password': user.password,
        'email': user.email,
        'birthDate': user.birthDate.toIso8601String(),
        'phone': user.phone,
      };

      final headers = {
        'Content-Type': 'application/json',
        if (jwtToken != null) 'Authorization': 'Bearer $jwtToken',
      };

      final response = await http.post(
        Uri.parse('$apiUrl/auth/registration'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Erro: ${response.body}';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      errorMessage = 'Erro ao cadastrar usuário: $e';
      notifyListeners();
      return false;
    }
  }

  void setNome(String value) {
    nome = value;
    notifyListeners();
  }

  void setSenha(String value) {
    senha = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setDataNascimento(DateTime value) {
    dataNascimento = value;
    notifyListeners();
  }

  void setTelefone(String value) {
    telefone = value;
    notifyListeners();
  }
}
