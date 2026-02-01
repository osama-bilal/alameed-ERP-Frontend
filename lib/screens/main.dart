import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/internet/internet_connect_cubit.dart';
import '/blocs/pos%20purch/p_os_bloc.dart';
import '/blocs/pos%20purch/return/return_bloc.dart';
import '/blocs/pos%20purch/sell/sell_bloc.dart';
import '/blocs/pos/p_os_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/blocs/return/return_bloc.dart';
import '/blocs/sell/sell_bloc.dart';
import '/controllers/provider/parties.dart';
import '/controllers/provider/pos_view.dart';
import '/controllers/provider/return.dart';
import '/controllers/provider/theme_provider.dart';
import '/controllers/provider/locale_provider.dart';
import '/controllers/provider/shift.dart';
import '/core/app_theme.dart';
import '/core/main.dart';
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
import '/widgets/app_router.dart';
import 'package:provider/provider.dart';
import '../blocs/auth/auth_bloc.dart';
import '../l10n/app_localizations.dart';

// main screens linke login, dashboard, settings, products, invoices, customers, suppliers etc are here
// استيراد شاشاتك

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductsProvider()),
        ChangeNotifierProvider(create: (context) => ShiftProvider()),
        ChangeNotifierProvider(create: (context) => AppParties()),
        ChangeNotifierProvider(create: (context) => ReturnProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SellingBloc()),
          BlocProvider(create: (context) => PosBloc()),
          BlocProvider(create: (context) => PosPurchBloc()),
          BlocProvider(create: (context) => PurchBloc()),
          BlocProvider(create: (context) => ReturnPurchBloc()),
          BlocProvider(create: (context) => AuthBloc()),
          BlocProvider(create: (context) => ReturnBloc()),
          BlocProvider(create: (context) => InternetConnectCubit()),
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
          BlocProvider(
            create: (context) => GeneralBloc<Groups>(AppService.groupsService),
          ),
        ],
        child: Consumer2<ThemeProvider, LocaleProvider>(
          builder: (context, themeProvider, localeProvider, child) {
            final router = createRouter(context);
            context.read<AuthBloc>().add(AppStarted());
            return MaterialApp.router(
              // ... inside MaterialApp
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: localeProvider.locale,
              routerConfig: router,
              debugShowCheckedModeBanner: false,
              theme: themeProvider.themeData,
              darkTheme: AppTheme.darkTheme, // Optional, but good practice
              themeMode: themeProvider.themeMode,
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
