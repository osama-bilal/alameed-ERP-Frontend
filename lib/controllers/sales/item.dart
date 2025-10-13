import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/services/general_services.dart';

class SaleItemsController {
  SaleItemsController({required this.context});
  final BuildContext context;

  void fethAll() {
    BlocProvider.of<GeneralBloc<SaleItem>>(
      context,
    ).add(LoadItems());
  }

  void getInvoiceSales(int invoiceId) {
    BlocProvider.of<GeneralBloc<SaleItem>>(context).add(
      LoadItems(tempService: 
        GeneralService<SaleItem>(
          endpoint: "/invoices/sale-items/?invoice=$invoiceId",
          fromMap: SaleItem.fromMap,
          toMap: (o) => o.toMap(),
        ),
      ),
    );
  }

  void createItem(SaleItem item) {
    BlocProvider.of<GeneralBloc<SaleItem>>(
      context,
    ).add(AddItem(item));
  }

  void deleteItem(int id) {
    BlocProvider.of<GeneralBloc<SaleItem>>(
      context,
    ).add(DeleteItem(id));
  }

  void patialUpdate(int id, Map<String, dynamic> changes) {
    BlocProvider.of<GeneralBloc<SaleItem>>(
      context,
    ).add(PartialUpdateItem(changes: changes, itemId: id));
  }

  void update(int id, SaleItem item) {
    BlocProvider.of<GeneralBloc<SaleItem>>(
      context,
    ).add(UpdateItem(item: item, itemId: id));
  }
}
