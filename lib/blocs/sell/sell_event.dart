part of 'sell_bloc.dart';

sealed class SellingEvent extends Equatable {
  const SellingEvent();

  @override
  List<Object> get props => [];
}

final class StartSell extends SellingEvent {
  final SaleInvoice invoiceSell;
  const StartSell({required this.invoiceSell});
}

final class ConfirmSell extends SellingEvent {
  final SaleInvoice? invoice;
  final String action;
  const ConfirmSell({this.invoice, required this.action});
  @override
  List<Object> get props => [?invoice, action];
}

final class RefreshInvoice extends SellingEvent {
  final int id;
  const RefreshInvoice({required this.id});
  @override
  List<Object> get props => [id];
}

final class PrintFinished extends SellingEvent {}
