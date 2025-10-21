part of 'internet_connect_cubit.dart';

sealed class InternetConnectState extends Equatable {
  const InternetConnectState();

  @override
  List<Object> get props => [];
}

final class InternetConnectInitial extends InternetConnectState {}

final class ConnectedState extends InternetConnectState {
  final String message;
  const ConnectedState({required this.message});

  @override
  List<Object> get props => [message];
}

final class FieldState extends InternetConnectState {
  final String message;
  const FieldState({required this.message});

  @override
  List<Object> get props => [message];
}
