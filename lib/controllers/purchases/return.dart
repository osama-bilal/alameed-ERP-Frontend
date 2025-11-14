import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';

class ReturnSaleController {
  ReturnSaleController({required this.context});
  final BuildContext context;

  void fethAll() {
    BlocProvider.of<GeneralBloc<ReturnPurchase>>(context).add(LoadItems());
  }

  void createItem(ReturnPurchase item) {
    BlocProvider.of<GeneralBloc<ReturnPurchase>>(context).add(AddItem(item));
  }

  void deleteItem(int id) {
    BlocProvider.of<GeneralBloc<ReturnPurchase>>(context).add(DeleteItem(id));
  }

  void patialUpdate(int id, Map<String, dynamic> changes) {
    BlocProvider.of<GeneralBloc<ReturnPurchase>>(
      context,
    ).add(PartialUpdateItem(changes: changes, itemId: id));
  }

  void update(int id, ReturnPurchase item) {
    BlocProvider.of<GeneralBloc<ReturnPurchase>>(
      context,
    ).add(UpdateItem<ReturnPurchase>(item: item, itemId: id));
  }
}
