part of 'return_bloc.dart';

sealed class ReturnPurchState extends Equatable {
  const ReturnPurchState();

  @override
  List<Object?> get props => [];
}

final class ReturnInitial extends ReturnPurchState {
  const ReturnInitial();
}

class ReturnLoading extends ReturnPurchState {
  const ReturnLoading();
}

class ReturnStarted extends ReturnPurchState {
  final PurchaseInvoice invoice;
  const ReturnStarted({required this.invoice});
}

class ReplaceStarted extends ReturnPurchState {
  final PurchaseInvoice invoice;
  const ReplaceStarted({required this.invoice});
}

class ReturnSuccess extends ReturnPurchState {
  final List<ReturnPurchase> items;
  const ReturnSuccess({required this.items});
}

class ReturnFinished extends ReturnPurchState {
  const ReturnFinished();
}

class ReturnFailure extends ReturnPurchState {
  final String message;
  const ReturnFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
