part of 'sell_bloc.dart';

sealed class PurchEvent extends Equatable {
  const PurchEvent();

  @override
  List<Object> get props => [];
}

final class StartSell extends PurchEvent {
  final PurchaseInvoice invoiceSell;
  const StartSell({required this.invoiceSell});
}

final class ConfirmSell extends PurchEvent {
  final PurchaseInvoice? invoice;
  final String action;
  const ConfirmSell({this.invoice, required this.action});
  @override
  List<Object> get props => [?invoice, action];
}

final class RefreshInvoice extends PurchEvent {
  final int id;
  const RefreshInvoice({required this.id});
  @override
  List<Object> get props => [id];
}

final class PrintFinished extends PurchEvent {}
