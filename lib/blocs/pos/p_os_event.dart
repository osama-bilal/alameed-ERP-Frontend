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
class Reset extends PosEvent {}

class ClearActiveInvoice extends PosEvent{}