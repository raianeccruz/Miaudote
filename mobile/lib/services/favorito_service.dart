import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/animal.dart';
import 'auth_service.dart';

class FavoritoItem {
  final int id;
  final Animal animal;

  const FavoritoItem({required this.id, required this.animal});

  factory FavoritoItem.fromJson(Map<String, dynamic> json) {
    final dadosAnimal = Map<String, dynamic>.from(json['animal'] as Map);

    // O FavoritoResource não retorna user_id.
    // O valor zero evita erro na conversão do modelo Animal.
    dadosAnimal['user_id'] ??= 0;

    return FavoritoItem(
      id: int.parse(json['id'].toString()),
      animal: Animal.fromJson(dadosAnimal),
    );
  }
}

class FavoritoService {
  final String _baseUrl = ApiConstants.baseUrl;
  final AuthService _authService = AuthService();

  Future<String> _obterToken() async {
    final token = await _authService.obterToken();

    if (token == null || token.isEmpty) {
      throw Exception('Usuário não autenticado.');
    }

    return token;
  }

  Map<String, String> _headers(String token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<FavoritoItem>> listar() async {
    final token = await _obterToken();

    final resposta = await http.get(
      Uri.parse('$_baseUrl/favoritos'),
      headers: _headers(token),
    );

    if (resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);

      final List lista = dados is Map ? dados['data'] ?? [] : dados;

      return lista.map((item) {
        return FavoritoItem.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    }

    throw Exception(_mensagemErro(resposta));
  }

  Future<void> adicionar(int animalId) async {
    final token = await _obterToken();

    final resposta = await http.post(
      Uri.parse('$_baseUrl/favoritos'),
      headers: _headers(token),
      body: jsonEncode({'animal_id': animalId}),
    );

    if (resposta.statusCode != 200 && resposta.statusCode != 201) {
      throw Exception(_mensagemErro(resposta));
    }
  }

  Future<void> remover(int favoritoId) async {
    final token = await _obterToken();

    final resposta = await http.delete(
      Uri.parse('$_baseUrl/favoritos/$favoritoId'),
      headers: _headers(token),
    );

    if (resposta.statusCode != 200 && resposta.statusCode != 204) {
      throw Exception(_mensagemErro(resposta));
    }
  }

  String _mensagemErro(http.Response resposta) {
    try {
      final dados = jsonDecode(resposta.body);

      if (dados is Map && dados['message'] != null) {
        return dados['message'].toString();
      }
    } catch (_) {
      // Mantém a mensagem padrão caso a resposta não seja JSON.
    }

    return 'Erro na comunicação com o servidor '
        '(código ${resposta.statusCode}).';
  }
}
