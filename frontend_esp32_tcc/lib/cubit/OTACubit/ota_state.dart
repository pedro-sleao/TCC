part of 'ota_cubit.dart';

/// Classe abstrata que representa os diferentes estados do OTA.
abstract class OtaState {}

/// Estado inicial do OTA.
class OtaInitial extends OtaState {}

/// Estado que indica que o OTA esta ocorrendo
class OtaLoading extends OtaState {}

/// Estado que indica que o OTA ocorreu com sucesso.
class OtaDone extends OtaState {}

/// Estado que indica que ocorreu um erro no OTA.
class OtaError extends OtaState {
  final String errorMessage;

  OtaError({required this.errorMessage});
}
