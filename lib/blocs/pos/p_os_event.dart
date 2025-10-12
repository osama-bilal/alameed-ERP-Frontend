part of 'p_os_bloc.dart';

// Events
sealed class PosEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPosData extends PosEvent {}

class SetActiveInvoice extends PosEvent {
  final SaleInvoice invoice;
  SetActiveInvoice(this.invoice);
}

class CreateNewInvoice extends PosEvent {}

class AddProductToActiveInvoice extends PosEvent {
  final POSView product;
  AddProductToActiveInvoice(this.product);
}

class UpdateItem extends PosEvent {
  final int localItemId;
  final SaleItem newItem;
  UpdateItem(this.localItemId, this.newItem);
}

class RemoveItemFromActiveInvoice extends PosEvent {
  final int localItemId;
  RemoveItemFromActiveInvoice(this.localItemId);
}

class UpdateSellInvoice extends PosEvent {
  final int id;
  final SaleInvoice invoice;
  UpdateSellInvoice({required this.id, required this.invoice});

  @override
  List<Object?> get props => [id, invoice];
}

class FinalizeActiveInvoice extends PosEvent {}

class PaySellInvoice extends PosEvent {
  final String amount;
  PaySellInvoice({required this.amount});

  @override
  List<Object?> get props => [amount];
}

class SetUnpaidSell extends PosEvent {}

class CancelSell extends PosEvent {}

class Reset extends PosEvent {}

class SaveAnd extends PosEvent {
  final PosEvent thenGo;
  final SaleInvoice invoice;
  SaveAnd({required this.thenGo, required this.invoice});
}
