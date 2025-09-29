  import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/auth/auth_bloc.dart';

Map<String, bool> tablePermissions(BuildContext context, String table) {
    final state = context.read<AuthBloc>().state;
    List<String> userPermissions = [];
    if (state is AuthAuthenticated) {
      userPermissions = state.permissions;
    }

    final prefixes = ['add_', 'change_', 'view_', 'delete_'];
    final result = <String, bool>{};

    for (var p in prefixes) {
      final key = p.replaceAll('_', ''); // e.g. 'add_'=> 'add'
      result[key] = userPermissions.contains('${p}$table');
    }

    return result;
  }