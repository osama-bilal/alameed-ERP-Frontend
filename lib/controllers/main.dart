// here is created main controller for app like provider or bloc or riverpod and also state management
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/services/general_services.dart';

class MainController<T> {
  MainController({required this.context, required this.service});
  final BuildContext context;
  final GeneralService<T> service;
  void fethAll() {
    BlocProvider.of<GeneralBloc<T>>(
      context,
    ).add(LoadItems<T>(service));
  }

  void createItem(T item) {
    BlocProvider.of<GeneralBloc<T>>(
      context,
    ).add(AddItem<T>(service, item));
  }

  void deleteItem(int id) {
    BlocProvider.of<GeneralBloc<T>>(
      context,
    ).add(DeleteItem<T>(service, id));
  }

  void patialUpdate(int id, Map<String, dynamic> changes) {
    BlocProvider.of<GeneralBloc<T>>(
      context,
    ).add(PartialUpdateItem<T>(service, changes, id));
  }

  void update(int id, T item) {
    BlocProvider.of<GeneralBloc<T>>(
      context,
    ).add(UpdateItem<T>(service, item, id));
  }
}
