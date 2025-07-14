part of 'http_cubit.dart';

/// Classe base para todos os estados do [HttpCubit].
///
/// Esta classe é a base abstrata para todos os estados que o cubit pode emitir.
abstract class HttpState {}

/// Estado inicial do HttpCubit.
class HttpInitial extends HttpState {}

/// Estado de carregamento.
class HttpLoading extends HttpState {}

/// Estado quando os dados dos locais são carregados com sucesso.
class HttpLocalLoaded extends HttpState {}

/// Estado quando os dados dos sensores são carregados com sucesso.
class HttpDataLoaded extends HttpState {}

/// Estado de erro.
class HttpError extends HttpState {
  final String errorMessage;

  HttpError({required this.errorMessage});
}
