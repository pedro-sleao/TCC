part of 'login_cubit.dart';

/// Classe abstrata que representa o estado do LoginCubit.
///
/// Todos os estados possíveis do LoginCubit estendem esta classe.
abstract class LoginState {}

/// Estado inicial do LoginCubit.
class LoginInitial extends LoginState {}

/// Estado que indica que uma operação de login ou logout está em andamento.
class LoginLoading extends LoginState {}

/// Estado que indica que a operação de login foi concluída com sucesso.
class LoginDone extends LoginState {}

/// Estado que indica que a operação de login foi recusada.
class LoginRefused extends LoginState {}

/// Estado que indica que a operação de logout foi concluída com sucesso.
class LogoutDone extends LoginState {}

/// Estado que indica que ocorreu um erro durante uma operação de login ou logout.
class LoginError extends LoginState {
  final String errorMessage;

  LoginError({required this.errorMessage});
}