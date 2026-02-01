import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '/core/main.dart';
import '/models/invoices/purchase.dart';
import '/services/api_client.dart';
import '/services/custom_failures.dart';
import '/services/general_services.dart';
import '/utils/clean_null.dart';

part 'sell_event.dart';
part 'sell_state.dart';

class PurchBloc extends Bloc<PurchEvent, PurchState> {
  final GeneralService<PurchaseInvoice> invoiceService =
      AppService.purchaseInvoiceService;
  PurchBloc() : super(SellingInitial()) {
    on<StartSell>(_start);
    on<ConfirmSell>(_confirm);
    on<RefreshInvoice>(_refresh);
    on<PrintFinished>((event, emit) => emit(SellFinished()));
  }

  Future<void> _start(StartSell event, Emitter<PurchState> emit) async {
    final invoice = event.invoiceSell;
    if ((invoice.id ?? 0) > 0) {
      emit(Loading());
      final api = ApiClient();
      try {
        final response = await api.dio.post(
          "${AppUrls.purchaseInvoiceUrl}${invoice.id}/finalize/",
        );
        if (response.data['status'] == "تم اعتماد الفاتورة") {
          add(RefreshInvoice(id: invoice.id!));
        }
        return;
      } catch (e) {
        emit(state.copyWithError(e.toString()));
      }
    } else {
      emit(SellFialed(message: "Must connect to the server first."));
    }
  }

  Future<void> _confirm(ConfirmSell event, Emitter<PurchState> emit) async {
    final action = event.action;
    final invoice = event.invoice;
    if (invoice == null) {
      emit(SellFinished());
      return;
    }
    if (invoice.status != 'final') {
      emit(SellFinished());
      return;
    }
    final api = ApiClient();

    emit(Loading());
    if (action == 'cancel') {
      try {
        final response = await api.dio.post(
          "${AppUrls.purchaseInvoiceUrl}${invoice.id}/cancel/",
        );
        if (response.data['status'] != null) {
          emit(SellFinished());
        }
      } catch (e) {
        emit(SellUpdated(invoice: invoice).copyWithError(e.toString()));
      }
    } else {
      try {
        final updated = await invoiceService.patch(
          invoice.id!,
          cleanNullData(invoice.toMap()),
        );
        if (action == 'pay') {
          var amount = event.invoice!.paid;
          if (amount == null) return;
          if (amount == "") {
            amount = "0.00";
          }
          final response = await api.dio.post(
            "${AppUrls.purchaseInvoiceUrl}${updated.id}/mark_paid/",
            data: <String, dynamic>{"paid": amount},
          );
          if (response.data['status'] != null) {
            final paidInvoice = await invoiceService.fetchItem(invoice.id);
            if (['paid', 'partially_paid'].contains(paidInvoice.status)) {
              emit(PrintInvoice(invoice: paidInvoice));
            } else {
              emit(
                SellUpdated(
                  invoice: paidInvoice,
                  error: "The pay process didn't Done.",
                ),
              );
            }
          }
        } else if (action == 'unpaid') {
          final response = await api.dio.post(
            "${AppUrls.purchaseInvoiceUrl}${updated.id}/mark_unpaid/",
          );
          if (response.data['status'] != null) {
            final paidInvoice = await invoiceService.fetchItem(updated.id);
            if ("unpaid" == paidInvoice.status) {
              emit(PrintInvoice(invoice: paidInvoice));
            }
          }
        }
      } on NetworkFailure {
        // 🚨 هنا تم التفريق: خطأ شبكة
        emit(
          SellUpdated(invoice: invoice, error: "Cannot connect to internet"),
        );
      } on ServerFailure catch (f) {
        // 🚨 هنا تم التفريق: خطأ سيرفر
        log(f.toString());
        emit(
          SellUpdated(
            invoice: invoice,
            error:
                'Server Down (Code ${f.statusCode}):  contact with app developer.',
          ),
        );
      } on ClientFailure catch (f) {
        // 🚨 هنا تم التفريق: خطأ عميل/منطق
        emit(
          SellUpdated(
            invoice: invoice,
            error: 'Client Error (Code ${f.statusCode}): ${f.message}',
          ),
        );
      } catch (e) {
        emit(SellUpdated(invoice: invoice).copyWithError(e.toString()));
      }
    }
  }

  Future<void> _refresh(RefreshInvoice event, Emitter<PurchState> emit) async {
    final state = this.state;
    emit(Loading());
    try {
      final invoice = await invoiceService.fetchItem(event.id);
      if (invoice.status == "final") {
        emit(SellingStarted(invoice: invoice));
      } else if ([
        'paid',
        'partially_paid',
        "unpaid",
      ].contains(invoice.status)) {
        emit(PrintInvoice(invoice: invoice));
      } else {
        emit(state.copyWithError("The invoice must be finaled"));
      }
    } on NetworkFailure {
      // 🚨 هنا تم التفريق: خطأ شبكة
      emit(state.copyWithError("Fiald to connect to the server"));
    } on ServerFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ سيرفر
      emit(
        state.copyWithError('Server Down (Code ${f.statusCode}): حاول لاحقاً.'),
      );
    } on ClientFailure catch (f) {
      // 🚨 هنا تم التفريق: خطأ عميل/منطق
      emit(
        state.copyWithError(
          'Client Error (Code ${f.statusCode}): ${f.message}',
        ),
      );
    } catch (_) {
      emit(state.copyWithError('حدث خطأ غير متوقع.'));
    }
  }
}
