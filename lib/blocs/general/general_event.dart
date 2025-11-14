part of 'general_bloc.dart';

sealed class GeneralEvent<T> extends Equatable {
  final String? tempPoint;
  const GeneralEvent({this.tempPoint});

  @override
  List<Object> get props => [?tempPoint];
}

class LoadItems<T> extends GeneralEvent<T> {
  const LoadItems({super.tempPoint});
}

class LoadSinglItem<T> extends GeneralEvent<T> {
  final int? itemId;

  const LoadSinglItem({this.itemId, super.tempPoint});

  @override
  List<Object> get props => [?itemId];
}

class AddItem<T> extends GeneralEvent<T> {
  final T item;

  const AddItem(this.item, {super.tempPoint});

  @override
  List<Object> get props => [?item];
}

class UpdateItem<T> extends GeneralEvent<T> {
  final T item;
  final int itemId;

  const UpdateItem({required this.item, required this.itemId, super.tempPoint});

  @override
  List<Object> get props => [?item, itemId];
}

class PartialUpdateItem<T> extends GeneralEvent<T> {
  final Map<String, dynamic> changes;
  final int itemId;

  const PartialUpdateItem({
    required this.changes,
    required this.itemId,
    super.tempPoint,
  });

  @override
  List<Object> get props => [changes, itemId];
}

class DeleteItem<T> extends GeneralEvent<T> {
  final int itemId;

  const DeleteItem(this.itemId, {super.tempPoint});

  @override
  List<Object> get props => [itemId];
}
