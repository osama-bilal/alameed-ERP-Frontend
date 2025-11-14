part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// 1. حدث يبدأ عند تشغيل التطبيق للتحقق من التوكن المخزن
class AppStarted extends AuthEvent {}

// 2. حدث يُرسل بعد تسجيل الدخول بنجاح
class LoggedIn extends AuthEvent {}

// 3. حدث يُرسل عند تسجيل الخروج
class LoggedOut extends AuthEvent {}