part of 'general_bloc.dart';

sealed class GeneralEvent<T> extends Equatable {
  final GeneralService<T> service;
  const GeneralEvent(this.service);

  @override
  List<Object> get props => [service];
}

class LoadItems<T> extends GeneralEvent {
  const LoadItems(super.service);
}

class LoadSinglItem<T> extends GeneralEvent {
  final int? itemId;

  const LoadSinglItem(super.service, {this.itemId});

  @override
  List<Object> get props => [?itemId, service];
}

class AddItem<T> extends GeneralEvent {
  final T item;

  const AddItem(super.service, this.item);

  @override
  List<Object> get props => [?item, service];
}

class UpdateItem<T> extends GeneralEvent {
  final T item;
  final int itemId;

  const UpdateItem(super.service, this.item, this.itemId);

  @override
  List<Object> get props => [?item, itemId, service];
}

class PartialUpdateItem<T> extends GeneralEvent {
  final Map<String, dynamic> changes;
  final int itemId;

  const PartialUpdateItem(super.service, this.changes, this.itemId);

  @override
  List<Object> get props => [changes, itemId, service];
}

class DeleteItem extends GeneralEvent {
  final int itemId;

  const DeleteItem(super.service, this.itemId);

  @override
  List<Object> get props => [itemId, service];
}
