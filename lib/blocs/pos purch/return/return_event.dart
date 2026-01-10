part of 'return_bloc.dart';

sealed class ReturnPurchEvent extends Equatable {
  const ReturnPurchEvent();

  @override
  List<Object> get props => [];
}

/// Event to process the return for the given invoice.
class ProcessReturn extends ReturnPurchEvent {
  const ProcessReturn();
}

class StartReturn extends ReturnPurchEvent {
  final String returnCode;
  const StartReturn({required this.returnCode});
  @override
  List<Object> get props => [returnCode];
}

class StartReplace extends ReturnPurchEvent {
  final PurchaseInvoice oldInvoice;
  final List<ReturnPurchase> itemsReturned;
  const StartReplace({required this.itemsReturned, required this.oldInvoice});
  @override
  List<Object> get props => [oldInvoice, itemsReturned];
}

class CancelReturn extends ReturnPurchEvent {
  const CancelReturn();
}

class ReturnMoney extends ReturnPurchEvent {
  final List<ReturnPurchase> items;
  const ReturnMoney({required this.items});
}

class AddReturn extends ReturnPurchEvent {
  final ReturnPurchase item;
  const AddReturn({required this.item});
  @override
  List<Object> get props => [item];
}
