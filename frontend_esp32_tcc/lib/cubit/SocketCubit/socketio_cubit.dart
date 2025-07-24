import 'package:dashboard_flutter/constants.dart';
import 'package:dashboard_flutter/cubit/CalibrationCubit/calibration_cubit.dart';
import 'package:dashboard_flutter/cubit/HTTPCubit/http_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'socketio_state.dart';

/// Gerencia a conexão com o servidor WebSocket e a comunicação de eventos.
///
/// Utiliza o 'socket_io_client' para estabelecer a comunicação em tempo real.
class SocketCubit extends Cubit<SocketState> {
  SocketCubit() : super(SocketInitial());

  static IO.Socket? socket;

  /// Inicializa a conexão com o servidor WebSocket.
  ///
  /// [httpCubit] é o cubit de HTTP utilizado para atualizar dados quando uma mensagem é recebida pelo WebSocket.
  void initSocket(HttpCubit httpCubit, CalibrationCubit calibrationCubit) {
    // Não faz nada se o socket ja estiver conectado.
    if (socket != null && socket!.connected) {
      return;
    }
    emit(SocketLoading());
    socket = IO.io('http://$ipAddress:5000', <String, dynamic>{
      'transports': ['websocket']
    });
    emit(SocketConnected());
    socket!.on('message', (data) {
      String? local = httpCubit.selectedLocal;
      httpCubit.updateData(local!);
      httpCubit.updateNodeData();
    });

    socket!.on('calibration_response', (data) {
      calibrationCubit.calibrationResponse(data);
    });
  }

  /// Desconecta a conexão WebSocket se estiver ativa.
  void disconnectSocket() {
    if (socket != null) {
      socket!.disconnect();
    }
  }
}
