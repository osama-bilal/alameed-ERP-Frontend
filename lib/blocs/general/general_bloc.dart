import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ponit_of_sales/services/general_services.dart';
part 'general_event.dart';
part 'general_state.dart';

class GeneralBloc<T> extends Bloc<GeneralEvent, GeneralState> {
  // final GeneralService service;
  GeneralBloc() : super(GeneralLoadInProgress()) {
    on<LoadItems>(_onLoadItems);
    on<LoadItem<T>>(_onLoadItem);
    on<AddItem<T>>(_onAddItem);
    on<UpdateItem<T>>(_onUpdateItem);
    on<DeleteItem>(_onDeleteItem);
  }

  Future<void> _onLoadItems(LoadItems event, Emitter<GeneralState> emit) async {
    emit(GeneralLoadInProgress());
    try {
      final invoices = await event.service.fetchList() as List<T>;
      emit(ItemsLoadSuccess<T>(invoices));
    } catch (e) {
      emit(ItemLoadFailure(e.toString()));
    }
  }

  Future<void> _onLoadItem(LoadItem event, Emitter<GeneralState> emit) async {
    emit(GeneralLoadInProgress());
    try {
      final item = await event.service.fetchItem(event.itemId) as T;
      emit(LoadItemSuccess<T>(item));
    } catch (e) {
      emit(ItemLoadFailure(e.toString()));
    }
  }

  Future<void> _onAddItem(AddItem event, Emitter<GeneralState> emit) async {
    try {
      final newItem = await event.service.create(event.invoice as T) as T;
      emit(ItemOperationSuccess<T>(newItem));
    } catch (e) {
      emit(ItemLoadFailure(e.toString()));
    }
  }

  Future<void> _onUpdateItem(
    UpdateItem event,
    Emitter<GeneralState> emit,
  ) async {
    try {
      final updatedItem = await event.service.update(event.itemId, event.item as T) as T;
      emit(ItemOperationSuccess<T>(updatedItem));
    } catch (e) {
      emit(ItemLoadFailure(e.toString()));
    }
  }

  Future<void> _onDeleteItem(
    DeleteItem event,
    Emitter<GeneralState> emit,
  ) async {
    try {
      await event.service.delete(event.itemId);
      add(LoadItems(event.service));
    } catch (e) {
      emit(ItemLoadFailure(e.toString()));
    }
  }
}
