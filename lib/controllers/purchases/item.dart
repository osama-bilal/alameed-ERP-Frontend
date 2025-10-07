import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/services/general_services.dart';

class PurchaseItemController {
  PurchaseItemController({required this.context});
  final BuildContext context;

  void fethAll() {
    BlocProvider.of<GeneralBloc<PurchaseItem>>(
      context,
    ).add(LoadItems<PurchaseItem>(AppService.purchaseItemService));
  }

  void getInvoiceSales(int invoiceId) {
    BlocProvider.of<GeneralBloc<PurchaseItem>>(context).add(
      LoadItems<PurchaseItem>(
        GeneralService<PurchaseItem>(
          endpoint: "/invoices/purchase-items/?invoice=$invoiceId",
          fromMap: PurchaseItem.fromMap,
          toMap: (o) => o.toMap(),
        ),
      ),
    );
  }

  void createItem(PurchaseItem item) {
    BlocProvider.of<GeneralBloc<PurchaseItem>>(
      context,
    ).add(AddItem<PurchaseItem>(AppService.purchaseItemService, item));
  }

  void deleteItem(int id) {
    BlocProvider.of<GeneralBloc<PurchaseItem>>(
      context,
    ).add(DeleteItem(AppService.purchaseItemService, id));
  }

  void patialUpdate(int id, Map<String, dynamic> changes) {
    BlocProvider.of<GeneralBloc<PurchaseItem>>(
      context,
    ).add(PartialUpdateItem<PurchaseItem>(AppService.purchaseItemService, changes, id));
  }

  void update(int id, PurchaseItem item) {
    BlocProvider.of<GeneralBloc<PurchaseItem>>(
      context,
    ).add(UpdateItem<PurchaseItem>(AppService.purchaseItemService, item, id));
  }
}
