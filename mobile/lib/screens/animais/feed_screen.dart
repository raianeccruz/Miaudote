import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/animal.dart';
import '../../models/usuario.dart';
import '../../services/animal_service.dart';
import '../../services/auth_service.dart';
import '../../services/favorito_service.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error.dart';
import '../../widgets/app_loading.dart';
import 'feed_header.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final AnimalService _animalService = AnimalService();
  final AuthService _authService = AuthService();
  final FavoritoService _favoritoService = FavoritoService();

  List<Animal> _animais = [];
  Usuario? _usuario;

  bool _carregando = true;
  bool _excluindo = false;

  String? _erro;

  String _filtroSelecionado = 'Todos';

  final Set<int> _animaisFavoritos = {};
  final Map<int, int> _idsFavoritos = {};
  final Set<int> _favoritosEmAlteracao = {};

  @override
  void initState() {
    super.initState();
    _carregarAnimais();
  }

  // Carrega os animais, o usuário e seus favoritos.
  Future<void> _carregarAnimais() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final usuario = await _authService.buscarUsuario();
      final animais = await _animalService.listar();

      Set<int> animaisFavoritos = {};
      Map<int, int> idsFavoritos = {};

      try {
        final favoritos = await _favoritoService.listar();

        for (final favorito in favoritos) {
          animaisFavoritos.add(favorito.animal.id);
          idsFavoritos[favorito.animal.id] = favorito.id;
        }
      } catch (e) {
        debugPrint('Erro ao carregar favoritos: $e');
      }

      if (!mounted) return;

      setState(() {
        _usuario = usuario;
        _animais = animais;

        _animaisFavoritos
          ..clear()
          ..addAll(animaisFavoritos);

        _idsFavoritos
          ..clear()
          ..addAll(idsFavoritos);

        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  // Verifica se o animal pertence ao usuário autenticado.
  bool _usuarioEhResponsavel(Animal animal) {
    return _usuario != null && animal.userId == _usuario!.id;
  }

  // Adiciona ou remove um animal dos favoritos.
  Future<void> _alternarFavorito(Animal animal) async {
    if (_favoritosEmAlteracao.contains(animal.id)) return;

    setState(() {
      _favoritosEmAlteracao.add(animal.id);
    });

    try {
      if (_animaisFavoritos.contains(animal.id)) {
        final favoritoId = _idsFavoritos[animal.id];

        if (favoritoId == null) {
          throw Exception('Não foi possível identificar o favorito.');
        }

        await _favoritoService.remover(favoritoId);

        if (!mounted) return;

        setState(() {
          _animaisFavoritos.remove(animal.id);
          _idsFavoritos.remove(animal.id);
        });
      } else {
        await _favoritoService.adicionar(animal.id);

        final favoritos = await _favoritoService.listar();

        final encontrados = favoritos.where(
          (favorito) => favorito.animal.id == animal.id,
        );

        if (encontrados.isEmpty) {
          throw Exception('Não foi possível atualizar os favoritos.');
        }

        if (!mounted) return;

        setState(() {
          _animaisFavoritos.add(animal.id);
          _idsFavoritos[animal.id] = encontrados.first.id;
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _animaisFavoritos.contains(animal.id)
                ? 'Animal adicionado aos favoritos!'
                : 'Animal removido dos favoritos.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível atualizar o favorito: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _favoritosEmAlteracao.remove(animal.id);
        });
      }
    }
  }

  // Abre o formulário de edição.
  Future<void> _editarAnimal(Animal animal) async {
    await context.pushNamed(AppRoutes.animalForm, extra: animal);

    if (mounted) {
      _carregarAnimais();
    }
  }

  // Abre a tela de solicitação de adoção.
  Future<void> _adotarAnimal(Animal animal) async {
    await context.pushNamed(AppRoutes.solicitacaoAdocao, extra: animal);
  }

  // Exclui um animal após confirmação.
  Future<void> _excluirAnimal(Animal animal) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir animal'),
          content: Text('Tem certeza de que deseja excluir ${animal.nome}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      _excluindo = true;
    });

    try {
      await _animalService.excluir(animal.id);

      if (!mounted) return;

      setState(() {
        _animais.removeWhere((item) => item.id == animal.id);
        _animaisFavoritos.remove(animal.id);
        _idsFavoritos.remove(animal.id);
        _excluindo = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal excluído com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _excluindo = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível excluir o animal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Aplica o filtro selecionado no cabeçalho.
  List<Animal> get _animaisFiltrados {
    if (_filtroSelecionado == AppStrings.all) {
      return _animais;
    }

    return _animais.where((animal) {
      final especie = animal.especie.toLowerCase();

      if (_filtroSelecionado == AppStrings.dogs) {
        return especie == 'cachorro';
      }

      if (_filtroSelecionado == AppStrings.cats) {
        return especie == 'gato';
      }

      if (_filtroSelecionado == AppStrings.others) {
        return especie != 'cachorro' && especie != 'gato';
      }

      return true;
    }).toList();
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
      child: const Center(
        child: Icon(Icons.pets, size: 48, color: AppColors.primary),
      ),
    );
  }

  // Constrói o cartão de cada animal.
  Widget _construirCard(Animal animal) {
    final ehResponsavel = _usuarioEhResponsavel(animal);
    final ehFavorito = _animaisFavoritos.contains(animal.id);
    final alterandoFavorito = _favoritosEmAlteracao.contains(animal.id);

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

              // Botão de favorito: aparece somente para animais de outros usuários.
              if (!ehResponsavel)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: ehFavorito
                          ? 'Remover dos favoritos'
                          : 'Adicionar aos favoritos',
                      onPressed: alterandoFavorito
                          ? null
                          : () => _alternarFavorito(animal),
                      icon: alterandoFavorito
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              ehFavorito
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: ehFavorito
                                  ? Colors.red
                                  : AppColors.primary,
                            ),
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
                      case 'editar':
                        _editarAnimal(animal);
                        break;
                      case 'excluir':
                        _excluirAnimal(animal);
                        break;
                      case 'adotar':
                        _adotarAnimal(animal);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'ver_mais',
                      child: Text('Ver mais'),
                    ),
                    if (ehResponsavel) ...[
                      const PopupMenuItem(
                        value: 'editar',
                        child: Text('Editar'),
                      ),
                      const PopupMenuItem(
                        value: 'excluir',
                        child: Text('Excluir'),
                      ),
                    ],
                    if (!ehResponsavel)
                      const PopupMenuItem(
                        value: 'adotar',
                        child: Text('Quero adotar'),
                      ),
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

                if (!ehResponsavel) ...[
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _adotarAnimal(animal),
                      child: const Text('Quero adotar'),
                    ),
                  ),
                ],
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

  @override
  Widget build(BuildContext context) {
    final animaisExibidos = _animaisFiltrados;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            FeedHeader(
              nomeUsuario: _usuario?.nome ?? '',
              quantidadeAnimais: _animais.length,
              filtroSelecionado: _filtroSelecionado,
              aoSelecionarFiltro: (filtro) {
                setState(() {
                  _filtroSelecionado = filtro;
                });
              },
              aoSair: () async {
                await _authService.logout();

                if (context.mounted) {
                  context.goNamed(AppRoutes.login);
                }
              },
              aoAbrirFavoritos: () {
                context.pushNamed(AppRoutes.favoritos);
              },
              aoAbrirMinhasSolicitacoes: () {
                context.pushNamed(AppRoutes.minhasSolicitacoes);
              },
            ),

            Expanded(child: _construirConteudo(animaisExibidos)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.pushNamed(AppRoutes.animalForm);

          if (mounted) {
            _carregarAnimais();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Define o conteúdo apresentado no feed.
  Widget _construirConteudo(List<Animal> animaisExibidos) {
    if (_carregando || _excluindo) {
      return const AppLoading();
    }

    if (_erro != null) {
      return AppError(mensagem: _erro!, aoTentarNovamente: _carregarAnimais);
    }

    if (animaisExibidos.isEmpty) {
      return AppEmptyState(
        mensagem: _filtroSelecionado == 'Todos'
            ? 'Nenhum animal cadastrado ainda.'
            : 'Nenhum animal encontrado nessa categoria.',
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarAnimais,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 320,
          mainAxisExtent: 390,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: animaisExibidos.length,
        itemBuilder: (context, index) {
          return _construirCard(animaisExibidos[index]);
        },
      ),
    );
  }
}
