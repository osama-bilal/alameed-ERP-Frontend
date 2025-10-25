import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ponit_of_sales/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// auth_bloc.dart

// تحتاج هنا لاستخدام حزمة مثل flutter_secure_storage
// يمكنك أيضاً استخدام طبقة الـ Repository هنا لفصل المنطق

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FlutterSecureStorage _secureStorage;
  // أضف أي خدمات أخرى مثل UserService

  AuthBloc()
    : _secureStorage = const FlutterSecureStorage(),
      super(AuthInitial()) {
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
      // 1. محاولة قراءة التوكن من التخزين الآمن
      final token = await _secureStorage.read(key: 'access');
      final user = await AuthService().getStoredUser();
      if (token != null && user != null) {
        // 2. إذا وُجِد توكن، افترض أنه صالح وأصدر حالة المصادقة
        // *في تطبيق حقيقي: يجب التحقق من صلاحية التوكن على الخادم*
        emit(AuthAuthenticated(userToken: token, permissions: user.permissions, isAdmin: user.isAdmin));
      } else {
        // 3. لم يُعثر على توكن، المستخدم غير مُصادَق
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // 4. حدث خطأ (عادةً ناتج عن فشل القراءة)، نعتبر المستخدم غير مُصادَق
      emit(AuthUnauthenticated());
    }
  }

  // 2. معالجة حدث تسجيل الدخول (LoggedIn)
  void _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final token = await AuthService().getAccessToken();
    final user = await AuthService().getStoredUser();

    if (token == null || user == null) {
      emit(AuthUnauthenticated());
      return;
    }
    // 1. حفظ التوكن في التخزين الآمن
    // await _secureStorage.write(key: 'access', value: token);
    // 2. إصدار حالة المصادقة
    emit(AuthAuthenticated(userToken: token, permissions: user.permissions, isAdmin: user.isAdmin,));
  }

  // 3. معالجة حدث تسجيل الخروج (LoggedOut)
  void _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // 1. حذف التوكن من التخزين الآمن
    await _secureStorage.delete(key: 'access');
    // 2. إصدار حالة غير مُصادَق
    emit(AuthUnauthenticated());
  }
}
