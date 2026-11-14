import '../constants/app_strings.dart';

abstract final class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.invalidEmail;
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }

    if (value.length < 6) {
      return AppStrings.invalidPassword;
    }

    return null;
  }

  static String? confirmPassword(String? value, String senha) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }

    if (value != senha) {
      return AppStrings.passwordMismatch;
    }

    return null;
  }

  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }

    final idade = int.tryParse(value.trim());

    if (idade == null || idade < 0) {
      return AppStrings.invalidAge;
    }

    return null;
  }
}
