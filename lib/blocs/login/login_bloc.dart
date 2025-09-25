// blocs/login/login_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../../services/auth_service.dart';

// blocs/login/login_bloc.dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService authService;

  LoginBloc(this.authService) : super(const LoginState()) {
    on<LoginStarted>(_onLoginStarted); // 👈 handle stored session
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginStarted(
    LoginStarted event,
    Emitter<LoginState> emit,
  ) async {
    final user = await authService.getStoredUser();
    if (user != null) {
      // print(user.username);
      emit(state.copyWith(status: LoginStatus.success, user: user));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      final user = await authService.login(event.username, event.password);
      emit(state.copyWith(status: LoginStatus.success, user: user));
    } catch (e) {
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    await authService.logout();
    emit(const LoginState(status: LoginStatus.initial));
  }
}
