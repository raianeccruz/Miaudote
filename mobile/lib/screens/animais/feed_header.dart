import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class FeedHeader extends StatelessWidget {
  final String nomeUsuario;
  final int quantidadeAnimais;
  final String filtroSelecionado;
  final ValueChanged<String> aoSelecionarFiltro;
  final VoidCallback aoSair;
  final VoidCallback aoAbrirFavoritos;
  final VoidCallback aoAbrirMinhasSolicitacoes;

  const FeedHeader({
    super.key,
    required this.nomeUsuario,
    required this.quantidadeAnimais,
    required this.filtroSelecionado,
    required this.aoSelecionarFiltro,
    required this.aoSair,
    required this.aoAbrirFavoritos,
    required this.aoAbrirMinhasSolicitacoes,
  });

  String get _inicialUsuario {
    if (nomeUsuario.trim().isEmpty) {
      return '?';
    }

    return nomeUsuario.trim()[0].toUpperCase();
  }

  String get _textoContador {
    if (quantidadeAnimais == 1) {
      return AppStrings.friendToAdoptSingular;
    }

    return AppStrings.friendToAdoptPlural;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    final filtros = [
      AppStrings.all,
      AppStrings.dogs,
      AppStrings.cats,
      AppStrings.others,
    ];

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
              Icon(Icons.pets, color: AppColors.primary, size: 30),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.appName,
                style: tema.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),

              // Acesso à tela de favoritos.
              IconButton(
                tooltip: 'Meus favoritos',
                onPressed: aoAbrirFavoritos,
                icon: const Icon(
                  Icons.favorite_border,
                  color: AppColors.primary,
                  size: 27,
                ),
              ),

              // Menu do perfil.
              PopupMenuButton<String>(
                tooltip: 'Perfil',
                onSelected: (opcao) {
                  if (opcao == 'solicitacoes') {
                    aoAbrirMinhasSolicitacoes();
                  } else if (opcao == 'sair') {
                    aoSair();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'solicitacoes',
                    child: Row(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 10),
                        Text('Minhas solicitações'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
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

          Text(
            '$quantidadeAnimais $_textoContador',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: filtros.map((filtro) {
              final selecionado = filtroSelecionado == filtro;

              return ChoiceChip(
                label: Text(filtro),
                selected: selecionado,
                onSelected: (_) => aoSelecionarFiltro(filtro),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: selecionado
                      ? AppColors.textOnPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                side: BorderSide(
                  color: selecionado ? AppColors.primary : AppColors.border,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
