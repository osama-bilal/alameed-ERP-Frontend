part of 'return_bloc.dart';

sealed class ReturnState extends Equatable {
  const ReturnState();

  @override
  List<Object?> get props => [];
}

final class ReturnInitial extends ReturnState {
  const ReturnInitial();
}

class ReturnLoading extends ReturnState {
  const ReturnLoading();
}

class ReturnStarted extends ReturnState {
  final SaleInvoice invoice;
  const ReturnStarted({required this.invoice});
}

class ReplaceStarted extends ReturnState {
  final SaleInvoice invoice;
  const ReplaceStarted({required this.invoice});
}

class ReturnSuccess extends ReturnState {
  final List<ReturnSale> items;
  const ReturnSuccess({required this.items});
}

class ReturnFinished extends ReturnState {
  const ReturnFinished();
}

class ReturnFailure extends ReturnState {
  final String message;
  const ReturnFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
