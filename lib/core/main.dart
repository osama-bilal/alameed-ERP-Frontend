// here is set the shared preferences and other main things like database and api services and constants and colors, styles
import 'dart:async';

import 'package:flutter/foundation.dart';
import '/models/attendance.dart';
import '/models/brand.dart';
import '/models/category.dart';
import '/models/customer.dart';
import '/models/debt.dart';
import '/models/deposit.dart';
import '/models/employee.dart';
import '/models/expense.dart';
import '/models/groups.dart';
import '/models/invoices/purchase.dart';
import '/models/invoices/sale.dart';
import '/models/options.dart';
import '/models/payment_method.dart';
import '/models/pos_view.dart';
import '/models/product.dart';
import '/models/report.dart';
import '/models/salarypayment.dart';
import '/models/shift.dart';
import '/models/stockmovement.dart';
import '/models/supplier.dart';
import '/models/transections.dart';
import '/models/user.dart';
import '/services/general_services.dart';

part 'app_service.dart';
part 'app_urls.dart';

Timer? _syncTimer;

final List<Function> _pendingOps = [];

void scheduleOp<T>(Function operation) {
  _pendingOps.add(operation);
  // إعادة ضبط المؤقت
  _syncTimer?.cancel();
  _syncTimer = Timer(const Duration(seconds: 5), () {
    for (var op in _pendingOps) {
      try {
        op;
      } catch (e) {
        throw Exception(e);
      }
    }
    _pendingOps.clear();
  });
}
