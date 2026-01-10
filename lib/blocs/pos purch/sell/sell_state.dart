part of 'sell_bloc.dart';

sealed class PurchState extends Equatable {
  final String? error;
  const PurchState({this.error});
  PurchState copyWithError(String error);
  @override
  List<Object> get props => [?error];
}

final class SellingInitial extends PurchState {
  const SellingInitial({super.error});
  @override
  SellingInitial copyWithError(String error) {
    return SellingInitial(error: error);
  }
}

final class SellingStarted extends PurchState {
  final PurchaseInvoice invoice;
  const SellingStarted({required this.invoice, super.error});
  @override
  SellingStarted copyWithError(String error) {
    return SellingStarted(error: super.error, invoice: invoice);
  }

  @override
  List<Object> get props => [invoice];
}

final class SellUpdated extends PurchState {
  final PurchaseInvoice invoice;
  const SellUpdated({required this.invoice, super.error});
  @override
  SellUpdated copyWithError(String error) {
    return SellUpdated(error: super.error, invoice: invoice);
  }

  @override
  List<Object> get props => [invoice];
}

final class PrintInvoice extends PurchState {
  final PurchaseInvoice invoice;
  const PrintInvoice({required this.invoice, super.error});
  @override
  SellUpdated copyWithError(String error) {
    return SellUpdated(error: super.error, invoice: invoice);
  }

  @override
  List<Object> get props => [invoice];
}

final class SellFinished extends PurchState {
  const SellFinished({super.error});
  @override
  SellFinished copyWithError(String error) {
    return SellFinished(error: super.error);
  }
}

final class SellFialed extends PurchState {
  final String message;
  const SellFialed({required this.message, super.error});
  @override
  SellFialed copyWithError(String error) {
    return SellFialed(error: super.error, message: message);
  }

  @override
  List<Object> get props => [message];
}

final class Loading extends PurchState {
  @override
  SellingInitial copyWithError(String error) {
    return SellingInitial(error: super.error);
  }
}
