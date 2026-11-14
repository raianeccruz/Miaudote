import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';

class AppLoading extends StatelessWidget {
  final String? mensagem;

  const AppLoading({super.key, this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(mensagem ?? AppStrings.loading),
        ],
      ),
    );
  }
}
