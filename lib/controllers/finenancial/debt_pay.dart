import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/debt.dart';

class DebtPayController {
  DebtPayController({required this.context});
  final BuildContext context;

  void fethAll() {
    BlocProvider.of<GeneralBloc<DebtPayment>>(
      context,
    ).add(LoadItems<DebtPayment>(AppService.debtPaymentService));
  }

  void createItem(DebtPayment item) {
    BlocProvider.of<GeneralBloc<DebtPayment>>(
      context,
    ).add(AddItem<DebtPayment>(AppService.debtPaymentService, item));
  }

  void deleteItem(int id) {
    BlocProvider.of<GeneralBloc<DebtPayment>>(
      context,
    ).add(DeleteItem(AppService.debtPaymentService, id));
  }

  void patialUpdate(int id, Map<String, dynamic> changes) {
    BlocProvider.of<GeneralBloc<DebtPayment>>(
      context,
    ).add(PartialUpdateItem<DebtPayment>(AppService.debtPaymentService, changes, id));
  }

  void update(int id, DebtPayment item) {
    BlocProvider.of<GeneralBloc<DebtPayment>>(
      context,
    ).add(UpdateItem<DebtPayment>(AppService.debtPaymentService, item, id));
  }
}
