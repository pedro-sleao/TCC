part of 'register_cubit.dart';


/// Classe base para todos os estados do [RegisterCubit].
abstract class RegisterState {}

/// Estado inicial do [RegisterCubit].
class RegisterInitial extends RegisterState {}


/// Estado emitido quando há uma atualização no estado dos sensores.
class RegisterInserting extends RegisterState {
  final Map<String, bool> updatedSensorStates;

  RegisterInserting(this.updatedSensorStates);

  List<Object?> get sensorStates => [updatedSensorStates];
}

/// Estado emitido quando a coluna de filtragem é alterada.
class RegisterFilteringColumn extends RegisterState {
  final String updatedSelectedColumn;

  RegisterFilteringColumn(this.updatedSelectedColumn);

  String get selectedColumn => updatedSelectedColumn;
}

/// Estado emitido quando uma operação de registro é concluída com sucesso.
class RegisterDone extends RegisterState {
  final String registerMessage;

  RegisterDone({required this.registerMessage});
}


/// Estado emitido quando a lista de usuários é obtida com sucesso.
class RegisterFetchedUsers extends RegisterState {}

/// Estado emitido quando um usuário é excluído com sucesso.
class RegisterDeletedUser extends RegisterState{
  final String deleteMessage;

  RegisterDeletedUser({required this.deleteMessage});
}

/// Estado emitido quando ocorre um erro em uma operação de registro ou gerenciamento.
class RegisterError extends RegisterState {
  final String registerError;

  RegisterError({required this.registerError});
}
