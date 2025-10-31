import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/auth/auth_bloc.dart';

List<String> allowedHomeTabs(BuildContext context) {
  final state = context.read<AuthBloc>().state;
  if (state is! AuthAuthenticated) {
    return [];
  }
  final perms = state.user.permissions;
  final prefixes = ['add_', 'change_', 'view_', 'delete_'];
  final isAdmin = state.user.isAdmin;
  if (isAdmin) {
    return [
      'pos',
      'sales',
      'purchase',
      'accounting',
      'hr',
      'inventory',
      'reports',
      'settings',
      'about',
    ];
  }
  final List<String> allowed = [];
  final Map<String, List<String>> tabsWithTable = {
    'pos': ['product'],
    'sales': ['saleinvoice', 'saleitem', 'returnsale'],
    'accounting': [
      'debt',
      'debtpayment',
      'expense',
      'deposit',
      'salarypayment',
      'accounttransaction',
      'paymentmethod',
    ],
    'purchase': ['purchaseinvoice', 'purchaseitem', 'returnpurchase'],
    'hr': ['customer', 'supplier', 'employee', 'attendance', 'shift'],
    'reports': ['report'],
    'inventory': ['stockmovement', 'product'],
  };
  tabsWithTable.forEach((tab, tables) {
    if (tables.any(
      (table) => prefixes.any((p) => perms.contains('$p$table')),
    )) {
      allowed.add(tab);
    }
  });
  allowed.addAll(['settings', 'about']);

  return LinkedHashSet<String>.from(allowed).toList();
}
