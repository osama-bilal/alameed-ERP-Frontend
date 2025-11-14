import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/services/general_services.dart';

part 'return_event.dart';
part 'return_state.dart';

class ReturnBloc extends Bloc<ReturnEvent, ReturnState> {
  final GeneralService<ReturnSale> _returnService =
      AppService.returnSaleService;
  final GeneralService<SaleInvoice> _invoiceService =
      AppService.saleInvoiceService;
  ReturnBloc() : super(ReturnInitial()) {
    on<ProcessReturn>(_onProcessReturn);
    on<StartReturn>(_startReturn);
    on<StartReplace>(_startReplace);
    on<CancelReturn>(_onCancelReturn);
    on<ReturnMoney>(_returnMoney);
    on<AddReturn>(_onAddReturn);
  }

  Future<void> _startReturn(
    StartReturn event,
    Emitter<ReturnState> emit,
  ) async {
    final service = _invoiceService.copy();
    service.endpoint =
        "${AppUrls.saleInvoiceUrl}by-return-code/${event.returnCode}/";
    emit(ReturnLoading());
    try {
      final invoice = await service.fetchItem(null);
      emit(ReturnStarted(invoice: invoice));
    } catch (e) {
      emit(ReturnFailure(message: e.toString()));
      emit(ReturnFinished());
    }
  }

  Future<void> _onCancelReturn(
    CancelReturn event,
    Emitter<ReturnState> emit,
  ) async {
    emit(ReturnFinished());
  }

  Future<void> _onAddReturn(AddReturn event, Emitter<ReturnState> emit) async {
    emit(ReturnLoading());
    try {
      final item = await _returnService.create(event.item);
      emit(ReturnSuccess(items: [item]));
    } catch (e) {
      emit(ReturnFailure(message: e.toString()));
    }
  }

  Future<void> _startReplace(
    StartReplace event,
    Emitter<ReturnState> emit,
  ) async {
    emit(ReturnLoading());
    List<ReturnSale> items = [];

    for (var i in event.itemsReturned) {
      try {
        final item = await _returnService.create(i);
        items.add(item);
      } on Exception catch (e) {
        emit(ReturnFailure(message: e.toString()));
        break;
      }
    }
    if (items.length == event.itemsReturned.length) {
      try {
        final replaceInvoice = await _invoiceService.create(
          SaleInvoice(exchangeWith: event.oldInvoice.id),
        );
        emit(ReplaceStarted(invoice: replaceInvoice));
      } on Exception catch (e) {
        emit(ReturnFailure(message: e.toString()));
      }
    } else {
      emit(ReturnFailure(message: 'Something went wrong'));
    }
  }

  Future<void> _returnMoney(
    ReturnMoney event,
    Emitter<ReturnState> emit,
  ) async {
    emit(ReturnLoading());
    List<ReturnSale> items = [];

    for (var i in event.items) {
      try {
        final item = await _returnService.create(i);
        items.add(item);
      } on Exception catch (e) {
        emit(ReturnFailure(message: e.toString()));
        break;
      }
    }
    if (items.length == event.items.length) {
      emit(ReturnSuccess(items: items));
    } else {
      emit(ReturnFailure(message: 'Something went wrong'));
    }
  }

  Future<void> _onProcessReturn(
    ProcessReturn event,
    Emitter<ReturnState> emit,
  ) async {
    emit(ReturnLoading());
    try {
      // await _returnRepository.processSaleReturn(state.invoice!);
      // emit(ReturnSuccess(invoice: state.invoice!));
    } catch (e) {
      emit(ReturnFailure(message: e.toString()));
    }
  }
}
