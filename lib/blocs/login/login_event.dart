
part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginStarted extends LoginEvent {}  // 👈 new event

class LoginSubmitted extends LoginEvent {
  final String username;
  final String password;

  LoginSubmitted(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}

class LogoutRequested extends LoginEvent {}
