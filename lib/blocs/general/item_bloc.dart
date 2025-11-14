// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ponit_of_sales/services/custom_failures.dart';
// import 'package:ponit_of_sales/services/general_services.dart';
// import 'package:ponit_of_sales/utils/pending_operation.dart';

// part 'item_event.dart';
// part 'item_state.dart';

// class ItemBloc<T> extends Bloc<ItemEvent<T>, ItemState<T>> {
//   GeneralService<T> service;

//   ItemBloc(this.service) : super(ItemInitial<T>()) {
//     on<LoadItem<T>>(_onLoadItem);
//     on<AddItem<T>>(_onAddItem);
//     on<UpdateItem<T>>(_onUpdateItem);
//     on<DeleteItem<T>>(_onDeleteItem);
//     on<PartialUpdateItem<T>>(_onPartialUpdateItem);
//   }

//   Future<void> _onLoadItem(
//     LoadItem<T> event,
//     Emitter<ItemState<T>> emit,
//   ) async {
//     emit(ItemOperationInProgress<T>());
//     final service = event.tempService ?? this.service;
//     try {
//       final item = await service.fetchItem(event.itemId);
//       emit(ItemLoadSuccess<T>(item));
//     } on NetworkFailure catch (f) {
//       emit(ItemOperationFailure('Offline: ${f.message}'));
//     } on ServerFailure catch (f) {
//       emit(
//         ItemOperationFailure(
//           'Server Down (Code ${f.statusCode}): حاول لاحقاً.',
//         ),
//       );
//     } on ClientFailure catch (f) {
//       emit(
//         ItemOperationFailure(
//           'Client Error (Code ${f.statusCode}): ${f.message}',
//         ),
//       );
//     } on SuccessResponse catch (e) {
//       emit(
//         ItemOperationFailure(
//           'Success Response with unexpected status code: ${e.statusCode}',
//         ),
//       );
//     } catch (e) {
//       emit(ItemOperationFailure(e.toString()));
//     }
//   }

//   Future<void> _onAddItem(AddItem<T> event, Emitter<ItemState<T>> emit) async {
//     emit(ItemOperationInProgress());
//     final service = event.tempService ?? this.service;
//     try {
//       final newItem = await service.create(event.item);
//       emit(
//         ItemOperationSuccess<T>(item: newItem, operation: OperationType.add),
//       );
//     } on NetworkFailure catch (f) {
//       emit(ItemOperationFailure('Offline: ${f.message}'));
//     } on ServerFailure catch (f) {
//       emit(
//         ItemOperationFailure(
//           'Server Down (Code ${f.statusCode}): حاول لاحقاً.',
//         ),
//       );
//     } on ClientFailure catch (f) {
//       emit(
//         ItemOperationFailure(
//           'Client Error (Code ${f.statusCode}): ${f.message}',
//         ),
//       );
//     } catch (e) {
//       emit(ItemOperationFailure(e.toString()));
//     }
//   }

//   Future<void> _onUpdateItem(
//     UpdateItem<T> event,
//     Emitter<ItemState<T>> emit,
//   ) async {
//     final service = event.tempService ?? this.service;
//     emit(ItemOperationInProgress());
//     try {
//       final updatedItem = await service.update(event.itemId, event.item);
//       emit(
//         ItemOperationSuccess<T>(
//           item: updatedItem,
//           operation: OperationType.update,
//         ),
//       );
//     } on NetworkFailure catch (f) {
//       emit(ItemOperationFailure('Offline: ${f.message}'));
//     } on ServerFailure catch (f) {
//       emit(
//         ItemOperationFailure(
//           'Server Down (Code ${f.statusCode}): حاول لاحقاً.',
//         ),
//       );
//     } on ClientFailure catch (f) {
//       emit(
//         ItemOperationFailure(
//           'Client Error (Code ${f.statusCode}): ${f.message}',
//         ),
//       );
//     } catch (e) {
//       emit(ItemOperationFailure(e.toString()));
//     }
//   }

//   Future<void> _onPartialUpdateItem(
//     PartialUpdateItem<T> event,
//     Emitter<ItemState<T>> emit,
//   ) async {
//     final service = event.tempService ?? this.service;
//     emit(ItemOperationInProgress<T>());
//     try {
//       final updatedItem = await service.patch(event.itemId, event.changes);
//       emit(
//         ItemOperationSuccess<T>(
//           item: updatedItem,
//           operation: OperationType.partiallyUpdate,
//         ),
//       );
//     } on NetworkFailure catch (f) {
//       emit(ItemOperationFailure('Offline: ${f.message}'));
//     } on ServerFailure catch (f) {
//       emit(
//         ItemOperationFailure(
//           'Server Down (Code ${f.statusCode}): حاول لاحقاً.',
//         ),
//       );
//     } on ClientFailure catch (f) {
//       emit(
//         ItemOperationFailure(
//           'Client Error (Code ${f.statusCode}): ${f.message}',
//         ),
//       );
//     } catch (e) {
//       emit(ItemOperationFailure(e.toString()));
//     }
//   }

//   Future<void> _onDeleteItem(
//     DeleteItem<T> event,
//     Emitter<ItemState<T>> emit,
//   ) async {
//     emit(ItemOperationInProgress<T>());
//     final service = event.tempService ?? this.service;
//     try {
//       await service.delete(event.itemId);
//       emit(ItemOperationSuccess<T>(operation: OperationType.delete));
//     } on NetworkFailure catch (f) {
//       emit(ItemOperationFailure('Offline: ${f.message}'));
//     } on ServerFailure catch (f) {
//       emit(
//         ItemOperationFailure(
//           'Server Down (Code ${f.statusCode}): حاول لاحقاً.',
//         ),
//       );
//     } on ClientFailure catch (f) {
//       emit(
//         ItemOperationFailure(
//           'Client Error (Code ${f.statusCode}): ${f.message}',
//         ),
//       );
//     } on SuccessResponse catch (e) {
//       if (e.statusCode == 204) {
//         emit(ItemOperationSuccess<T>(operation: OperationType.delete));
//       } else {
//         emit(
//           ItemOperationFailure(
//             'Success Response with unexpected status code: ${e.statusCode}',
//           ),
//         );
//       }
//     } catch (e) {
//       emit(ItemOperationFailure(e.toString()));
//     }
//   }
// }
