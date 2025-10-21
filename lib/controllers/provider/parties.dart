import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/party.dart';

class SystemParties extends ChangeNotifier {
  List<ViewParty> parties = [];

  void addList<T>(List<ViewParty<T>> l) {
    parties.addAll(l);
    // notifyListeners();
  }

  List<ViewParty<T>> get<T>() =>
      parties.whereType<ViewParty<T>>().toList();
}
