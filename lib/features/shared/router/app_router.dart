import 'package:_96sooq_admin/features/auth/bloc/auth_bloc.dart';
import 'package:_96sooq_admin/features/auth/bloc/auth_state.dart';
import 'package:_96sooq_admin/features/auth/login/view/login_view.dart';
import 'package:_96sooq_admin/features/root/view/admin_root_desktop_view.dart';
import 'package:_96sooq_admin/features/root/view/admin_root_view_.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter/material.dart';

// Helper class to convert Bloc stream to Listenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/',
    // This is the key: it notifies GoRouter to re-evaluate when the Bloc state changes
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final bool isAuthenticated = authBloc.state is Authenticated;

      // Use state.uri.path for cleaner comparison
      final String currentPath = state.uri.path;
      final bool isLoggingIn = currentPath == '/login';

      if (!isAuthenticated) {
        // If not logged in and not on login page, force go to /login
        return isLoggingIn ? null : '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        // If logged in but still on login page, force go to home /
        return '/';
      }

      // Return null to allow the navigation to proceed as requested
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(
        path: '/',
        builder: (context, state) => const AdminRootView(),
      ),
    ],
  );
}
