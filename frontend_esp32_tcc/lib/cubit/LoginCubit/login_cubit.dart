import 'package:dashboard_flutter/data/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_state.dart';

/// Cubit para gerenciar o estado de login e logout.
///
/// O LoginCubit é responsável por realizar operações relacionadas ao login, logout e
/// busca de informações do usuário. Ele usa o [Repository] para interagir com a API
/// e emite diferentes estados para refletir o progresso e os resultados dessas operações.
class LoginCubit extends Cubit<LoginState> {
  final Repository repository;

  /// Construtor do [LoginCubit].
  /// 
  /// [repository] é usado para fazer chamadas à API relacionadas a login e logout.
  LoginCubit({required this.repository}) : super(LoginInitial());

  String? userRole;

  /// Realiza uma chamada para buscar informações do usuário.
  /// 
  /// Emite [LoginLoading] enquanto a solicitação está em andamento.
  /// Emite [LoginDone] se a busca for bem-sucedida, atualizando o papel do usuário.
  /// Emite [LoginError] se ocorrer um erro durante a busca.
  void fetchUser() {
    emit(LoginLoading());
    repository.fetchUser().then((userData) {
      userRole = userData['data']['role'];
      emit(LoginDone());
    }).catchError((e) {
      emit(LoginError(errorMessage: e.toString()));
    });
  }

  /// Realiza o login do usuário.
  /// 
  /// [username] e [password] são fornecidos para autenticação.
  /// Emite [LoginLoading] enquanto a solicitação está em andamento.
  /// Emite [LoginDone] se o login for bem-sucedido, atualizando o papel do usuário.
  /// Emite [LoginError] se ocorrer um erro durante o login.
  void login(String username, String password) {
    emit(LoginLoading());
    repository.login(username, password).then((loginResponse) {
      userRole = loginResponse['role'];
      emit(LoginDone());
    }).catchError((e) {
      emit(LoginError(errorMessage: e.toString()));
    });
  }

  /// Realiza o logout do usuário.
  /// 
  /// Emite [LoginLoading] enquanto a solicitação de logout está em andamento.
  /// Emite [LogoutDone] se o logout for bem-sucedido.
  /// Emite [LoginError] se ocorrer um erro durante o logout ou se a resposta indicar um erro.
  void logout() {
    repository.logout().then((logoutResponse) {
      if (!logoutResponse) {
        emit(LogoutDone());
      } else {
        emit(LoginError(errorMessage: 'Erro ao desconectar-se.'));
      }
    }).catchError((e) {
      emit(LoginError(errorMessage: e.toString()));
    });
  }

}
