import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/services/custom_failures.dart';
import 'package:ponit_of_sales/services/general_services.dart';

part 'list_event.dart';
part 'list_state.dart';

class ListBloc<T> extends Bloc<ListEvent<T>, ListState<T>> {
  GeneralService<T> service;

  ListBloc(this.service) : super(ListLoadInProgress<T>()) {
    on<LoadList<T>>(_onLoadList);
  }

  Future<void> _onLoadList(
    LoadList<T> event,
    Emitter<ListState<T>> emit,
  ) async {
    emit(ListLoadInProgress<T>());
    final service = event.tempService ?? this.service;
    try {
      final items = await service.fetchList();
      emit(ListLoadSuccess<T>(items));
    } on NetworkFailure catch (f) {
      emit(ListLoadFailure('Offline: ${f.message}'));
    } on ServerFailure catch (f) {
      emit(ListLoadFailure('Server Down (Code ${f.statusCode}): حاول لاحقاً.'));
    } on ClientFailure catch (f) {
      emit(
        ListLoadFailure('Client Error (Code ${f.statusCode}): ${f.message}'),
      );
    } on SuccessResponse catch (e) {
      if (e.statusCode == 204) {
        emit(ListLoadSuccess<T>([]));
      } else {
        emit(
          ListLoadFailure(
            'Success Response with unexpected status code: ${e.statusCode}',
          ),
        );
      }
    } catch (e) {
      emit(ListLoadFailure(e.toString()));
    }
  }
}
