
import 'package:dashboard_flutter/data/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'register_state.dart';

/// Cubit que gerencia o estado das operações de registro e gerenciamento de usuários.
///
/// O [RegisterCubit] lida com operações como registro de dados da placa, registro de usuários, 
/// busca de usuários, exclusão de usuários, e manipulação de estados de sensores.
class RegisterCubit extends Cubit<RegisterState> {
  final Repository repository;

  /// Construtor do [RegisterCubit].
  /// 
  /// [repository] é usado para fazer chamadas à API.
  RegisterCubit({required this.repository}) : super(RegisterInitial());

  Map<String, bool> sensorStates = {
    "Temperatura": false,
    "TDS": false,
    "Turbidez": false,
    "pH": false,
  };

  String selectedColumn = "Sem filtro";

  String registerAccountMessage = '';
  late String errorMessage;

  List<String> usersList = [];

  /// Registra dados de uma placa com as informações fornecidas.
  ///
  /// [localName] é o nome do local onde o nó está localizado.
  /// [idPlaca] é o identificador da placa.
  void registerNodeData(String localName, String idPlaca) async {
    repository
        .registerNodeData(localName, idPlaca, sensorStates)
        .then((msg) {
      emit(RegisterDone(registerMessage: msg));
    }).catchError((e) {
      emit(RegisterError(registerError: e.toString()));
    });
  }

  /// Registra uma nova conta com o nome de usuário e senha fornecidos.
  ///
  /// [username] é o nome de usuário.
  /// [password] é a senha.
  void register(String username, String password) async {
    repository.register(username, password).then((msg) {
      emit(RegisterDone(registerMessage: msg));
    }).catchError((e) {
      emit(RegisterError(registerError: e.toString()));
    });
  }

  /// Busca a lista de usuários registrados.
  void fetchUsers() async {
    repository.fecthUsers().then((users) {
      usersList = users;
      emit(RegisterFetchedUsers());
    }).catchError((e) {
      emit(RegisterError(registerError: e.toString()));
    });
  }

  /// Exclui um usuário com o nome de usuário fornecido.
  ///
  /// [username] é o nome do usuário a ser excluído.
  void deleteUser(String username) async {
    repository.deleteUser(username).then((msg) {
      emit(RegisterDeletedUser(deleteMessage: msg));
    }).catchError((e) {
      emit(RegisterError(registerError: e.toString()));
    });
  }

  /// Atualiza o estado de um sensor específico.
  ///
  /// [sensorName] é o nome do sensor a ser atualizado.
  /// [isChecked] indica se o sensor está ativado ou desativado.
  void setSensorChecked(String sensorName, bool isChecked) {
    sensorStates[sensorName] = isChecked;
    emit(RegisterInserting(sensorStates));
  }

  /// Limpa todos os estados dos sensores.
  void clearSensorStates() {
    sensorStates = {
      "Temperatura": false,
      "TDS": false,
      "Turbidez": false,
      "pH": false,
    };
    emit(RegisterInitial());
  }

  /// Atualiza a coluna selecionada para filtragem.
  ///
  /// [newColumn] é o nome da nova coluna selecionada.
  void changeSelectedColumn(String newColumn) {
    selectedColumn = newColumn;

    emit(RegisterFilteringColumn(selectedColumn));
  }

  /// Reseta a mensagem de conta registrada.
  void resetRegisterAccountMessage() {
    registerAccountMessage = '';
  }
}
