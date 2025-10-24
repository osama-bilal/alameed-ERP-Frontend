import 'package:flutter/widgets.dart';
import 'package:ponit_of_sales/models/shift.dart';

class ShiftProvider extends ChangeNotifier {
  Shift? _currentShift;
  bool isLoading = false;

  Shift? get current => _currentShift;
  bool get hasOpen {
    return _currentShift != null &&
        _currentShift?.id != null &&
        _currentShift?.closedAt == null &&
        !_currentShift!.isClosed &&
        _currentShift?.openedAt != null;
  }

  void openNew(Shift s) {
    isLoading = false;
    _currentShift = s;
    notifyListeners();
  }

  void close() {
    _currentShift = null;
    isLoading = false;
    notifyListeners();
  }
}
