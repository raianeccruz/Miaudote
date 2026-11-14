import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/animal.dart';
import '../../services/solicitacao_adocao_service.dart';
import '../../widgets/app_button.dart';

class SolicitacaoAdocaoScreen extends StatefulWidget {
  final Animal animal;

  const SolicitacaoAdocaoScreen({super.key, required this.animal});

  @override
  State<SolicitacaoAdocaoScreen> createState() =>
      _SolicitacaoAdocaoScreenState();
}

class _SolicitacaoAdocaoScreenState extends State<SolicitacaoAdocaoScreen> {
  final SolicitacaoAdocaoService _service = SolicitacaoAdocaoService();

  bool _carregando = false;

  // Envia a solicitação de adoção para a API.
  Future<void> _solicitarAdocao() async {
    // Impede o envio de solicitações repetidas.
    if (_carregando) return;

    setState(() {
      _carregando = true;
    });

    try {
      await _service.solicitarAdocao(widget.animal.id);

      if (!mounted) return;

      // Exibe a confirmação após a resposta positiva da API.
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle_outline,
              color: AppColors.primary,
              size: 48,
            ),
            title: const Text('Solicitação enviada!'),
            content: Text(
              'Sua solicitação para adotar ${widget.animal.nome} '
              'foi enviada com sucesso.\n\n'
              'Agora ela ficará pendente até a análise '
              'do responsável pelo animal.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar ao feed'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      context.goNamed(AppRoutes.feed);
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final animal = widget.animal;

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar adoção')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.pets, size: 64, color: AppColors.primary),

            const SizedBox(height: AppSpacing.lg),

            Text(
              'Você deseja solicitar a adoção de ${animal.nome}?',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.md),

            Text('Espécie: ${animal.especie}', textAlign: TextAlign.center),

            Text(
              'Localização: ${animal.cidade} - ${animal.estado}',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.lg),

            const Text(
              'Ao confirmar, sua solicitação será enviada '
              'ao responsável pelo animal para análise.',
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            AppButton(
              texto: 'Confirmar solicitação',
              aoClicar: _solicitarAdocao,
              carregando: _carregando,
            ),

            const SizedBox(height: AppSpacing.sm),

            TextButton(
              onPressed: _carregando
                  ? null
                  : () => context.goNamed(AppRoutes.feed),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
