import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/animal.dart';
import '../../models/usuario.dart';
import '../../services/auth_service.dart';
import '../../services/favorito_service.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error.dart';
import '../../widgets/app_loading.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  final FavoritoService _favoritoService = FavoritoService();
  final AuthService _authService = AuthService();

  List<FavoritoItem> _favoritos = [];

  Usuario? _usuario;

  bool _carregando = true;
  String? _erro;

  final Set<int> _favoritosRemovendo = {};

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
    _carregarUsuario();
  }

  // Busca os animais favoritados pelo usuário.
  Future<void> _carregarFavoritos() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final favoritos = await _favoritoService.listar();

      if (!mounted) return;

      setState(() {
        _favoritos = favoritos;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
        _carregando = false;
      });
    }
  }

  // Busca os dados do usuário autenticado.
  Future<void> _carregarUsuario() async {
    try {
      final usuario = await _authService.buscarUsuario();

      if (!mounted) return;

      setState(() {
        _usuario = usuario;
      });
    } catch (e) {
      // Mantém a tela funcionando caso não consiga
      // carregar os dados do perfil.
    }
  }

  // Retorna a inicial do nome do usuário.
  String get _inicialUsuario {
    final nome = _usuario?.nome.trim() ?? '';

    if (nome.isEmpty) {
      return '?';
    }

    return nome[0].toUpperCase();
  }

  // Encerra a sessão e retorna para o login.
  Future<void> _sair() async {
    await _authService.logout();

    if (!mounted) return;

    context.goNamed(AppRoutes.login);
  }

  // Remove um animal da lista de favoritos.
  Future<void> _removerFavorito(FavoritoItem favorito) async {
    if (_favoritosRemovendo.contains(favorito.id)) return;

    setState(() {
      _favoritosRemovendo.add(favorito.id);
    });

    try {
      await _favoritoService.remover(favorito.id);

      if (!mounted) return;

      setState(() {
        _favoritos.removeWhere((item) => item.id == favorito.id);
        _favoritosRemovendo.remove(favorito.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Animal removido dos favoritos.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _favoritosRemovendo.remove(favorito.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível remover o favorito: '
            '${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Abre a tela de solicitação de adoção.
  Future<void> _adotarAnimal(Animal animal) async {
    await context.pushNamed(AppRoutes.solicitacaoAdocao, extra: animal);
  }

  // Constrói a imagem do animal.
  Widget _construirImagem(Animal animal) {
    final imagem = animal.imagem;

    if (imagem == null || imagem.isEmpty) {
      return _imagemPadrao();
    }

    try {
      if (imagem.startsWith('data:image')) {
        final partes = imagem.split(',');

        if (partes.length < 2) {
          return _imagemPadrao();
        }

        return Image.memory(
          base64Decode(partes[1]),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _imagemPadrao();
          },
        );
      }

      return Image.network(
        imagem,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagemPadrao();
        },
      );
    } catch (e) {
      return _imagemPadrao();
    }
  }

  // Imagem exibida quando o animal não possui foto.
  Widget _imagemPadrao() {
    return Container(
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(Icons.pets, color: AppColors.primary, size: 40),
    );
  }

  // Constrói o cartão de cada animal favoritado.
  Widget _construirCard(FavoritoItem favorito) {
    final animal = favorito.animal;
    final removendo = _favoritosRemovendo.contains(favorito.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: _construirImagem(animal),
              ),

              // Botão para remover dos favoritos.
              Positioned(
                top: 8,
                left: 8,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Remover dos favoritos',
                    onPressed: removendo
                        ? null
                        : () => _removerFavorito(favorito),
                    icon: removendo
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.favorite, color: Colors.red),
                  ),
                ),
              ),

              // Menu de opções do animal.
              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: (opcao) {
                    switch (opcao) {
                      case 'ver_mais':
                        _mostrarDetalhes(animal);
                        break;
                      case 'adotar':
                        _adotarAnimal(animal);
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'ver_mais', child: Text('Ver mais')),
                    PopupMenuItem(value: 'adotar', child: Text('Quero adotar')),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  '${animal.especie} • ${animal.idade}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: AppSpacing.xs),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${animal.cidade} - ${animal.estado}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  animal.descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                const SizedBox(height: AppSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _adotarAnimal(animal),
                    child: const Text('Quero adotar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Exibe os detalhes completos do animal.
  void _mostrarDetalhes(Animal animal) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(animal.nome),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _construirImagem(animal),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Espécie: ${animal.especie}'),
                Text('Idade: ${animal.idade}'),
                Text('Localização: ${animal.cidade} - ${animal.estado}'),
                const SizedBox(height: 8),
                Text(animal.descricao),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // Cabeçalho seguindo o padrão visual do feed.
  Widget _construirHeader() {
    final tema = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pets, color: AppColors.primary, size: 30),

              const SizedBox(width: AppSpacing.sm),

              Text(
                AppStrings.appName,
                style: tema.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const Spacer(),

              // Menu de perfil do usuário.
              PopupMenuButton<String>(
                tooltip: 'Perfil',
                onSelected: (opcao) {
                  if (opcao == 'sair') {
                    _sair();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'sair',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: AppColors.danger),
                        SizedBox(width: 10),
                        Text(
                          'Sair da conta',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ],
                    ),
                  ),
                ],
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.surfaceMuted,
                  child: Text(
                    _inicialUsuario,
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Volta para o feed de animais.
          InkWell(
            onTap: () => context.goNamed(AppRoutes.feed),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_back,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Voltar ao feed',
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _construirHeader(),
          Expanded(child: _construirConteudo()),
        ],
      ),
    );
  }

  // Define o conteúdo apresentado na tela.
  Widget _construirConteudo() {
    if (_carregando) {
      return const AppLoading();
    }

    if (_erro != null) {
      return AppError(mensagem: _erro!, aoTentarNovamente: _carregarFavoritos);
    }

    if (_favoritos.isEmpty) {
      return const AppEmptyState(
        mensagem:
            'Nenhum favorito por enquanto.\n'
            'Quando você favoritar um animal, ele aparecerá aqui.',
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarFavoritos,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 320,
          mainAxisExtent: 390,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: _favoritos.length,
        itemBuilder: (context, index) {
          return _construirCard(_favoritos[index]);
        },
      ),
    );
  }
}
