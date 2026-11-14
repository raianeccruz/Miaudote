import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/solicitacao_adocao.dart';
import 'auth_service.dart';

class SolicitacaoAdocaoService {
  final AuthService _authService = AuthService();

  // Busca todas as solicitações relacionadas ao usuário autenticado.
  Future<List<SolicitacaoAdocao>> listar() async {
    final token = await _authService.obterToken();

    if (token == null) {
      throw Exception('Usuário não autenticado.');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/solicitacoes-adocao');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final dados = jsonDecode(response.body);

      final List<dynamic> lista = dados is Map ? dados['data'] : dados;

      return lista.map((item) => SolicitacaoAdocao.fromJson(item)).toList();
    }

    final dados = jsonDecode(response.body);

    throw Exception(
      dados['message'] ?? 'Não foi possível carregar as solicitações.',
    );
  }

  // Envia uma nova solicitação de adoção.
  Future<void> solicitarAdocao(int animalId) async {
    final token = await _authService.obterToken();

    if (token == null) {
      throw Exception('Usuário não autenticado.');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/solicitacoes-adocao');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'animal_id': animalId}),
    );

    if (response.statusCode == 201) {
      return;
    }

    final dados = jsonDecode(response.body);

    throw Exception(
      dados['message'] ?? 'Não foi possível enviar a solicitação.',
    );
  }

  // Cancela uma solicitação de adoção pendente.
  Future<void> cancelar(int solicitacaoId) async {
    final token = await _authService.obterToken();

    if (token == null) {
      throw Exception('Usuário não autenticado.');
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/solicitacoes-adocao/$solicitacaoId',
    );

    final response = await http.delete(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    final dados = jsonDecode(response.body);

    throw Exception(
      dados['message'] ?? 'Não foi possível cancelar a solicitação.',
    );
  }
}
