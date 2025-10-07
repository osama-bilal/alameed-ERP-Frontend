import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';

class ReturnSaleController {
  ReturnSaleController({required this.context});
  final BuildContext context;

  void fethAll() {
    BlocProvider.of<GeneralBloc<ReturnPurchase>>(
      context,
    ).add(LoadItems<ReturnPurchase>(AppService.returnPurchaseService));
  }

  void createItem(ReturnPurchase item) {
    BlocProvider.of<GeneralBloc<ReturnPurchase>>(
      context,
    ).add(AddItem<ReturnPurchase>(AppService.returnPurchaseService, item));
  }

  void deleteItem(int id) {
    BlocProvider.of<GeneralBloc<ReturnPurchase>>(
      context,
    ).add(DeleteItem(AppService.returnPurchaseService, id));
  }

  void patialUpdate(int id, Map<String, dynamic> changes) {
    BlocProvider.of<GeneralBloc<ReturnPurchase>>(
      context,
    ).add(PartialUpdateItem<ReturnPurchase>(AppService.returnPurchaseService, changes, id));
  }

  void update(int id, ReturnPurchase item) {
    BlocProvider.of<GeneralBloc<ReturnPurchase>>(
      context,
    ).add(UpdateItem<ReturnPurchase>(AppService.returnPurchaseService, item, id));
  }
}
