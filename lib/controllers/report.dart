import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import '../models/report.dart';

class ReportController extends MainController<Report> {
  ReportController({required super.context});
  void generate(int id) {
    BlocProvider.of<GeneralBloc<Report>>(
      context,
    ).add(LoadSinglItem<Report>(tempPoint: "/reports/$id/generate/"));
  }
}
