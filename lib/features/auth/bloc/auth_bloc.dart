import 'package:_96sooq_admin/constants/api_endpoints.dart';
import 'package:_96sooq_admin/features/auth/services/auth_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/auth_storage.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:dio/dio.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc()
      : _authService = AuthService(
          Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl)),
        ),
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onAppStarted(
      AppStarted event, Emitter<AuthState> emit) async {
    final isAuth = await AuthStorage.isAuthenticated();
    emit(isAuth ? Authenticated() : Unauthenticated());
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await _authService.login(
        email: event.email,
        password: event.password,
      );

      await AuthStorage.saveToken(token);
      await AuthStorage.setAuthenticated(true);

      emit(Authenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
      LogoutRequested event, Emitter<AuthState> emit) async {
    await AuthStorage.logout();
    emit(Unauthenticated());
  }
}
