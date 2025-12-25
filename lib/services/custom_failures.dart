// domain/failures/failures.dart;

abstract class Failure implements Exception {}

// ❌ خطأ في الاتصال (لا يوجد إنترنت أو مهلة)
class NetworkFailure extends Failure {
  final String message = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.';
  @override
  String toString() {
    return message;
  }
}

// ❌ خطأ في السيرفر (رمز 5xx)
class ServerFailure extends Failure {
  final int statusCode;
  ServerFailure(this.statusCode);
  @override
  String toString() {
    return "خطأ في السيرفر مع الرمز: $statusCode";
  }
}

// ❌ خطأ في العميل (رمز 4xx - مثل البيانات، التوكن، الخ)
class ClientFailure extends Failure {
  final int statusCode;
  final String message;
  ClientFailure(this.statusCode, this.message);

  @override
  String toString() {
    return "خطأ في العميل: $message. الرمز($statusCode)";
  }
}

class SuccessResponse extends Failure {
  final int statusCode;
  final String message;
  SuccessResponse(this.statusCode, this.message);

  @override
  String toString() {
    return message;
  }
}

// ❌ فشل غير معروف
class UnknownFailure extends Failure {
  @override
  String toString() {
    return "خطأ غير معروف.";
  }
}
