import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/debt.dart';

class DebtController {
  DebtController({required this.context});
  final BuildContext context;

  void fethAll() {
    BlocProvider.of<GeneralBloc<Debt>>(
      context,
    ).add(LoadItems<Debt>(AppService.debtService));
  }

  void createItem(Debt item) {
    BlocProvider.of<GeneralBloc<Debt>>(
      context,
    ).add(AddItem<Debt>(AppService.debtService, item));
  }

  void deleteItem(int id) {
    BlocProvider.of<GeneralBloc<Debt>>(
      context,
    ).add(DeleteItem(AppService.debtService, id));
  }

  void patialUpdate(int id, Map<String, dynamic> changes) {
    BlocProvider.of<GeneralBloc<Debt>>(
      context,
    ).add(PartialUpdateItem<Debt>(AppService.debtService, changes, id));
  }

  void update(int id, Debt item) {
    BlocProvider.of<GeneralBloc<Debt>>(
      context,
    ).add(UpdateItem<Debt>(AppService.debtService, item, id));
  }
}
