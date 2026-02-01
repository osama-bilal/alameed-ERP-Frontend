import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/auth/auth_bloc.dart';

Map<String, bool> tablePermissions(BuildContext context, String table) {
  final state = context.read<AuthBloc>().state;
  List<String> userPermissions = [];
  if (state is AuthAuthenticated) {
    userPermissions = state.user.permissions;
  } else {
    return {'add': false, 'change': false, 'view': false, 'delete': false};
  }

  final prefixes = ['add_', 'change_', 'view_', 'delete_'];
  final result = <String, bool>{};

  for (var p in prefixes) {
    final key = p.replaceAll('_', '');
    result[key] = userPermissions.contains('$p$table');
  }

  return result;
}

bool hasPermission(BuildContext context, String table, String permissionType) {
  final permissions = tablePermissions(context, table);
  return permissions[permissionType] ?? false;
}

bool isAdmin(BuildContext context) {
  final state = context.read<AuthBloc>().state;
  if (state is AuthAuthenticated) {
    return state.user.isAdmin;
  }
  return false;
}
