part of 'general_bloc.dart';

sealed class GeneralState extends Equatable {
  const GeneralState();

  @override
  List<Object> get props => [];
}

final class GeneralLoadInProgress<T> extends GeneralState {}

final class LoadItemSuccess<T> extends GeneralState {
  final T item;

  const LoadItemSuccess(this.item);

  @override
  List<Object> get props => [?item];
}

final class ItemsLoadSuccess<T> extends GeneralState {
  final List<T> items;

  const ItemsLoadSuccess(this.items);

  @override
  List<Object> get props => [items];
}

final class ItemLoadFailure<T> extends GeneralState {
  final String error;

  const ItemLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}

final class ItemOperationSuccess<T> extends GeneralState {
  final T item;

  const ItemOperationSuccess(this.item);

  @override
  List<Object> get props => [?item];
}
