import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ponit_of_sales/services/custom_failures.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import 'package:ponit_of_sales/utils/pending_operation.dart';
part 'general_event.dart';
part 'general_state.dart';

class GeneralBloc<T> extends Bloc<GeneralEvent<T>, GeneralState<T>> {
  GeneralService<T> service;
  GeneralBloc(this.service) : super(GeneralLoadInProgress<T>()) {
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
    final service = event.tempService ?? this.service;
    try {
      final items = await service.fetchList();
      emit(ItemsLoadSuccess<T>(items));
    } on NetworkFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ شبكة
      emit(ItemLoadFailure('Offline: ${f.message}'));
    } on ServerFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ سيرفر
      emit(ItemLoadFailure('Server Down (Code ${f.statusCode}): حاول لاحقاً.'));
    } on ClientFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ عميل/منطق
      emit(
        ItemLoadFailure('Client Error (Code ${f.statusCode}): ${f.message}'),
      );
    } on SuccessResponse catch (e) {
      if (e.statusCode == 204) {
        emit(ItemsLoadSuccess<T>([]));
      } else {
        emit(
          ItemLoadFailure(
            'Success Response with unexpected status code: ${e.statusCode}',
          ),
        );
      }
    } catch (e) {
      emit(ItemLoadFailure(e.toString()));
    }
  }

  Future<void> _onLoadSinglItem(
    LoadSinglItem<T> event,
    Emitter<GeneralState<T>> emit,
  ) async {
    emit(GeneralLoadInProgress<T>());
    final service = event.tempService ?? this.service;
    try {
      final item = await service.fetchItem(event.itemId);
      emit(LoadSinglItemSuccess<T>(item));
    } on NetworkFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ شبكة
      emit(ItemLoadFailure('Offline: ${f.message}'));
    } on ServerFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ سيرفر
      emit(ItemLoadFailure('Server Down (Code ${f.statusCode}): حاول لاحقاً.'));
    } on ClientFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ عميل/منطق
      emit(
        ItemLoadFailure('Client Error (Code ${f.statusCode}): ${f.message}'),
      );
    } on SuccessResponse catch (e) {
      emit(
        ItemLoadFailure(
          'Success Response with unexpected status code: ${e.statusCode}',
        ),
      );
    } catch (e) {
      emit(ItemLoadFailure(e.toString()));
    }
  }

  Future<void> _onAddItem(
    AddItem<T> event,
    Emitter<GeneralState<T>> emit,
  ) async {
    emit(ItemOperationGoing());
    final service = event.tempService ?? this.service;
    try {
      final newItem = await service.create(event.item);
      emit(
        ItemOperationSuccess<T>(item: newItem, operation: OperationType.add),
      );
    } on NetworkFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ شبكة
      emit(ItemLoadFailure('Offline: ${f.message}'));
    } on ServerFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ سيرفر
      emit(ItemLoadFailure('Server Down (Code ${f.statusCode}): حاول لاحقاً.'));
    } on ClientFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ عميل/منطق
      emit(
        ItemLoadFailure('Client Error (Code ${f.statusCode}): ${f.message}'),
      );
    } on SuccessResponse catch (e) {
      emit(
        ItemLoadFailure(
          'Success Response with unexpected status code: ${e.statusCode}',
        ),
      );
    } catch (e) {
      emit(ItemLoadFailure(e.toString()));
    }
  }

  Future<void> _onUpdateItem(
    UpdateItem<T> event,
    Emitter<GeneralState<T>> emit,
  ) async {
    final service = event.tempService ?? this.service;
    emit(ItemOperationGoing());
    try {
      final updatedItem = await service.update(event.itemId, event.item);
      emit(
        ItemOperationSuccess<T>(
          item: updatedItem,
          operation: OperationType.update,
        ),
      );
    } on NetworkFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ شبكة
      emit(ItemLoadFailure('Offline: ${f.message}'));
    } on ServerFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ سيرفر
      emit(ItemLoadFailure('Server Down (Code ${f.statusCode}): حاول لاحقاً.'));
    } on ClientFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ عميل/منطق
      emit(
        ItemLoadFailure('Client Error (Code ${f.statusCode}): ${f.message}'),
      );
    } on SuccessResponse catch (e) {
      emit(
        ItemLoadFailure(
          'Success Response with unexpected status code: ${e.statusCode}',
        ),
      );
    } catch (e) {
      emit(ItemLoadFailure(e.toString()));
    }
  }

  Future<void> _onPartialUpdateItem(
    PartialUpdateItem<T> event,
    Emitter<GeneralState<T>> emit,
  ) async {
    final service = event.tempService ?? this.service;
    emit(ItemOperationGoing<T>());
    try {
      final updatedItem = await service.patch(event.itemId, event.changes);
      emit(
        ItemOperationSuccess<T>(
          item: updatedItem,
          operation: OperationType.partiallyUpdate,
        ),
      );
    } on NetworkFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ شبكة
      emit(ItemLoadFailure('Offline: ${f.message}'));
    } on ServerFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ سيرفر
      emit(ItemLoadFailure('Server Down (Code ${f.statusCode}): حاول لاحقاً.'));
    } on ClientFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ عميل/منطق
      emit(
        ItemLoadFailure('Client Error (Code ${f.statusCode}): ${f.message}'),
      );
    } on SuccessResponse catch (e) {
      emit(
        ItemLoadFailure(
          'Success Response with unexpected status code: ${e.statusCode}',
        ),
      );
    } catch (e) {
      emit(ItemLoadFailure(e.toString()));
    }
  }

  Future<void> _onDeleteItem(
    DeleteItem<T> event,
    Emitter<GeneralState<T>> emit,
  ) async {
    emit(ItemOperationGoing<T>());
    final service = event.tempService ?? this.service;
    try {
      await service.delete(event.itemId);
      emit(
        ItemOperationSuccess<T>(item: null, operation: OperationType.delete),
      );
    } on NetworkFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ شبكة
      emit(ItemLoadFailure('Offline: ${f.message}'));
    } on ServerFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ سيرفر
      emit(ItemLoadFailure('Server Down (Code ${f.statusCode}): حاول لاحقاً.'));
    } on ClientFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ عميل/منطق
      emit(
        ItemLoadFailure('Client Error (Code ${f.statusCode}): ${f.message}'),
      );
    } on SuccessResponse catch (e) {
      if (e.statusCode == 204) {
        emit(
          ItemOperationSuccess<T>(item: null, operation: OperationType.delete),
        );
      } else {
        emit(
          ItemLoadFailure(
            'Success Response with unexpected status code: ${e.statusCode}',
          ),
        );
      }
    } catch (e) {
      emit(ItemLoadFailure(e.toString()));
    }
  }
}
