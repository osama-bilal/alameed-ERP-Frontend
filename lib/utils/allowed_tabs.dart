import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/auth/auth_bloc.dart';

List<String> allowedHomeTabs(BuildContext context) {
  final state = context.read<AuthBloc>().state;
  final perms = (state is AuthAuthenticated) ? state.permissions : <String>[];
  final prefixes = ['add_', 'change_', 'view_', 'delete_'];

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
    'hr': ['customer', 'supplier', 'employee', 'attendance', 'shift', 'user'],
    'reports': ['report'],
    'inventory': ['stockmovement', 'product'],
  };
  // // POS requires view_product
  // if (perms.contains('view_product')) {
  //   allowed.add('pos');
  // }

  // // sales
  // // const salesTables = ['saleinvoice', 'saleitem', 'returnsale'];
  // final hasSales = tabsWithTable['sales']!.any(
  //   (table) => prefixes.any((p) => perms.contains('$p$table')),
  // );
  // if (hasSales) allowed.add('sales');
  // // Sales is always available in the current UI

  // // Accounting: any permission on accounting-related tables
  // // const accountingTables = [
  // //   'debt',
  // //   'debtpayment',
  // //   'expense',
  // //   'deposit',
  // //   'salarypayment',
  // //   'accounttransaction',
  // //   'paymentmethod',
  // // ];
  tabsWithTable.forEach((tab, tables) {
    if (tables.any(
      (table) => prefixes.any((p) => perms.contains('$p$table')),
    )) {
      allowed.add(tab);
    }
  });
  // final hasAccounting = tabsWithTable['accounting']!.any(
  //   (table) => prefixes.any((p) => perms.contains('$p$table')),
  // );
  // if (hasAccounting) allowed.add('accounting');

  // // Purchase: any permission on purchase related tables
  // // const purchaseTables = ['purchaseinvoice', 'purchaseitem', 'returnpurchase'];
  // final hasPurchase = purchaseTables.any(
  //   (table) => prefixes.any((p) => perms.contains('$p$table')),
  // );
  // if (hasPurchase) allowed.add('purchase');

  // const hrTables = [
  //   'customer',
  //   'supplier',
  //   'employee',
  //   'attendance',
  //   'shift',
  //   'user',
  // ];
  // final hasHR = hrTables.any(
  //   (table) => prefixes.any((p) => perms.contains('$p$table')),
  // );
  // if (hasHR) allowed.add("hr");

  // //
  // const reportsTables = ['report'];
  // final hasReporta = reportsTables.any(
  //   (table) => prefixes.any((p) => perms.contains('$p$table')),
  // );
  // if (hasReporta) allowed.add("reports");
  // The following tabs were not guarded in the original HomeScreen,
  // include them by default
  allowed.addAll(['settings', 'about']);

  // Remove duplicates just in case and preserve insertion order
  return LinkedHashSet<String>.from(allowed).toList();
}
