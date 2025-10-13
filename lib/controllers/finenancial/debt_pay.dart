import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/debt.dart';

class DebtPayController {
  DebtPayController({required this.context});
  final BuildContext context;

  void fethAll() {
    BlocProvider.of<GeneralBloc<DebtPayment>>(
      context,
    ).add(LoadItems());
  }

  void createItem(DebtPayment item) {
    BlocProvider.of<GeneralBloc<DebtPayment>>(
      context,
    ).add(AddItem(item));
  }

  void deleteItem(int id) {
    BlocProvider.of<GeneralBloc<DebtPayment>>(context).add(DeleteItem(id));
  }

  void patialUpdate(int id, Map<String, dynamic> changes) {
    BlocProvider.of<GeneralBloc<DebtPayment>>(
      context,
    ).add(PartialUpdateItem(changes: changes, itemId: id));
  }

  void update(int id, DebtPayment item) {
    BlocProvider.of<GeneralBloc<DebtPayment>>(
      context,
    ).add(UpdateItem(item: item, itemId: id));
  }
}
