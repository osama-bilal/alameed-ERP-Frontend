import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/pos/p_os_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/blocs/return/return_bloc.dart';
import 'package:ponit_of_sales/blocs/sell/sell_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/controllers/provider/return.dart';
import 'package:ponit_of_sales/controllers/provider/shift.dart';
import 'package:ponit_of_sales/core/app_theme.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/attendance.dart';
import 'package:ponit_of_sales/models/brand.dart';
import 'package:ponit_of_sales/models/category.dart';
import 'package:ponit_of_sales/models/customer.dart';
import 'package:ponit_of_sales/models/debt.dart';
import 'package:ponit_of_sales/models/deposit.dart';
import 'package:ponit_of_sales/models/employee.dart';
import 'package:ponit_of_sales/models/expense.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/options.dart';
// import 'package:ponit_of_sales/models/party.dart';
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
// import 'package:ponit_of_sales/services/general_services.dart';
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
        // ChangeNotifierProvider(create: (context) => SellingProvider()),
        ChangeNotifierProvider(create: (context) => ProductsProvider()),
        ChangeNotifierProvider(create: (context) => ShiftProvider()),
        ChangeNotifierProvider(create: (context) => AppParties()),
        ChangeNotifierProvider(create: (context) => ReturnProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SellingBloc()),
          BlocProvider(create: (context) => PosBloc()),
          BlocProvider(create: (context) => AuthBloc()),
          // BlocProvider(create: (context) => GeneralBloc<ViewParty>(
          //   GeneralService<ViewParty>(
          //     endpoint: "/parties/groups/",
          //     fromMap: ViewParty.fromMap,
          //     toMap: (o) => o.toMap(),
          //   ),
          // )),
          BlocProvider(
            create: (context) =>
                GeneralBloc<POSView>(AppService.posViewService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<Attendance>(AppService.attendanceService),
          ),
          BlocProvider(
            create: (context) => GeneralBloc<Brand>(AppService.brandService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<Customer>(AppService.customerService),
          ),
          BlocProvider(
            create: (context) => GeneralBloc<Debt>(AppService.debtService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<DebtPayment>(AppService.debtPaymentService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<Deposit>(AppService.depositService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<Employee>(AppService.employeeService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<Expense>(AppService.expenseService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<OptionsValue>(AppService.optionValueService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<OptionsType>(AppService.optionTypeService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<PaymentMethod>(AppService.payMethodService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<SalaryPayment>(AppService.salaryService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<Product>(AppService.productService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<ProductVariant>(AppService.variantService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<ProductCategory>(AppService.categoryService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<PurchaseInvoice>(AppService.purchaseInvoiceService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<PurchaseItem>(AppService.purchaseItemService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<ReturnPurchase>(AppService.returnPurchaseService),
          ),
          BlocProvider(
            create: (context) => GeneralBloc<Report>(AppService.reportService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<SaleInvoice>(AppService.saleInvoiceService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<SaleItem>(AppService.saleItemService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<ReturnSale>(AppService.returnSaleService),
          ),
          BlocProvider(
            create: (context) => GeneralBloc<Shift>(AppService.shiftService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<StockMovement>(AppService.stockService),
          ),
          BlocProvider(
            create: (context) =>
                GeneralBloc<Supplier>(AppService.supplierService),
          ),
          BlocProvider(
            create: (context) => GeneralBloc<AccountTransaction>(
              AppService.accountTransactionService,
            ),
          ),
          BlocProvider(
            create: (context) => GeneralBloc<User>(AppService.usersService),
          ),
          BlocProvider(create: (context) => ReturnBloc()),
        ],
        child: Builder(
          builder: (context) {
            final router = createRouter(context);
            context.read<AuthBloc>().add(AppStarted());
            // 3. استخدام MaterialApp.router
            return MaterialApp.router(
              routerConfig: router,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
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
