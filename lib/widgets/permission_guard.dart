import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/auth/auth_bloc.dart';
// استورد ملفات الـ BLoC والحالات

class PermissionGuard extends StatelessWidget {
  final List<String> requiredPermissions;
  final Widget child;
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
      selector: (state) {
        if (state is AuthAuthenticated) {
          return state.user.permissions;
        }
        return [];
      },
      builder: (context, userPermissions) {
        final hasPermission = requiredPermissions.every(
          (requiredPerm) => userPermissions.contains(requiredPerm),
        );

        if (hasPermission) {
          return child;
        } else {
          return fallback ?? const SizedBox(height: 0, width: 0);
        }
      },
    );
  }
}

class AnyPermissionGuard extends StatelessWidget {
  // الصلاحية (أو مجموعة الصلاحيات) المطلوبة للعرض
  final List<String> tables;
  final Widget child;
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
          return state.user.permissions;
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
          return child;
        } else {
          return fallback ?? const SizedBox(height: 0, width: 0);
        }
      },
    );
  }
}
