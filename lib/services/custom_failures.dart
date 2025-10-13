// domain/failures/failures.dart

abstract class Failure {}

// ❌ خطأ في الاتصال (لا يوجد إنترنت أو مهلة)
class NetworkFailure extends Failure {
  final String message = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.';
}

// ❌ خطأ في السيرفر (رمز 5xx)
class ServerFailure extends Failure {
  final int statusCode;
  ServerFailure(this.statusCode);
}

// ❌ خطأ في العميل (رمز 4xx - مثل البيانات، التوكن، الخ)
class ClientFailure extends Failure {
  final int statusCode;
  final String message;
  ClientFailure(this.statusCode, this.message);
}

// ❌ فشل غير معروف
class UnknownFailure extends Failure {}