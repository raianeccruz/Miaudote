import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String texto;
  final VoidCallback? aoClicar;
  final bool carregando;

  const AppButton({
    super.key,
    required this.texto,
    required this.aoClicar,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: carregando ? null : aoClicar,
      child: carregando
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : Text(texto),
    );
  }
}
