import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';

class AppEmptyState extends StatelessWidget {
  final String mensagem;
  final IconData icone;
  final String? textoBotao;
  final VoidCallback? aoClicar;

  const AppEmptyState({
    super.key,
    required this.mensagem,
    this.icone = Icons.pets_outlined,
    this.textoBotao,
    this.aoClicar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (aoClicar != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: aoClicar,
                child: Text(textoBotao ?? AppStrings.tryAgain),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
