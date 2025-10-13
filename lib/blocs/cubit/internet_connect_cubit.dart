import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'internet_connect_state.dart';

class InternetConnectCubit extends Cubit<InternetConnectState> {
  InternetConnectCubit() : super(InternetConnectInitial());
}
