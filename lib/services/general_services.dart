import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ponit_of_sales/services/custom_failures.dart';
import 'package:ponit_of_sales/utils/clean_null.dart';
import 'api_client.dart';

class GeneralService<T> {
  final ApiClient _api = ApiClient();
  String endpoint;
  final T Function(Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;
  GeneralService({
    required this.endpoint,
    required this.fromMap,
    required this.toMap,
  });

  Future<List<T>> fetchList({Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _api.dio.get(
        endpoint,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => fromMap(json)).toList();
      }
      throw DioException(requestOptions: response.requestOptions,response: response);
    } on DioException catch (e) {
      // ============ مفتاح التفرقة هنا ============

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.badCertificate ||
          e.type == DioExceptionType.connectionError) {
        // ❌ الحالة الأولى: خطأ شبكة/اتصال
        log('❌ Dio: خطأ في الاتصال. محاولة القراءة من الكاش.');

        // try {
        // التحول التلقائي: القراءة من قاعدة البيانات المحلية
        // final localData = await _localDataSource.get(cacheKey);
        // return localData; // إرجاع البيانات المحلية بنجاح
        // } catch (_) {
        // إذا فشلت القراءة من الكاش (لا توجد بيانات محلياً)
        throw NetworkFailure();
        // }
      } else {
        // ❌ الحالة الثانية: استجابة سيئة (4xx أو 5xx) - السيرفر متاح ولكنه أرجع خطأ
        final statusCode = e.response?.statusCode;

        if (statusCode! >= 500) {
          throw ServerFailure(statusCode); // خطأ سيرفر
        } else if (statusCode >= 400) {
          // يمكنك تحليل الـ body للرسالة المخصصة
          throw ClientFailure(
            statusCode,
            e.response?.statusMessage ??
                e.response?.data['error'] ??
                'خطأ في بيانات العميل',
          );
        }
      }

      // ❌ أخطاء Dio أخرى (مثل إلغاء الطلب)
      throw UnknownFailure();
    } catch (_) {
      throw UnknownFailure();
    }
  }

  Future<T> fetchItem(int? id) async {
    final point = id == null ? endpoint : "$endpoint$id/";
    try {
      final response = await _api.dio.get(point);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return fromMap(data);
      }
      throw DioException(requestOptions: response.requestOptions,response: response);
    } on DioException catch (e) {
      // ============ مفتاح التفرقة هنا ============

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.badCertificate ||
          e.type == DioExceptionType.connectionError) {
        // ❌ الحالة الأولى: خطأ شبكة/اتصال
        log('❌ Dio: خطأ في الاتصال. محاولة القراءة من الكاش.');

        // try {
        // التحول التلقائي: القراءة من قاعدة البيانات المحلية
        // final localData = await _localDataSource.get(cacheKey);
        // return localData; // إرجاع البيانات المحلية بنجاح
        // } catch (_) {
        // إذا فشلت القراءة من الكاش (لا توجد بيانات محلياً)
        throw NetworkFailure();
        // }
      } else {
        // ❌ الحالة الثانية: استجابة سيئة (4xx أو 5xx) - السيرفر متاح ولكنه أرجع خطأ
        final statusCode = e.response?.statusCode;

        if (statusCode! >= 500) {
          throw ServerFailure(statusCode); // خطأ سيرفر
        } else if (statusCode >= 400) {
          // يمكنك تحليل الـ body للرسالة المخصصة
          throw ClientFailure(
            statusCode,
            e.response?.statusMessage ??
                e.response?.data['error'] ??
                'خطأ في بيانات العميل',
          );
        }
      }

      // ❌ أخطاء Dio أخرى (مثل إلغاء الطلب)
      throw UnknownFailure();
    } catch (_) {
      throw UnknownFailure();
    }
  }

  Future<T> create(T item) async {
    try {
      final response = await _api.dio.post(
        endpoint,
        data: cleanNullData(toMap(item)),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return fromMap(response.data);
      }
      throw DioException(requestOptions: response.requestOptions,response: response);
    } on DioException catch (e) {
      // ============ مفتاح التفرقة هنا ============

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.badCertificate ||
          e.type == DioExceptionType.connectionError) {
        // ❌ الحالة الأولى: خطأ شبكة/اتصال
        log('❌ Dio: خطأ في الاتصال. محاولة القراءة من الكاش.');

        // try {
        //   // التحول التلقائي: القراءة من قاعدة البيانات المحلية
        //   // final localData = await _localDataSource.get(cacheKey);
        //   // return localData; // إرجاع البيانات المحلية بنجاح
        // } catch (_) {
        //   // إذا فشلت القراءة من الكاش (لا توجد بيانات محلياً)
        //
        // }
        throw NetworkFailure();
      } else {
        // ❌ الحالة الثانية: استجابة سيئة (4xx أو 5xx) - السيرفر متاح ولكنه أرجع خطأ
        final statusCode = e.response?.statusCode;

        if (statusCode! >= 500) {
          throw ServerFailure(statusCode); // خطأ سيرفر
        } else if (statusCode >= 400) {
          // يمكنك تحليل الـ body للرسالة المخصصة
          throw ClientFailure(
            statusCode,
            e.response?.statusMessage ??
                e.response?.data['error'] ??
                'خطأ في بيانات العميل',
          );
        }
      }

      // ❌ أخطاء Dio أخرى (مثل إلغاء الطلب)
      throw UnknownFailure();
    } catch (_) {
      throw UnknownFailure();
    }
  }

  Future<T> update(int id, T item) async {
    try {
      final response = await _api.dio.put(
        "$endpoint$id/",
        data: cleanNullData(toMap(item)),
      );
      if (response.statusCode == 200) {
        return fromMap(response.data);
      }
      throw DioException(requestOptions: response.requestOptions,response: response);
    } on DioException catch (e) {
      // ============ مفتاح التفرقة هنا ============

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.badCertificate ||
          e.type == DioExceptionType.connectionError) {
        // ❌ الحالة الأولى: خطأ شبكة/اتصال
        log('❌ Dio: خطأ في الاتصال. محاولة القراءة من الكاش.');

        // try {
        // التحول التلقائي: القراءة من قاعدة البيانات المحلية
        // final localData = await _localDataSource.get(cacheKey);
        // return localData; // إرجاع البيانات المحلية بنجاح
        // } catch (_) {
        // إذا فشلت القراءة من الكاش (لا توجد بيانات محلياً)
        throw NetworkFailure();
        // }
      } else {
        // ❌ الحالة الثانية: استجابة سيئة (4xx أو 5xx) - السيرفر متاح ولكنه أرجع خطأ
        final statusCode = e.response?.statusCode;

        if (statusCode! >= 500) {
          throw ServerFailure(statusCode); // خطأ سيرفر
        } else if (statusCode >= 400) {
          // يمكنك تحليل الـ body للرسالة المخصصة
          throw ClientFailure(
            statusCode,
            e.response?.statusMessage ??
                e.response?.data['error'] ??
                'خطأ في بيانات العميل',
          );
        }
      }

      // ❌ أخطاء Dio أخرى (مثل إلغاء الطلب)
      throw UnknownFailure();
    } catch (_) {
      throw UnknownFailure();
    }
  }

  Future<T> patch(int id, Map<String, dynamic> fields) async {
    try {
      final response = await _api.dio.patch("$endpoint$id/", data: fields);
      if (response.statusCode == 200) {
        return fromMap(response.data);
      }
      throw DioException(requestOptions: response.requestOptions,response: response);
    } on DioException catch (e) {
      // ============ مفتاح التفرقة هنا ============

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.badCertificate ||
          e.type == DioExceptionType.connectionError) {
        // ❌ الحالة الأولى: خطأ شبكة/اتصال
        log('❌ Dio: خطأ في الاتصال. محاولة القراءة من الكاش.');

        // try {
        // التحول التلقائي: القراءة من قاعدة البيانات المحلية
        // final localData = await _localDataSource.get(cacheKey);
        // return localData; // إرجاع البيانات المحلية بنجاح
        // } catch (_) {
        // إذا فشلت القراءة من الكاش (لا توجد بيانات محلياً)
        throw NetworkFailure();
        // }
      } else {
        // ❌ الحالة الثانية: استجابة سيئة (4xx أو 5xx) - السيرفر متاح ولكنه أرجع خطأ
        final statusCode = e.response?.statusCode;

        if (statusCode! >= 500) {
          throw ServerFailure(statusCode); // خطأ سيرفر
        } else if (statusCode >= 400) {
          // يمكنك تحليل الـ body للرسالة المخصصة
          throw ClientFailure(
            statusCode,
            e.response?.statusMessage ??
                e.response?.data['error'] ??
                'خطأ في بيانات العميل',
          );
        }
      }

      // ❌ أخطاء Dio أخرى (مثل إلغاء الطلب)
      throw UnknownFailure();
    } catch (_) {
      throw UnknownFailure();
    }
  }

  Future<void> delete(int id) async {
    try {
      await _api.dio.delete("$endpoint$id/");
    } on DioException catch (e) {
      // ============ مفتاح التفرقة هنا ============

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.badCertificate ||
          e.type == DioExceptionType.connectionError) {
        // ❌ الحالة الأولى: خطأ شبكة/اتصال
        log('❌ Dio: خطأ في الاتصال. محاولة القراءة من الكاش.');

        // try {
        // التحول التلقائي: القراءة من قاعدة البيانات المحلية
        // final localData = await _localDataSource.get(cacheKey);
        // return localData; // إرجاع البيانات المحلية بنجاح
        // } catch (_) {
        // إذا فشلت القراءة من الكاش (لا توجد بيانات محلياً)
        throw NetworkFailure();
        // }
      } else {
        // ❌ الحالة الثانية: استجابة سيئة (4xx أو 5xx) - السيرفر متاح ولكنه أرجع خطأ
        final statusCode = e.response?.statusCode;

        if (statusCode! >= 500) {
          throw ServerFailure(statusCode); // خطأ سيرفر
        } else if (statusCode >= 400) {
          // يمكنك تحليل الـ body للرسالة المخصصة
          throw ClientFailure(
            statusCode,
            e.response?.statusMessage ??
                e.response?.data['error'] ??
                'خطأ في بيانات العميل',
          );
        }
      }

      // ❌ أخطاء Dio أخرى (مثل إلغاء الطلب)
      throw UnknownFailure();
    } catch (_) {
      throw UnknownFailure();
    }
  }
}
