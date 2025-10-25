part of 'list_bloc.dart';

sealed class ListEvent<T> extends Equatable {
  final GeneralService<T>? tempService;
  const ListEvent({this.tempService});

  @override
  List<Object?> get props => [tempService];
}

class LoadList<T> extends ListEvent<T> {
  const LoadList({super.tempService});
}
