import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/auth/auth_bloc.dart';
// استورد ملفات الـ BLoC والحالات

class PermissionGuard extends StatelessWidget {
  // الصلاحية (أو مجموعة الصلاحيات) المطلوبة للعرض
  final List<String> requiredPermissions;
  // الـ Widget الذي سيتم عرضه إذا كانت الصلاحيات متوفرة
  final Widget child;
  // الـ Widget الذي سيتم عرضه في حال عدم توفر الصلاحيات (اختياري، الافتراضي هو إخفاء العنصر)
  final Widget? fallback;

  const PermissionGuard({
    super.key,
    required this.requiredPermissions,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc, AuthState, List<String>>(
      // نقوم باستخلاص قائمة الصلاحيات فقط من حالة المصادقة
      selector: (state) {
        if (state is AuthAuthenticated) {
          return state.permissions;
        }
        return [];
      },
      builder: (context, userPermissions) {
        // التحقق من وجود كل الصلاحيات المطلوبة في قائمة صلاحيات المستخدم
        final hasPermission = requiredPermissions.every(
          (requiredPerm) => userPermissions.contains(requiredPerm),
        );

        if (hasPermission) {
          return child; // عرض الـ Widget المحمي
        } else {
          // عرض الـ Widget الاحتياطي أو إخفاء العنصر تماماً
          return fallback ?? const SizedBox(height: 0, width: 0);
        }
      },
    );
  }
}

class AnyPermissionGuard extends StatelessWidget {
  // الصلاحية (أو مجموعة الصلاحيات) المطلوبة للعرض
  final List<String> tables;
  // الـ Widget الذي سيتم عرضه إذا كانت الصلاحيات متوفرة
  final Widget child;
  // الـ Widget الذي سيتم عرضه في حال عدم توفر الصلاحيات (اختياري، الافتراضي هو إخفاء العنصر)
  final Widget? fallback;

  AnyPermissionGuard({
    super.key,
    required this.tables,
    required this.child,
    this.fallback,
  });
  final defaultPermissions = ["add_", "change_", "view_", "delete_"];
  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc, AuthState, List<String>>(
      // نقوم باستخلاص قائمة الصلاحيات فقط من حالة المصادقة
      selector: (state) {
        if (state is AuthAuthenticated) {
          return state.permissions;
        }
        return [];
      },
      builder: (context, userPermissions) {
        List<String> required = [];
        for (var perm in defaultPermissions) {
          for (var table in tables) {
            required.add("$perm$table");
          }
        }
        // التحقق من وجود كل الصلاحيات المطلوبة في قائمة صلاحيات المستخدم
        final hasPermission = required.any(
          (requiredPerm) => userPermissions.contains(requiredPerm),
        );

        if (hasPermission) {
          return child; // عرض الـ Widget المحمي
        } else {
          // عرض الـ Widget الاحتياطي أو إخفاء العنصر تماماً
          return fallback ?? const SizedBox(height: 0, width: 0);
        }
      },
    );
  }
}
