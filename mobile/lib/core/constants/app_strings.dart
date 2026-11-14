abstract final class AppStrings {
  // Aplicativo
  static const String appName = 'Miaudote';

  // Autenticação
  static const String login = 'Entrar';
  static const String register = 'Criar conta';
  static const String email = 'E-mail';
  static const String password = 'Senha';
  static const String name = 'Nome completo';
  static const String confirmPassword = 'Confirmar senha';
  static const String loginTitle = 'Bem-vindo ao Miaudote!';
  static const String loginSubtitle = 'Entre na sua conta para continuar.';
  static const String registerTitle = 'Crie sua conta';
  static const String registerSubtitle = 'Preencha os dados para começar.';

  // Animais
  static const String animals = 'Animais disponíveis';
  static const String registerAnimal = 'Cadastrar animal';
  static const String editAnimal = 'Editar animal';
  static const String animalName = 'Nome do animal';
  static const String animalNameHint = 'Ex.: Mel';
  static const String species = 'Espécie';
  static const String speciesHint = 'Ex.: Cachorro ou Gato';
  static const String age = 'Idade (em anos)';
  static const String ageHint = 'Ex.: 2';
  static const String description = 'Descrição';
  static const String descriptionHint = 'Conte um pouco sobre o animal...';
  static const String city = 'Cidade';
  static const String cityHint = 'Ex.: Guarapuava';
  static const String state = 'Estado';
  static const String stateHint = 'Ex.: PR';
  static const String animalInformation = 'Informações do animal';
  static const String selectImage = 'Selecionar imagem';
  static const String backToAnimals = 'Voltar para os animais';
  static const String saveChanges = 'Salvar alterações';

  // Botões e ações
  static const String cancel = 'Cancelar';
  static const String delete = 'Excluir';
  static const String edit = 'Editar';
  static const String save = 'Salvar';
  static const String confirm = 'Confirmar';
  static const String logout = 'Sair';
  static const String adopt = 'Quero adotar';
  static const String tryAgain = 'Tentar novamente';

  // Filtros
  static const String all = 'Todos';
  static const String dogs = 'Cães';
  static const String cats = 'Gatos';
  static const String others = 'Outros';

  // Textos do feed
  static const String greeting = 'Olá!';
  static const String findNewFriend = 'Encontre um novo amigo';
  static const String friendToAdoptSingular = 'amigo para adotar';
  static const String friendToAdoptPlural = 'amigos para adotar';

  // Validações
  static const String requiredField = 'Este campo é obrigatório.';
  static const String invalidEmail = 'Informe um e-mail válido.';
  static const String invalidPassword =
      'A senha deve ter pelo menos 6 caracteres.';
  static const String invalidAge = 'Informe uma idade válida.';
  static const String passwordMismatch = 'As senhas não coincidem.';

  // Mensagens
  static const String loginSuccess = 'Login realizado com sucesso!';
  static const String registerSuccess = 'Conta criada com sucesso!';
  static const String animalRegisterSuccess = 'Animal cadastrado com sucesso!';
  static const String animalUpdateSuccess = 'Animal atualizado com sucesso!';
  static const String animalDeleteSuccess = 'Animal excluído com sucesso!';
  static const String adoptionRequestSuccess =
      'Solicitação enviada com sucesso!';
  static const String genericError = 'Ocorreu um erro. Tente novamente.';
  static const String imageSelectionError =
      'Não foi possível selecionar a imagem.';

  // Carregamento
  static const String loading = 'Carregando...';

  // Estados vazios
  static const String emptyAnimals = 'Nenhum animal disponível no momento.';
  static const String emptySearch =
      'Nenhum animal encontrado para esse filtro.';
}
