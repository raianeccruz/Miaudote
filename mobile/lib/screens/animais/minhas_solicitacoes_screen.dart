import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/solicitacao_adocao.dart';
import '../../models/usuario.dart';
import '../../services/auth_service.dart';
import '../../services/solicitacao_adocao_service.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error.dart';
import '../../widgets/app_loading.dart';

class MinhasSolicitacoesScreen extends StatefulWidget {
  const MinhasSolicitacoesScreen({super.key});

  @override
  State<MinhasSolicitacoesScreen> createState() =>
      _MinhasSolicitacoesScreenState();
}

class _MinhasSolicitacoesScreenState extends State<MinhasSolicitacoesScreen> {
  final SolicitacaoAdocaoService _service = SolicitacaoAdocaoService();

  final AuthService _authService = AuthService();

  Usuario? _usuario;

  List<SolicitacaoAdocao> _solicitacoes = [];

  bool _carregando = true;
  String? _erro;

  // Guarda o ID da solicitação que está sendo cancelada.
  final Set<int> _cancelando = {};

  @override
  void initState() {
    super.initState();
    _carregarSolicitacoes();
  }

  // Busca o usuário e as solicitações relacionadas a ele.
  Future<void> _carregarSolicitacoes() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final usuario = await _authService.buscarUsuario();

      final todasSolicitacoes = await _service.listar();

      if (!mounted) return;

      // Mantém somente as solicitações enviadas pelo usuário.
      final minhasSolicitacoes = todasSolicitacoes
          .where((solicitacao) => solicitacao.usuario.id == usuario.id)
          .toList();

      setState(() {
        _usuario = usuario;
        _solicitacoes = minhasSolicitacoes;
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

  // Confirma e realiza o cancelamento da solicitação.
  Future<void> _cancelarSolicitacao(SolicitacaoAdocao solicitacao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar solicitação'),
          content: Text(
            'Deseja realmente cancelar sua solicitação '
            'para adotar ${solicitacao.animal.nome}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Voltar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Cancelar solicitação',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      _cancelando.add(solicitacao.id);
    });

    try {
      await _service.cancelar(solicitacao.id);

      if (!mounted) return;

      setState(() {
        _solicitacoes = _solicitacoes.map((item) {
          if (item.id == solicitacao.id) {
            return SolicitacaoAdocao(
              id: item.id,
              status: 'cancelada',
              animal: item.animal,
              usuario: item.usuario,
              createdAt: item.createdAt,
            );
          }

          return item;
        }).toList();

        _cancelando.remove(solicitacao.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação cancelada com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cancelando.remove(solicitacao.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
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

  // Formata a data da solicitação.
  String _formatarData(DateTime? data) {
    if (data == null) {
      return 'Data não informada';
    }

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();

    return '$dia/$mes/$ano';
  }

  // Retorna o texto correspondente ao status.
  String _textoStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return 'Aguardando análise';

      case 'aceita':
        return 'Solicitação aceita';

      case 'recusada':
        return 'Solicitação recusada';

      case 'cancelada':
        return 'Solicitação cancelada';

      default:
        return 'Status: $status';
    }
  }

  // Retorna a cor correspondente ao status.
  Color _corStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.orange;

      case 'aceita':
        return Colors.green;

      case 'recusada':
        return AppColors.danger;

      case 'cancelada':
        return Colors.grey;

      default:
        return AppColors.textSecondary;
    }
  }

  // Constrói o cabeçalho da tela.
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
              CircleAvatar(
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
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          InkWell(
            onTap: () => Navigator.pop(context),
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
                    'Voltar',
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

  // Constrói a imagem do animal.
  Widget _construirImagem(String? imagem) {
    if (imagem == null || imagem.isEmpty) {
      return _imagemPadrao();
    }

    return Image.network(
      imagem,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _imagemPadrao();
      },
    );
  }

  // Imagem padrão quando não existe foto.
  Widget _imagemPadrao() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Icon(Icons.pets, color: AppColors.primary, size: 36),
      ),
    );
  }

  // Constrói o cartão de uma solicitação.
  Widget _construirCard(SolicitacaoAdocao solicitacao) {
    final animal = solicitacao.animal;
    final corStatus = _corStatus(solicitacao.status);
    final estaPendente = solicitacao.status.toLowerCase() == 'pendente';
    final estaCancelando = _cancelando.contains(solicitacao.id);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 1,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 100,
                height: 115,
                child: _construirImagem(animal.imagem),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    animal.especie,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _formatarData(solicitacao.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: corStatus.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _textoStatus(solicitacao.status),
                      style: TextStyle(
                        color: corStatus,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // O botão aparece somente para solicitações pendentes.
                  if (estaPendente) ...[
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: estaCancelando
                            ? null
                            : () => _cancelarSolicitacao(solicitacao),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: estaCancelando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Cancelar solicitação'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Constrói o conteúdo principal.
  Widget _construirConteudo() {
    if (_carregando) {
      return const AppLoading();
    }

    if (_erro != null) {
      return AppError(
        mensagem: _erro!,
        aoTentarNovamente: _carregarSolicitacoes,
      );
    }

    if (_solicitacoes.isEmpty) {
      return const AppEmptyState(
        mensagem:
            'Você ainda não enviou nenhuma solicitação de adoção.\n'
            'Quando solicitar a adoção de um animal, ela aparecerá aqui.',
        icone: Icons.pets_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarSolicitacoes,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _solicitacoes.length,
        itemBuilder: (context, index) {
          return _construirCard(_solicitacoes[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _construirHeader(),
            Expanded(child: _construirConteudo()),
          ],
        ),
      ),
    );
  }
}
