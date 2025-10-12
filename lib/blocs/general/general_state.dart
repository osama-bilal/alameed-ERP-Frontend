part of 'general_bloc.dart';

sealed class GeneralState<T> extends Equatable {
  const GeneralState();

  @override
  List<Object> get props => [];
}

final class GeneralLoadInProgress<T> extends GeneralState<T> {}

final class ItemOperationGoing<T> extends GeneralState<T> {}

final class LoadSinglItemSuccess<T> extends GeneralState<T> {
  final T item;

  const LoadSinglItemSuccess(this.item);

  @override
  List<Object> get props => [?item];
}

final class ItemsLoadSuccess<T> extends GeneralState<T> {
  final List<T> items;

  const ItemsLoadSuccess(this.items);

  @override
  List<Object> get props => [items];
}

final class ItemLoadFailure<T> extends GeneralState<T> {
  final String error;

  const ItemLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}

final class ItemOperationSuccess<T> extends GeneralState<T> {
  final T? item;
  final OperationType operation;
  const ItemOperationSuccess({required this.item, required this.operation});

  @override
  List<Object> get props => [?item, operation];
}
