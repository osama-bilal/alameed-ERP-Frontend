import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
      } else if (response.statusCode == 204) {
        return [];
      } else if (response.statusCode == 404) {
        throw ClientFailure(404, 'Not Found');
      } else if (response.statusCode == 202) {
        throw SuccessResponse(202, 'Accepted but no content');
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
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
        if (statusCode == null) {
          debugPrint(e.error.toString());
          throw UnknownFailure();
        }
        if (statusCode >= 500) {
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
      throw e.error ?? e;
    } catch (e) {
      rethrow;
    }
  }

  Future<T> fetchItem(int? id, {Map<String, dynamic>? queryParams}) async {
    final point = id == null ? endpoint : "$endpoint$id/";
    try {
      final response = await _api.dio.get(point, queryParameters: queryParams);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return fromMap(data);
      } else if (response.statusCode == 204) {
        throw SuccessResponse(204, 'No Content');
      } else if (response.statusCode == 404) {
        throw ClientFailure(404, 'Not Found');
      } else if (response.statusCode == 202) {
        throw SuccessResponse(202, 'Accepted but no content');
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
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
        if (statusCode == null) {
          debugPrint(e.error.toString());
          throw UnknownFailure();
        }
        if (statusCode >= 500) {
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
      throw e.error ?? e;
    } catch (e) {
      rethrow;
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
      } else if (response.statusCode == 204) {
        throw SuccessResponse(204, 'No Content');
      } else if (response.statusCode == 404) {
        throw ClientFailure(404, 'Not Found');
      } else if (response.statusCode == 202) {
        throw SuccessResponse(202, 'Accepted but no content');
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
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
        if (statusCode == null) {
          debugPrint(e.error.toString());
          throw UnknownFailure();
        }
        if (statusCode >= 500) {
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
      throw e.error ?? e;
    } catch (e) {
      rethrow;
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
      } else if (response.statusCode == 204) {
        throw SuccessResponse(204, 'No Content');
      } else if (response.statusCode == 404) {
        throw ClientFailure(404, 'Not Found');
      } else if (response.statusCode == 202) {
        throw SuccessResponse(202, 'Accepted but no content');
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
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
        if (statusCode == null) {
          debugPrint(e.error.toString());
          throw UnknownFailure();
        }
        if (statusCode >= 500) {
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
      throw e.error ?? e;
    } catch (e) {
      rethrow;
    }
  }

  Future<T> patch(int id, Map<String, dynamic> fields) async {
    try {
      final response = await _api.dio.patch("$endpoint$id/", data: fields);
      if (response.statusCode == 200) {
        return fromMap(response.data);
      } else if (response.statusCode == 204) {
        throw SuccessResponse(204, 'No Content');
      } else if (response.statusCode == 404) {
        throw ClientFailure(404, 'Not Found');
      } else if (response.statusCode == 202) {
        throw SuccessResponse(202, 'Accepted but no content');
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
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
        if (statusCode == null) {
          debugPrint(e.error.toString());
          throw UnknownFailure();
        }
        if (statusCode >= 500) {
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
      throw e.error ?? e;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      final response = await _api.dio.delete("$endpoint$id/");
      if (response.statusCode == 404) {
        throw ClientFailure(404, 'Not Found');
      } else if (response.statusCode == 202) {
        throw SuccessResponse(202, 'Accepted but no content');
      }
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
        if (statusCode == null) {
          debugPrint(e.error.toString());
          throw UnknownFailure();
        }
        if (statusCode >= 500) {
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
      throw e.error ?? e;
    } catch (e) {
      rethrow;
    }
  }
}
