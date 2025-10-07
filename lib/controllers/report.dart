import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/services/general_services.dart';
import '../models/report.dart';

class ReportController extends MainController<Report> {
  ReportController({required super.context, required super.service});
  void generate(int id) {
    final service = GeneralService<Report>(
      endpoint: "/reports/$id/generate/",
      fromMap: Report.fromMap,
      toMap: (o) => o.toMap(),
    );
    BlocProvider.of<GeneralBloc<Report>>(context).add(
      LoadSinglItem<Report>(service)
    );
  }
}
