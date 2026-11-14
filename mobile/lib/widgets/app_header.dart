import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/theme/app_spacing.dart';

class AppHeader extends StatelessWidget {
  final String? nomeUsuario;
  final VoidCallback? aoClicarAvatar;

  const AppHeader({super.key, this.nomeUsuario, this.aoClicarAvatar});

  String get inicialUsuario {
    if (nomeUsuario == null || nomeUsuario!.trim().isEmpty) {
      return '?';
    }

    return nomeUsuario!.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Icon(Icons.pets, color: tema.colorScheme.primary, size: 30),
          const SizedBox(width: AppSpacing.sm),
          Text(
            AppStrings.appName,
            style: tema.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: tema.colorScheme.primary,
            ),
          ),
          const Spacer(),
          if (nomeUsuario != null)
            GestureDetector(
              onTap: aoClicarAvatar,
              child: CircleAvatar(
                backgroundColor: tema.colorScheme.secondary,
                foregroundColor: tema.colorScheme.onSecondary,
                child: Text(
                  inicialUsuario,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
