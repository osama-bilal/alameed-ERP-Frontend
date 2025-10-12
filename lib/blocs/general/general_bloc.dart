import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
part 'general_event.dart';
part 'general_state.dart';

class GeneralBloc<T> extends Bloc<GeneralEvent<T>, GeneralState<T>> {
  GeneralBloc() : super(GeneralLoadInProgress<T>()) {
    on<LoadItems<T>>(_onLoadItems);
    on<LoadSinglItem<T>>(_onLoadSinglItem);
    on<AddItem<T>>(_onAddItem);
    on<UpdateItem<T>>(_onUpdateItem);
    on<DeleteItem<T>>(_onDeleteItem);
    on<PartialUpdateItem<T>>(_onPartialUpdateItem);
  }

  Future<void> _onLoadItems(
    LoadItems<T> event,
    Emitter<GeneralState<T>> emit,
  ) async {
    emit(GeneralLoadInProgress<T>());
    try {
      final items = await event.service.fetchList();
      emit(ItemsLoadSuccess<T>(items));
    } on DioException catch (e) {
      emit(ItemLoadFailure<T>(e.toString()));
    }
  }

  Future<void> _onLoadSinglItem(
    LoadSinglItem<T> event,
    Emitter<GeneralState<T>> emit,
  ) async {
    emit(GeneralLoadInProgress<T>());
    try {
      final item = await event.service.fetchItem(event.itemId);
      emit(LoadSinglItemSuccess<T>(item));
    } on DioException catch (e) {
      emit(ItemLoadFailure<T>(e.toString()));
    }
  }

  Future<void> _onAddItem(AddItem<T> event, Emitter<GeneralState<T>> emit) async {
    emit(ItemOperationGoing());
    try {
      final newItem = await event.service.create(event.item);
      emit(
        ItemOperationSuccess<T>(item: newItem, operation: OperationType.add),
      );
    } on DioException catch (e) {
      emit(ItemLoadFailure<T>(e.toString()));
    }
  }

  Future<void> _onUpdateItem(
    UpdateItem<T> event,
    Emitter<GeneralState<T>> emit,
  ) async {
    emit(ItemOperationGoing());
    try {
      final updatedItem = await event.service.update(event.itemId, event.item);
      emit(
        ItemOperationSuccess<T>(
          item: updatedItem,
          operation: OperationType.update,
        ),
      );
    } on DioException catch (e) {
      emit(ItemLoadFailure<T>(e.toString()));
    }
  }

  Future<void> _onPartialUpdateItem(
    PartialUpdateItem<T> event,
    Emitter<GeneralState<T>> emit,
  ) async {
    emit(ItemOperationGoing<T>());
    try {
      final updatedItem = await event.service.patch(
        event.itemId,
        event.changes,
      );
      emit(
        ItemOperationSuccess<T>(
          item: updatedItem,
          operation: OperationType.partiallyUpdate,
        ),
      );
    } on DioException catch (e) {
      emit(ItemLoadFailure<T>(e.toString()));
    }
  }

  Future<void> _onDeleteItem(
    DeleteItem<T> event,
    Emitter<GeneralState<T>> emit,
  ) async {
    emit(ItemOperationGoing<T>());
    try {
      await event.service.delete(event.itemId);
      emit(
        ItemOperationSuccess<T>(item: null, operation: OperationType.delete),
      );
    } on DioException catch (e) {
      emit(ItemLoadFailure<T>(e.toString()));
    }
  }
}
