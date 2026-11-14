import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

import '../core/constants/api_constants.dart';
import '../models/animal.dart';
import 'auth_service.dart';

class AnimalService {
  final String _baseUrl = ApiConstants.baseUrl;
  final AuthService _authService = AuthService();

  // Lista todos os animais.
  Future<List<Animal>> listar() async {
    final url = Uri.parse('$_baseUrl/animais');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );

    final dados = _decodificar(response.body);

    if (response.statusCode == 200) {
      final lista = dados is Map ? dados['data'] : dados;

      if (lista is! List) {
        throw Exception('Formato de resposta inválido.');
      }

      return lista.map((item) {
        return Animal.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    }

    throw Exception(_obterMensagemErro(dados));
  }

  // Busca um animal pelo ID.
  Future<Animal> buscarPorId(int id) async {
    final url = Uri.parse('$_baseUrl/animais/$id');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );

    final dados = _decodificar(response.body);

    if (response.statusCode == 200) {
      return _converterAnimal(dados);
    }

    throw Exception(_obterMensagemErro(dados));
  }

  // Cadastra um animal, podendo enviar uma imagem.
  Future<Animal> cadastrar({
    required String nome,
    required String especie,
    required int idade,
    required String descricao,
    required String cidade,
    required String estado,
    XFile? imagem,
  }) async {
    final campos = {
      'nome': nome,
      'especie': especie,
      'idade': idade.toString(),
      'descricao': descricao,
      'cidade': cidade,
      'estado': estado,
    };

    final dados = await _enviarFormulario(
      url: Uri.parse('$_baseUrl/animais'),
      campos: campos,
      imagem: imagem,
    );

    return _converterAnimal(dados);
  }

  // Atualiza os dados de um animal.
  Future<Animal> atualizar({
    required int id,
    required String nome,
    required String especie,
    required int idade,
    required String descricao,
    required String cidade,
    required String estado,
    XFile? imagem,
  }) async {
    final campos = {
      'nome': nome,
      'especie': especie,
      'idade': idade.toString(),
      'descricao': descricao,
      'cidade': cidade,
      'estado': estado,
    };

    final dados = await _enviarFormulario(
      url: Uri.parse('$_baseUrl/animais/$id'),
      campos: campos,
      imagem: imagem,
      atualizar: true,
    );

    return _converterAnimal(dados);
  }

  // Exclui um animal.
  Future<void> excluir(int id) async {
    final token = await _obterToken();

    final url = Uri.parse('$_baseUrl/animais/$id');

    final response = await http.delete(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final dados = _decodificar(response.body);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_obterMensagemErro(dados));
    }
  }

  // Envia formulários com ou sem imagem.
  Future<dynamic> _enviarFormulario({
    required Uri url,
    required Map<String, String> campos,
    XFile? imagem,
    bool atualizar = false,
  }) async {
    final token = await _obterToken();

    final request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields.addAll(campos);

    // O Laravel recebe a edição por meio de method spoofing.
    if (atualizar) {
      request.fields['_method'] = 'PUT';
    }

    if (imagem != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'imagem',
          await imagem.readAsBytes(),
          filename: imagem.name,
          contentType: MediaType.parse(imagem.mimeType ?? 'image/jpeg'),
        ),
      );
    }

    final resposta = await request.send();
    final response = await http.Response.fromStream(resposta);

    final dados = _decodificar(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return dados;
    }

    throw Exception(_obterMensagemErro(dados));
  }

  // Recupera o token salvo no login.
  Future<String> _obterToken() async {
    final token = await _authService.obterToken();

    if (token == null || token.isEmpty) {
      throw Exception('Usuário não autenticado.');
    }

    return token;
  }

  // Converte a resposta do Laravel em um objeto Animal.
  Animal _converterAnimal(dynamic dados) {
    final animal = dados is Map && dados['data'] != null
        ? dados['data']
        : dados;

    return Animal.fromJson(Map<String, dynamic>.from(animal));
  }

  // Converte o JSON recebido.
  dynamic _decodificar(String corpo) {
    if (corpo.isEmpty) {
      return <String, dynamic>{};
    }

    return jsonDecode(corpo);
  }

  // Obtém uma mensagem de erro da API.
  String _obterMensagemErro(dynamic dados) {
    if (dados is Map<String, dynamic>) {
      if (dados['errors'] is Map) {
        final erros = dados['errors'] as Map;

        for (final mensagens in erros.values) {
          if (mensagens is List && mensagens.isNotEmpty) {
            return mensagens.first.toString();
          }
        }
      }

      if (dados['message'] != null) {
        return dados['message'].toString();
      }
    }

    return 'Ocorreu um erro na comunicação com o servidor.';
  }
}
