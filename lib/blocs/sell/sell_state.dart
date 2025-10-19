part of 'sell_bloc.dart';

sealed class SellingState extends Equatable {
  final String? error;
  const SellingState({this.error});
  SellingState copyWithError(String error);
  @override
  List<Object> get props => [?error];
}

final class SellingInitial extends SellingState {
  const SellingInitial({super.error});
  @override
  SellingInitial copyWithError(String error) {
    return SellingInitial(error: error);
  }
}

final class SellingStarted extends SellingState {
  final SaleInvoice invoice;
  const SellingStarted({required this.invoice, super.error});
  @override
  SellingStarted copyWithError(String error) {
    return SellingStarted(error: super.error, invoice: invoice);
  }

  @override
  List<Object> get props => [invoice];
}

final class SellUpdated extends SellingState {
  final SaleInvoice invoice;
  const SellUpdated({required this.invoice, super.error});
  @override
  SellUpdated copyWithError(String error) {
    return SellUpdated(error: super.error, invoice: invoice);
  }

  @override
  List<Object> get props => [invoice];
}

final class PrintInvoice extends SellingState {
  final SaleInvoice invoice;
  const PrintInvoice({required this.invoice, super.error});
  @override
  SellUpdated copyWithError(String error) {
    return SellUpdated(error: super.error, invoice: invoice);
  }

  @override
  List<Object> get props => [invoice];
}

final class SellFinished extends SellingState {
  const SellFinished({super.error});
  @override
  SellFinished copyWithError(String error) {
    return SellFinished(error: super.error);
  }
}

final class SellFialed extends SellingState {
  final String message;
  const SellFialed({required this.message, super.error});
  @override
  SellFialed copyWithError(String error) {
    return SellFialed(error: super.error, message: message);
  }

  @override
  List<Object> get props => [message];
}

final class Loading extends SellingState {
  @override
  SellingInitial copyWithError(String error) {
    return SellingInitial(error: super.error);
  }
}
