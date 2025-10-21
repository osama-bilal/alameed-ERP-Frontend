part of 'return_bloc.dart';

sealed class ReturnEvent extends Equatable {
  const ReturnEvent();

  @override
  List<Object> get props => [];
}

/// Event to process the return for the given invoice.
class ProcessReturn extends ReturnEvent {
  const ProcessReturn();
}

class StartReturn extends ReturnEvent {
  final String returnCode;
  const StartReturn({required this.returnCode});
  @override
  List<Object> get props => [returnCode];
}

class StartReplace extends ReturnEvent {
  final SaleInvoice oldInvoice;
  final List<ReturnSale> itemsReturned;
  const StartReplace({required this.itemsReturned, required this.oldInvoice});
  @override
  List<Object> get props => [oldInvoice, itemsReturned];
}

class CancelReturn extends ReturnEvent {
  const CancelReturn();
}

class ReturnMoney extends ReturnEvent {
  final List<ReturnSale> items;
  const ReturnMoney({required this.items});
}

class AddReturn extends ReturnEvent {
  final ReturnSale item;
  const AddReturn({required this.item});
  @override
  List<Object> get props => [item];
}
