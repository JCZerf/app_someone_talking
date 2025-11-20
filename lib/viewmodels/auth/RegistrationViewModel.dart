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
  String? profilePhotoUrl;

  bool isLoading = false;
  String? errorMessage;

  String? jwtToken;

  void setJwtToken(String token) {
    jwtToken = token;
    notifyListeners();
  }

  Future<bool> register({String? profilePhotoFilePath}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final String phoneClean = telefone.replaceAll(RegExp(r'\D'), '');

    try {
      var uri = Uri.parse('$apiUrl/auth/registration');

      if (profilePhotoFilePath != null && profilePhotoFilePath.isNotEmpty) {
        var request = http.MultipartRequest('POST', uri);

        request.fields['name'] = nome;
        request.fields['password'] = senha;
        request.fields['email'] = email;
        request.fields['birthDate'] = (dataNascimento ?? DateTime.now()).toIso8601String();
        request.fields['phone'] = phoneClean;

        request.files.add(await http.MultipartFile.fromPath(
          'profilePhoto',
          profilePhotoFilePath,
        ));

        if (jwtToken != null) {
          request.headers['Authorization'] = 'Bearer $jwtToken';
        }

        final response = await request.send();
        final respStr = await response.stream.bytesToString();

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(respStr);
          profilePhotoUrl = data['profilePhotoUrl'];
          isLoading = false;
          notifyListeners();
          return true;
        } else {
          errorMessage = 'Erro: $respStr';
          isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        final user = User(
          id: '',
          name: nome,
          password: senha,
          email: email,
          birthDate: dataNascimento ?? DateTime.now(),
          phone: phoneClean,
          profilePhotoUrl: profilePhotoUrl ?? '',
        );

        final body = user.toJson();

        final headers = {
          'Content-Type': 'application/json',
          if (jwtToken != null) 'Authorization': 'Bearer $jwtToken',
        };

        final response = await http.post(
          uri,
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

  void setProfilePhotoUrl(String? url) {
    profilePhotoUrl = url;
    notifyListeners();
  }
}
