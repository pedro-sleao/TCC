part of 'calibration_cubit.dart';

/// Classe abstrata que representa os diferentes estados da calibracao.
abstract class CalibrationState {}

/// Estado inicial do WebSocket.
class CalibrationInitial extends CalibrationState {}

/// Estado para atualizar os widgets ao inserir os dados dos sensores.
class CalibrationInserting extends CalibrationState {
  final Map<String, bool> updatePhExpectedValue;

  CalibrationInserting(this.updatePhExpectedValue);

  List<Object?> get phExpectedValues => [updatePhExpectedValue];
}

/// Estado que indica que a calibracao esta sendo feita.
class CalibrationLoading extends CalibrationState {}

/// Estado que indica que os dados da calibracao foram enviados.
class CalibrationSent extends CalibrationState {
  final String calibrationMessage;

  CalibrationSent({required this.calibrationMessage});
}

/// Estado que indica que a calibração foi feita com sucesso.
class CalibrationDone extends CalibrationState {
  final String calibrationMessage;

  CalibrationDone({required this.calibrationMessage});
}

/// Estado emitido quando ocorre um erro.
class CalibrationError extends CalibrationState {
  final String calibrationError;

  CalibrationError({required this.calibrationError});
}
