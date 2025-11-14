import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ponit_of_sales/models/user.dart';
import 'package:ponit_of_sales/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// تحتاج هنا لاستخدام حزمة مثل flutter_secure_storage
// يمكنك أيضاً استخدام طبقة الـ Repository هنا لفصل المنطق

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  AuthBloc() : _authService = AuthService(), super(AuthInitial()) {
    // ربط الأحداث بالدوال المعالجة
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
    // إطلاق أول حدث عند إنشاء الـ Bloc
    add(AppStarted());
  }

  // --- دوال معالجة الأحداث ---
  // 1. معالجة حدث بدء التطبيق (AppStarted)
  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // 1. Check if token is valid
      final isTokenValid = await _authService.verifyToken();
      if (isTokenValid) {
        // 2. Token is valid, get user data and authenticate
        final token = await _authService.getAccessToken();
        final user = await _authService.getStoredUser();
        if (token != null && user != null) {
          emit(
            AuthAuthenticated(
              userToken: token,
              user: user
            ),
          );
        } else {
          // This case is unlikely but good to handle
          emit(AuthUnauthenticated());
        }
      } else {
        // 3. Token is invalid or expired, log out to clear corrupted state
        await _authService.logout();
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // 4. An error occurred (e.g., network issue), treat as unauthenticated
      emit(AuthUnauthenticated());
    }
  }

  // 2. معالجة حدث تسجيل الدخول (LoggedIn)
  void _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final token = await _authService.getAccessToken();
    final user = await _authService.getStoredUser();

    if (token == null || user == null) {
      emit(AuthUnauthenticated());
      return;
    }
    // 1. حفظ التوكن في التخزين الآمن
    // 2. إصدار حالة المصادقة
    emit(
      AuthAuthenticated(
        userToken: token,
        user: user
      ),
    );
  }

  // 3. معالجة حدث تسجيل الخروج (LoggedOut)
  void _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // 1. حذف التوكن من التخزين الآمن
    await _authService.logout();
    // 2. إصدار حالة غير مُصادَق
    emit(AuthUnauthenticated());
  }
}
