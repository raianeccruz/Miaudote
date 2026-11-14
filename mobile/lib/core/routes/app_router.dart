import 'package:go_router/go_router.dart';

import '../../screens/auth/login_screen.dart';
import '../../screens/auth/cadastro_screen.dart';

import '../../screens/animais/feed_screen.dart';
import '../../screens/animais/animal_form_screen.dart';
import '../../screens/animais/solicitacao_adocao_screen.dart';
import '../../screens/animais/favoritos_screen.dart';
import '../../screens/animais/minhas_solicitacoes_screen.dart';

import '../../models/animal.dart';

import 'app_routes.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/cadastro',
        name: AppRoutes.cadastro,
        builder: (context, state) => const CadastroScreen(),
      ),

      GoRoute(
        path: '/animais',
        name: AppRoutes.feed,
        builder: (context, state) => const FeedScreen(),
      ),

      GoRoute(
        path: '/animais/novo',
        name: AppRoutes.animalForm,
        builder: (context, state) =>
            AnimalFormScreen(animal: state.extra as Animal?),
      ),

      GoRoute(
        path: '/solicitacoes-adocao/nova',
        name: AppRoutes.solicitacaoAdocao,
        builder: (context, state) =>
            SolicitacaoAdocaoScreen(animal: state.extra as Animal),
      ),

      GoRoute(
        path: '/favoritos',
        name: AppRoutes.favoritos,
        builder: (context, state) => const FavoritosScreen(),
      ),

      GoRoute(
        path: '/minhas-solicitacoes',
        name: AppRoutes.minhasSolicitacoes,
        builder: (context, state) => const MinhasSolicitacoesScreen(),
      ),
    ],
  );
}
