part of 'p_os_bloc.dart';

// Events
sealed class PosPurchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPosData extends PosPurchEvent {}

class SetActiveInvoice extends PosPurchEvent {
  final PurchaseInvoice invoice;
  SetActiveInvoice(this.invoice);
}

class CreateNewInvoice extends PosPurchEvent {}

class AddProductToActiveInvoice extends PosPurchEvent {
  final POSView product;
  AddProductToActiveInvoice(this.product);
}

class UpdateItem extends PosPurchEvent {
  final int localItemId;
  final PurchaseItem newItem;
  UpdateItem(this.localItemId, this.newItem);
}

class RemoveItemFromActiveInvoice extends PosPurchEvent {
  final int localItemId;
  RemoveItemFromActiveInvoice(this.localItemId);
}

class Reset extends PosPurchEvent {}

class ClearActiveInvoice extends PosPurchEvent {}
