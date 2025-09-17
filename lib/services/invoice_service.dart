// services/invoice_service.dart
import '../models/invoices/sale.dart';
import 'api_client.dart';

class InvoiceService {
  final ApiClient _api = ApiClient();

  Future<List<SaleInvoice>> fetchInvoices() async {
    final response = await _api.dio.get("/invoices/invoices/");
    final data = response.data as List;
    return data.map((json) => SaleInvoice.fromMap(json)).toList();
  }

  Future<SaleInvoice> createInvoice(SaleInvoice invoice) async {
    final response = await _api.dio.post("/invoices/invoices/", data: invoice.toMap());
    return SaleInvoice.fromMap(response.data);
  }
}
