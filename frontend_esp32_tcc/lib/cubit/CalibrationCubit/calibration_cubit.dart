import 'package:dashboard_flutter/constants.dart';
import 'package:dashboard_flutter/data/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'calibration_state.dart';

/// Gerencia o envio dos dados para calibracao dos sensores.
class CalibrationCubit extends Cubit<CalibrationState> {
  final Repository repository;
  

  CalibrationCubit({required this.repository}) : super(CalibrationInitial());

  Map<String, bool> phExpectedValues = {
    "6.86": false,
    "9.18": false,
  };

  String selectedCalibration = "pH";

  // Envia os dados da calibracao para o servidor.
  void sendCalibrationData(String idPlaca,
    dynamic phExpectedValue, dynamic tdsExpectedValue) async {
    repository.sendCalibrationData(idPlaca, phExpectedValue, tdsExpectedValue).then((msg) {
      emit(CalibrationSent(calibrationMessage: msg));
    }).catchError((e) {
      emit(CalibrationError(calibrationError: e.toString()));
    });
  }

  /// Marca o valor esperado de calibracao do ph.
  void setPhValueChecked(String sensorName, bool isChecked) {
    if (isChecked) {
      phExpectedValues.updateAll((key, value) => false);
      phExpectedValues[sensorName] = true;
    } else {
      phExpectedValues[sensorName] = false;
  }
    emit(CalibrationInserting(phExpectedValues));
  }

  /// Obtem o valor selecionado para calibracao do ph.
  String? getSelectedPhValue() {
    try {
      return phExpectedValues.entries
          .firstWhere((entry) => entry.value == true)
          .key;
    } catch (e) {
      return null; // nenhum valor marcado
    }
  }


  /// Limpa todos os valores do campo de ph.
  void clearPhExpectedValue() {
    phExpectedValues = {
      "6.86": false,
      "9.18": false,
    };
    emit(CalibrationLoading());
  }

  /// Atualiza o sensor que vai ser calibrado.
  void updateSelectedCalibration(String selectedSensor) {
    selectedCalibration = selectedSensor;
    emit(CalibrationInserting(phExpectedValues));
  }

  void resetCalibrationState() {
    emit(CalibrationInitial());
  }

  void calibrationResponse(String message) {
    emit(CalibrationDone(calibrationMessage: message));
  }
}
