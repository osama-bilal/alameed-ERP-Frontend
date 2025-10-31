part of 'auth_bloc.dart';
// auth_state.dart

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// 1. حالة أولية: يتم عرض شاشة التحميل (Splash Screen)
class AuthInitial extends AuthState {}

// 2. حالة جاري تحميل البيانات أو التحقق من التوكن
class AuthLoading extends AuthState {}

// 3. حالة المستخدم غير مُصادَق (غير مسجل دخول)
class AuthUnauthenticated extends AuthState {}

// 4. حالة المستخدم مُصادَق (مسجل دخول)

class AuthAuthenticated extends AuthState {
  final String userToken;
  // 🌟 قائمة الصلاحيات المطلوبة
  final User user;
  const AuthAuthenticated({
    required this.userToken,
    required this.user,
  });

  @override
  List<Object> get props => [userToken, user];
}
