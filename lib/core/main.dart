// here is set the shared preferences and other main things like database and api services and constants and colors, styles
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ponit_of_sales/models/attendance.dart';
import 'package:ponit_of_sales/models/brand.dart';
import 'package:ponit_of_sales/models/category.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/models/debt.dart';
import 'package:ponit_of_sales/models/deposit.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/models/expense.dart';
import 'package:ponit_of_sales/models/groups.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/options.dart';
import 'package:ponit_of_sales/models/payment_method.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/models/product.dart';
import 'package:ponit_of_sales/models/report.dart';
import 'package:ponit_of_sales/models/salarypayment.dart';
import 'package:ponit_of_sales/models/shift.dart';
import 'package:ponit_of_sales/models/stockmovement.dart';
import 'package:ponit_of_sales/models/supplier.dart';
import 'package:ponit_of_sales/models/transections.dart';
import 'package:ponit_of_sales/models/user.dart';
import 'package:ponit_of_sales/services/general_services.dart';

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
