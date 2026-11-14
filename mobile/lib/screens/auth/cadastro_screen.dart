import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmacaoSenhaController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _mostrarSenha = false;
  bool _mostrarConfirmacaoSenha = false;
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmacaoSenhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await _authService.cadastrar(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
        confirmacaoSenha: _confirmacaoSenhaController.text,
      );

      if (!mounted) return;

      context.goNamed(AppRoutes.feed);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
      });
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),

                    // Identidade visual
                    const Icon(Icons.pets, size: 60, color: AppColors.primary),

                    const SizedBox(height: AppSpacing.md),

                    const Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    const Text(
                      'Crie sua conta e faça parte dessa história!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Título do formulário
                    const Text(
                      'Criar uma conta',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    const Text(
                      'Preencha seus dados para continuar.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Nome completo
                    AppTextField(
                      controller: _nomeController,
                      label: AppStrings.name,
                      textInputAction: TextInputAction.next,
                      validator: Validators.required,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // E-mail
                    AppTextField(
                      controller: _emailController,
                      label: AppStrings.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Senha
                    AppTextField(
                      controller: _senhaController,
                      label: AppStrings.password,
                      obscureText: !_mostrarSenha,
                      textInputAction: TextInputAction.next,
                      validator: Validators.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _mostrarSenha = !_mostrarSenha;
                          });
                        },
                        icon: Icon(
                          _mostrarSenha
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Confirmação da senha
                    AppTextField(
                      controller: _confirmacaoSenhaController,
                      label: 'Confirmar senha',
                      obscureText: !_mostrarConfirmacaoSenha,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        final erro = Validators.password(value);

                        if (erro != null) {
                          return erro;
                        }

                        if (value != _senhaController.text) {
                          return 'As senhas não coincidem.';
                        }

                        return null;
                      },
                      onFieldSubmitted: (_) => _cadastrar(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _mostrarConfirmacaoSenha =
                                !_mostrarConfirmacaoSenha;
                          });
                        },
                        icon: Icon(
                          _mostrarConfirmacaoSenha
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Mensagem de erro
                    if (_erro != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.dangerSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _erro!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Botão cadastrar
                    AppButton(
                      texto: AppStrings.register,
                      carregando: _carregando,
                      aoClicar: _cadastrar,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Voltar para o login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            'Já possui uma conta?',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.goNamed(AppRoutes.login);
                          },
                          child: const Text(
                            AppStrings.login,
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
