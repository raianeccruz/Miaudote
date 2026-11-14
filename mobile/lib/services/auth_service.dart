import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';
import '../models/usuario.dart';

class AuthService {
  // Endereço base da API.
  final String _baseUrl = ApiConstants.baseUrl;

  // Cadastra um usuário.
  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String confirmacaoSenha,
  }) async {
    final url = Uri.parse('$_baseUrl/register');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': nome,
        'email': email,
        'password': senha,
        'password_confirmation': confirmacaoSenha,
      }),
    );

    return _processarAutenticacao(response);
  }

  // Realiza o login.
  Future<Usuario> login({required String email, required String senha}) async {
    final url = Uri.parse('$_baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': senha}),
    );

    return _processarAutenticacao(response);
  }

  // Processa a resposta do login ou cadastro.
  Future<Usuario> _processarAutenticacao(http.Response response) async {
    final dados = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final token = dados['token'];

      final preferencias = await SharedPreferences.getInstance();

      await preferencias.setString(ApiConstants.tokenKey, token);

      return Usuario.fromJson(Map<String, dynamic>.from(dados['user']));
    }

    throw Exception(_obterMensagemErro(dados));
  }

  // Busca o token salvo.
  Future<String?> obterToken() async {
    final preferencias = await SharedPreferences.getInstance();

    return preferencias.getString(ApiConstants.tokenKey);
  }

  // Consulta os dados do usuário autenticado.
  Future<Usuario> buscarUsuario() async {
    final token = await obterToken();

    if (token == null) {
      throw Exception('Usuário não autenticado.');
    }

    final url = Uri.parse('$_baseUrl/user');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final dados = jsonDecode(response.body);

      return Usuario.fromJson(Map<String, dynamic>.from(dados));
    }

    throw Exception('Não foi possível buscar o usuário.');
  }

  // Realiza o logout.
  Future<void> logout() async {
    final token = await obterToken();

    if (token == null) {
      return;
    }

    final url = Uri.parse('$_baseUrl/logout');

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final preferencias = await SharedPreferences.getInstance();

      await preferencias.remove(ApiConstants.tokenKey);
    } else {
      throw Exception('Não foi possível realizar o logout.');
    }
  }

  // Obtém uma mensagem de erro retornada pela API.
  String _obterMensagemErro(dynamic dados) {
    if (dados is Map<String, dynamic>) {
      if (dados['errors'] is Map) {
        final erros = dados['errors'] as Map;
        final primeiraChave = erros.keys.first;

        final mensagens = erros[primeiraChave];

        if (mensagens is List && mensagens.isNotEmpty) {
          return mensagens.first.toString();
        }
      }

      if (dados['message'] != null) {
        return dados['message'].toString();
      }
    }

    return 'Ocorreu um erro na comunicação com o servidor.';
  }
}
