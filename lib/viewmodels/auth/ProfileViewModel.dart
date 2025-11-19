import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:someone_talking/config/api_config.dart';

class ProfileViewModel extends ChangeNotifier {
  String nome = '';
  String email = '';
  DateTime? dataNascimento;
  String telefone = '';
  bool isLoading = false;
  String? errorMessage;
  String? userId;
  String? profilePhotoUrl;

  Future<void> fetchUserProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString('jwtToken');
      userId = prefs.getString('userId');
      if (jwtToken == null || userId == null) {
        errorMessage = 'Usuário não autenticado';
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('$apiUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        nome = data['name'] ?? '';
        email = data['email'] ?? '';
        telefone = data['phone'] ?? '';
        dataNascimento = data['birthDate'] != null ? DateTime.parse(data['birthDate']) : null;
        profilePhotoUrl = data['profilePhotoUrl'] ?? '';
        isLoading = false;
        notifyListeners();
      } else {
        errorMessage = 'Erro ao buscar perfil';
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Erro: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString('jwtToken');
      if (jwtToken == null) {
        errorMessage = 'Usuário não autenticado';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final body = {
        'name': nome,
        'email': email,
        'phone': telefone,
        'birthDate': dataNascimento?.toIso8601String(),
      };

      final response = await http.put(
        Uri.parse('$apiUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Erro ao atualizar perfil';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Erro: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadProfilePhoto(String filePath) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString('jwtToken');
      userId = prefs.getString('userId');
      if (jwtToken == null || userId == null) {
        errorMessage = 'Usuário não autenticado';
        isLoading = false;
        notifyListeners();
        return false;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/users/$userId/profile-photo'),
      );
      request.headers['Authorization'] = 'Bearer $jwtToken';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        profilePhotoUrl = data['profilePhotoUrl'] ?? '';
        await prefs.setString('userPhotoUrl', profilePhotoUrl ?? '');
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Erro ao enviar foto de perfil';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Erro: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setNome(String value) {
    nome = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setTelefone(String value) {
    telefone = value;
    notifyListeners();
  }

  void setDataNascimento(DateTime value) {
    dataNascimento = value;
    notifyListeners();
  }

  void setProfilePhotoUrl(String value) {
    profilePhotoUrl = value;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');
    await prefs.remove('userId');
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
