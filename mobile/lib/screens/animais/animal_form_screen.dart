import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../models/animal.dart';
import '../../models/usuario.dart';
import '../../services/animal_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class AnimalFormScreen extends StatefulWidget {
  final Animal? animal;

  const AnimalFormScreen({super.key, this.animal});

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _especieController = TextEditingController();
  final _idadeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();

  final AnimalService _animalService = AnimalService();
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  Usuario? _usuario;

  XFile? _imagemSelecionada;
  Uint8List? _imagemPreview;

  bool _carregando = false;
  String? _erro;

  bool get _editando => widget.animal != null;

  String get _inicialUsuario {
    final nome = _usuario?.nome.trim() ?? '';

    if (nome.isEmpty) {
      return '?';
    }

    return nome[0].toUpperCase();
  }

  @override
  void initState() {
    super.initState();

    if (_editando) {
      final animal = widget.animal!;

      _nomeController.text = animal.nome;
      _especieController.text = animal.especie;
      _idadeController.text = animal.idade.toString();
      _descricaoController.text = animal.descricao;
      _cidadeController.text = animal.cidade;
      _estadoController.text = animal.estado;
    }

    _buscarUsuario();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _especieController.dispose();
    _idadeController.dispose();
    _descricaoController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();

    super.dispose();
  }

  Future<void> _buscarUsuario() async {
    try {
      final usuario = await _authService.buscarUsuario();

      if (!mounted) return;

      setState(() {
        _usuario = usuario;
      });
    } catch (e) {
      debugPrint('Não foi possível carregar o perfil: $e');
    }
  }

  // Encerra a sessão do usuário.
  Future<void> _sair() async {
    try {
      await _authService.logout();

      if (!mounted) return;

      context.goNamed(AppRoutes.login);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _selecionarImagem() async {
    try {
      final imagem = await _imagePicker.pickImage(source: ImageSource.gallery);

      if (imagem == null) return;

      final bytes = await imagem.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imagemSelecionada = imagem;
        _imagemPreview = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível selecionar a imagem.')),
      );
    }
  }

  Widget _imagemAlternativa() {
    return Container(
      color: AppColors.surfaceMuted,
      child: const Center(
        child: Icon(Icons.pets, size: 55, color: AppColors.primary),
      ),
    );
  }

  Widget _construirPreview() {
    if (_imagemPreview != null) {
      return Image.memory(
        _imagemPreview!,
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
      );
    }

    final imagemExistente = widget.animal?.imagem;

    if (imagemExistente != null && imagemExistente.isNotEmpty) {
      return Image.network(
        imagemExistente,
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagemAlternativa();
        },
      );
    }

    return _imagemAlternativa();
  }

  Widget _construirCampo({
    required String titulo,
    required TextEditingController controller,
    required String? Function(String?) validator,
    String? dica,
    int maxLinhas = 1,
    TextInputType? tipoTeclado,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: controller,
          label: titulo,
          hint: dica,
          validator: validator,
          maxLines: maxLinhas,
          keyboardType: tipoTeclado,
          mostrarLabel: false,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final nome = _nomeController.text.trim();
      final especie = _especieController.text.trim();
      final idade = int.parse(_idadeController.text.trim());
      final descricao = _descricaoController.text.trim();
      final cidade = _cidadeController.text.trim();
      final estado = _estadoController.text.trim();

      if (_editando) {
        await _animalService.atualizar(
          id: widget.animal!.id,
          nome: nome,
          especie: especie,
          idade: idade,
          descricao: descricao,
          cidade: cidade,
          estado: estado,
          imagem: _imagemSelecionada,
        );
      } else {
        await _animalService.cadastrar(
          nome: nome,
          especie: especie,
          idade: idade,
          descricao: descricao,
          cidade: cidade,
          estado: estado,
          imagem: _imagemSelecionada,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editando
                ? 'Animal atualizado com sucesso!'
                : 'Animal cadastrado com sucesso!',
          ),
        ),
      );

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
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 96,
        titleSpacing: 0,
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
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

              PopupMenuButton<String>(
                tooltip: 'Perfil',
                onSelected: (opcao) {
                  if (opcao == 'sair') {
                    _sair();
                  }
                },
                itemBuilder: (context) => [
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
        ),
      ),

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          context.goNamed(AppRoutes.feed);
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Voltar para os animais'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      _editando ? 'Editar animal' : 'Cadastrar um animal',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    const Text(
                      'Informações do animal',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 190,
                        width: double.infinity,
                        child: _construirPreview(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    OutlinedButton.icon(
                      onPressed: _carregando ? null : _selecionarImagem,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Selecionar imagem'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.all(AppSpacing.md),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    _construirCampo(
                      titulo: 'Nome do animal',
                      controller: _nomeController,
                      dica: 'Ex.: Mel',
                      validator: Validators.required,
                    ),

                    _construirCampo(
                      titulo: 'Espécie',
                      controller: _especieController,
                      dica: 'Ex.: Cachorro ou Gato',
                      validator: Validators.required,
                    ),

                    _construirCampo(
                      titulo: 'Idade (em anos)',
                      controller: _idadeController,
                      dica: 'Ex.: 2',
                      tipoTeclado: TextInputType.number,
                      validator: (value) {
                        final erro = Validators.required(value);

                        if (erro != null) return erro;

                        final idade = int.tryParse(value!.trim());

                        if (idade == null || idade < 0) {
                          return 'Informe uma idade válida.';
                        }

                        return null;
                      },
                    ),

                    _construirCampo(
                      titulo: 'Descrição',
                      controller: _descricaoController,
                      dica: 'Conte um pouco sobre o animal...',
                      maxLinhas: 4,
                      validator: Validators.required,
                    ),

                    _construirCampo(
                      titulo: 'Cidade',
                      controller: _cidadeController,
                      dica: 'Ex.: Guarapuava',
                      validator: Validators.required,
                    ),

                    _construirCampo(
                      titulo: 'Estado',
                      controller: _estadoController,
                      dica: 'Ex.: PR',
                      validator: Validators.required,
                    ),

                    if (_erro != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _erro!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    const SizedBox(height: AppSpacing.md),

                    AppButton(
                      texto: _editando
                          ? 'Salvar alterações'
                          : 'Cadastrar animal',
                      carregando: _carregando,
                      aoClicar: _salvar,
                    ),

                    const SizedBox(height: AppSpacing.md),
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
