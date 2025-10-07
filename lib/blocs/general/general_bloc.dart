import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
part 'general_event.dart';
part 'general_state.dart';

class GeneralBloc<T> extends Bloc<GeneralEvent, GeneralState> {
  GeneralBloc() : super(GeneralLoadInProgress<T>()) {
    on<LoadItems<T>>(_onLoadItems);
    on<LoadSinglItem<T>>(_onLoadItem);
    on<AddItem<T>>(_onAddItem);
    on<UpdateItem<T>>(_onUpdateItem);
    on<DeleteItem>(_onDeleteItem);
    on<PartialUpdateItem<T>>(_onPartialUpdateItem);
  }

  Future<void> _onLoadItems(LoadItems event, Emitter<GeneralState> emit) async {
    emit(GeneralLoadInProgress<T>());
    try {
      final items = await event.service.fetchList() as List<T>;
      emit(ItemsLoadSuccess<T>(items));
    } catch (e) {
      emit(ItemLoadFailure<T>(e.toString()));
    }
  }

  Future<void> _onLoadItem(
    LoadSinglItem event,
    Emitter<GeneralState> emit,
  ) async {
    emit(GeneralLoadInProgress<T>());
    try {
      final item = await event.service.fetchItem(event.itemId) as T;
      emit(LoadSinglItemSuccess<T>(item));
    } catch (e) {
      emit(ItemLoadFailure<T>(e.toString()));
    }
  }

  Future<void> _onAddItem(AddItem event, Emitter<GeneralState> emit) async {
    emit(ItemOperationGoing());
    try {
      final newItem = await event.service.create(event.item) as T;
      emit(ItemOperationSuccess<T>(newItem, OperationType.add));
    } catch (e) {
      emit(ItemLoadFailure<T>(e.toString()));
    }
  }

  Future<void> _onUpdateItem(
    UpdateItem event,
    Emitter<GeneralState> emit,
  ) async {
    emit(ItemOperationGoing());
    try {
      final updatedItem =
          await event.service.update(event.itemId, event.item) as T;
      emit(ItemOperationSuccess<T>(updatedItem, OperationType.update));
    } catch (e) {
      emit(ItemLoadFailure<T>(e.toString()));
    }
  }

  Future<void> _onPartialUpdateItem(
    PartialUpdateItem event,
    Emitter<GeneralState> emit,
  ) async {
    emit(ItemOperationGoing<T>());
    try {
      // Assumes the service exposes a `partialUpdate` (or similar) method.
      // Adjust the method name if your service uses a different one (e.g. `patch`).
      final updatedItem =
          await event.service.patch(event.itemId, event.changes) as T;
      emit(ItemOperationSuccess<T>(updatedItem, OperationType.update));
    } catch (e) {
      emit(ItemLoadFailure<T>(e.toString()));
    }
  }

  Future<void> _onDeleteItem(
    DeleteItem event,
    Emitter<GeneralState> emit,
  ) async {
    emit(ItemOperationGoing<T>());
    try {
      await event.service.delete(event.itemId);
      emit(ItemOperationSuccess(null, OperationType.delete));
    } catch (e) {
      emit(ItemLoadFailure<T>(e.toString()));
    }
  }
}
