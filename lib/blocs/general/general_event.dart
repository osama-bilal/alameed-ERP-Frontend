part of 'general_bloc.dart';

sealed class GeneralEvent extends Equatable {
  final GeneralService service;
  const GeneralEvent(this.service);

  @override
  List<Object> get props => [service];
}

class LoadItems extends GeneralEvent {
  const LoadItems(super.service);
}

class LoadItem<T> extends GeneralEvent {
  final int itemId;

  const LoadItem(super.service,this.itemId);

  @override
  List<Object> get props => [itemId, service];
}

class AddItem<T> extends GeneralEvent {
  final T invoice;

  const AddItem(super.service,this.invoice);

  @override
  List<Object> get props => [?invoice, service];
}

class UpdateItem<T> extends GeneralEvent {
  final T item;
  final int itemId;

  const UpdateItem(super.service ,this.item, this.itemId);

  @override
  List<Object> get props => [?item, itemId, service];
}

class DeleteItem extends GeneralEvent {
  final int itemId;

  const DeleteItem(super.service ,this.itemId);

  @override
  List<Object> get props => [itemId, service];
}
