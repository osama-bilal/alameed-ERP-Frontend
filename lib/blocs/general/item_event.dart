// part of 'item_bloc.dart';

// sealed class ItemEvent<T> extends Equatable {
//   final GeneralService<T>? tempService;
//   const ItemEvent({this.tempService});

//   @override
//   List<Object?> get props => [tempService];
// }

// class LoadItem<T> extends ItemEvent<T> {
//   final int? itemId;

//   const LoadItem({this.itemId, super.tempService});

//   @override
//   List<Object?> get props => [itemId, tempService];
// }

// class AddItem<T> extends ItemEvent<T> {
//   final T item;

//   const AddItem(this.item, {super.tempService});

//   @override
//   List<Object?> get props => [item, tempService];
// }

// class UpdateItem<T> extends ItemEvent<T> {
//   final T item;
//   final int itemId;

//   const UpdateItem({
//     required this.item,
//     required this.itemId,
//     super.tempService,
//   });

//   @override
//   List<Object?> get props => [item, itemId, tempService];
// }

// class PartialUpdateItem<T> extends ItemEvent<T> {
//   final Map<String, dynamic> changes;
//   final int itemId;

//   const PartialUpdateItem({
//     required this.changes,
//     required this.itemId,
//     super.tempService,
//   });

//   @override
//   List<Object?> get props => [changes, itemId, tempService];
// }

// class DeleteItem<T> extends ItemEvent<T> {
//   final int itemId;

//   const DeleteItem(this.itemId, {super.tempService});

//   @override
//   List<Object?> get props => [itemId, tempService];
// }
