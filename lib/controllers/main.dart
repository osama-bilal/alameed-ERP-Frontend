// here is created main controller for app like provider or bloc or riverpod and also state management
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';

class MainController<T extends Object> {
  MainController({required this.context, this.tempEndPoint});
  final BuildContext context;
  final String? tempEndPoint;
  void fetchAll() {
    BlocProvider.of<GeneralBloc<T>>(
      context,
    ).add(LoadItems<T>(tempPoint: tempEndPoint));
  }

  void createItem(T item) {
    BlocProvider.of<GeneralBloc<T>>(
      context,
    ).add(AddItem<T>(item, tempPoint: tempEndPoint));
  }

  void deleteItem(int id) {
    BlocProvider.of<GeneralBloc<T>>(context).add(DeleteItem<T>(id));
  }

  void patialUpdate(int id, Map<String, dynamic> changes) {
    BlocProvider.of<GeneralBloc<T>>(context).add(
      PartialUpdateItem<T>(
        changes: changes,
        itemId: id,
        tempPoint: tempEndPoint,
      ),
    );
  }

  void update(int id, T item) {
    BlocProvider.of<GeneralBloc<T>>(
      context,
    ).add(UpdateItem<T>(item: item, itemId: id, tempPoint: tempEndPoint));
  }
}
