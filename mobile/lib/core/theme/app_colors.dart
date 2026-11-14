import 'package:flutter/material.dart';

/// Paleta de cores do Miaudote.
///
/// As telas devem utilizar estas constantes em vez de
/// declarar cores diretamente nos componentes.
abstract final class AppColors {
  // Marca
  static const Color primary = Color(0xFFDE704D);
  static const Color primaryDark = Color(0xFFB9573B);
  static const Color primaryLight = Color(0xFFF6D9CE);

  // Superfícies
  static const Color background = Color(0xFFFAF2E7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFE4EFE7);
  static const Color border = Color(0xFFE5DED4);

  // Texto
  static const Color textPrimary = Color(0xFF344A42);
  static const Color textSecondary = Color(0xFF777777);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF477A59);
  static const Color successSoft = Color(0xFFE4EFE7);

  static const Color warning = Color(0xFFB7791F);
  static const Color warningSoft = Color(0xFFFAEED5);

  static const Color danger = Color(0xFFB3261E);
  static const Color dangerSoft = Color(0xFFFBE3E1);

  static const Color neutralSoft = Color(0xFFF0EDE8);
}
