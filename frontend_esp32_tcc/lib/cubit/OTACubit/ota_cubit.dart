import 'package:dashboard_flutter/data/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'ota_state.dart';

/// Gerencia o envio do arquivo binario para o servidor.
class OtaCubit extends Cubit<OtaState> {
  final Repository repository;

  OtaCubit({required this.repository}) : super(OtaInitial());

  Future<void> uploadFirmware() async {
    emit(OtaLoading());
    try {
      await repository.uploadFirmware();
      emit(OtaDone());
    } catch (e) {
      emit(OtaError(errorMessage: e.toString()));
    }
  }
}
