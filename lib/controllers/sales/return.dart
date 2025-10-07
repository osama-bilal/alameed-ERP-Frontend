import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';

class ReturnSaleController {
  ReturnSaleController({required this.context});
  final BuildContext context;

  void fethAll() {
    BlocProvider.of<GeneralBloc<ReturnSale>>(
      context,
    ).add(LoadItems<ReturnSale>(AppService.returnSaleService));
  }

  void createItem(ReturnSale item) {
    BlocProvider.of<GeneralBloc<ReturnSale>>(
      context,
    ).add(AddItem<ReturnSale>(AppService.returnSaleService, item));
  }

  void deleteItem(int id) {
    BlocProvider.of<GeneralBloc<ReturnSale>>(
      context,
    ).add(DeleteItem(AppService.returnSaleService, id));
  }

  void patialUpdate(int id, Map<String, dynamic> changes) {
    BlocProvider.of<GeneralBloc<ReturnSale>>(
      context,
    ).add(PartialUpdateItem<ReturnSale>(AppService.returnSaleService, changes, id));
  }

  void update(int id, ReturnSale item) {
    BlocProvider.of<GeneralBloc<ReturnSale>>(
      context,
    ).add(UpdateItem<ReturnSale>(AppService.returnSaleService, item, id));
  }
}
