import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/invoice.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/models/attendance.dart';
import 'package:ponit_of_sales/models/category.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/models/debt.dart';
import 'package:ponit_of_sales/models/deposit.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/models/expense.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
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
import 'package:ponit_of_sales/widgets/app_router.dart';
import 'package:provider/provider.dart';
import '../blocs/auth/auth_bloc.dart';
// main screens linke login, dashboard, settings, products, invoices, customers, suppliers etc are here
// استيراد شاشاتك

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => InvoiceProvider()),
        ChangeNotifierProvider(create: (context) => ProductsProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthBloc()),
          BlocProvider(create: (context) => GeneralBloc<SaleInvoice>()),
          BlocProvider(create: (context) => GeneralBloc<SaleItem>()),
          BlocProvider(create: (context) => GeneralBloc<ReturnSale>()),
          BlocProvider(create: (context) => GeneralBloc<POSView>()),
          BlocProvider(create: (context) => GeneralBloc<ProductCategory>()),
          BlocProvider(create: (context) => GeneralBloc<Attendance>()),
          BlocProvider(create: (context) => GeneralBloc<Customer>()),
          BlocProvider(create: (context) => GeneralBloc<Debt>()),
          BlocProvider(create: (context) => GeneralBloc<DebtPayment>()),
          BlocProvider(create: (context) => GeneralBloc<Deposit>()),
          BlocProvider(create: (context) => GeneralBloc<Employee>()),
          BlocProvider(create: (context) => GeneralBloc<Expense>()),
          BlocProvider(create: (context) => GeneralBloc<PaymentMethod>()),
          BlocProvider(create: (context) => GeneralBloc<SalaryPayment>()),
          BlocProvider(create: (context) => GeneralBloc<Product>()),
          BlocProvider(create: (context) => GeneralBloc<PurchaseInvoice>()),
          BlocProvider(create: (context) => GeneralBloc<PurchaseItem>()),
          BlocProvider(create: (context) => GeneralBloc<ReturnPurchase>()),
          BlocProvider(create: (context) => GeneralBloc<Report>()),
          BlocProvider(create: (context) => GeneralBloc<Shift>()),
          BlocProvider(create: (context) => GeneralBloc<StockMovement>()),
          BlocProvider(create: (context) => GeneralBloc<Supplier>()),
          BlocProvider(create: (context) => GeneralBloc<AccountTransaction>()),
          BlocProvider(create: (context) => GeneralBloc<User>()),
        ],
        child: Builder(
          builder: (context) {
            final router = createRouter(context);

            // 3. استخدام MaterialApp.router
            return MaterialApp.router(
              routerConfig: router,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(fontFamily: "Noto Sans Arabic"),
            );
          },
        ),
      ),
    );
  }
}

class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // gotoLogin(context);
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("assets/logo/logo-no-background.png"),
              fit: BoxFit.contain,
              height: 100,
              width: 110,
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
