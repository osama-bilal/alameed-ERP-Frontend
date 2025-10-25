part of 'item_bloc.dart';

sealed class ItemState<T> extends Equatable {
  const ItemState();

  @override
  List<Object?> get props => [];
}

final class ItemInitial<T> extends ItemState<T> {}

final class ItemOperationInProgress<T> extends ItemState<T> {}

final class ItemLoadSuccess<T> extends ItemState<T> {
  final T item;

  const ItemLoadSuccess(this.item);

  @override
  List<Object?> get props => [item];
}

final class ItemOperationSuccess<T> extends ItemState<T> {
  final T? item;
  final OperationType operation;
  const ItemOperationSuccess({this.item, required this.operation});

  @override
  List<Object?> get props => [item, operation];
}

final class ItemOperationFailure<T> extends ItemState<T> {
  final String error;

  const ItemOperationFailure(this.error);

  @override
  List<Object?> get props => [error];
}
