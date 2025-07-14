part of 'socketio_cubit.dart';

/// Classe abstrata que representa os diferentes estados do WebSocket.
abstract class SocketState {}

/// Estado inicial do WebSocket.
class SocketInitial extends SocketState {}

/// Estado que indica que a conexão com o WebSocket está sendo estabelecida.
class SocketLoading extends SocketState {}

/// Estado que indica que a conexão com o WebSocket foi estabelecida com sucesso.
class SocketConnected extends SocketState {}
