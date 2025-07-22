import 'package:dashboard_flutter/cubit/HTTPCubit/http_cubit.dart';
import 'package:dashboard_flutter/cubit/LoginCubit/login_cubit.dart';
import 'package:dashboard_flutter/cubit/OTACubit/ota_cubit.dart';
import 'package:dashboard_flutter/cubit/RegisterCubit/register_cubit.dart';
import 'package:dashboard_flutter/cubit/SocketCubit/socketio_cubit.dart';
import 'package:dashboard_flutter/data/http_services.dart';
import 'package:dashboard_flutter/data/repository.dart';
import 'package:dashboard_flutter/presentation/screens/admin.dart';
import 'package:dashboard_flutter/presentation/screens/admin_mobile.dart';
import 'package:dashboard_flutter/presentation/screens/dashboard.dart';
import 'package:dashboard_flutter/presentation/screens/login.dart';
import 'package:dashboard_flutter/presentation/screens/metrics_mobile.dart';
import 'package:dashboard_flutter/presentation/screens/ota.dart';
import 'package:dashboard_flutter/presentation/screens/register_node.dart';
import 'package:dashboard_flutter/presentation/screens/table_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Gerenciador de rotas da aplicação.
///
/// A classe [AppRouter] é responsável por definir as rotas da aplicação e criar as páginas
/// associadas a cada rota. Além disso, ela configura os cubits necessários para cada tela.
///
/// A classe também inclui um método para verificar a autenticação do usuário e redirecioná-lo
/// para a página de login se não estiver autenticado.
class AppRouter {
  late Repository repository;
  late LoginCubit loginCubit;
  late HttpCubit httpCubit;
  late RegisterCubit registerCubit;
  late SocketCubit socketCubit;
  late OtaCubit otaCubit;

  /// Cria uma instância do [AppRouter] e inicializa os cubits e o repositório necessários.
  AppRouter() {
    repository = Repository(httpService: HttpService());
    loginCubit = LoginCubit(repository: repository);
    httpCubit = HttpCubit(repository: repository);
    registerCubit = RegisterCubit(repository: repository);
    socketCubit = SocketCubit();
    otaCubit = OtaCubit(repository: repository);
  }

  /// Gera uma rota para a aplicação com base nas configurações fornecidas.
  ///
  /// O método [generateRoute] cria a rota e a página correspondente, configurando os cubits
  /// necessários para cada página. Ele também verifica a autenticação do usuário e redireciona
  /// para a página de login se o usuário não estiver autenticado.
  ///
  /// [settings] As configurações da rota solicitada.
  /// 
  /// Retorna uma [Route] correspondente à configuração fornecida.
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: httpCubit),
                    BlocProvider.value(value: loginCubit),
                    BlocProvider.value(value: socketCubit)
                  ],
                  child: _checkAuthentication(loginCubit, DashboardPage()),
                ),
            settings: settings);
      case "/register":
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: httpCubit),
                    BlocProvider.value(value: loginCubit),
                    BlocProvider.value(
                      value: registerCubit,
                    ),
                    BlocProvider.value(value: socketCubit)
                  ],
                  child: _checkAuthentication(loginCubit, const RegisterPage()),
                ),
            settings: settings);
      case "/table":
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: httpCubit),
                    BlocProvider.value(value: loginCubit),
                    BlocProvider.value(
                      value: registerCubit,
                    ),
                    BlocProvider.value(value: socketCubit)
                  ],
                  child: _checkAuthentication(loginCubit, const TableMobile()),
                ),
            settings: settings);
      case "/login":
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: httpCubit),
                    BlocProvider.value(value: loginCubit),
                  ],
                  child: const LoginPage(),
                ),
            settings: settings);
      case "/admin":
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: httpCubit),
                    BlocProvider.value(value: loginCubit),
                    BlocProvider.value(
                      value: registerCubit,
                    ),
                    BlocProvider.value(value: socketCubit)
                  ],
                  child: _checkAuthentication(loginCubit, const AdminPage()),
                ),
            settings: settings);
      case "/metrics":
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: httpCubit),
                    BlocProvider.value(value: loginCubit),
                    BlocProvider.value(
                      value: registerCubit,
                    ),
                    BlocProvider.value(value: socketCubit)
                  ],
                  child: _checkAuthentication(
                      loginCubit, const MetricsMobilePage()),
                ),
            settings: settings);
      case "/users":
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: httpCubit),
                    BlocProvider.value(value: loginCubit),
                    BlocProvider.value(
                      value: registerCubit,
                    ),
                    BlocProvider.value(value: socketCubit)
                  ],
                  child:
                      _checkAuthentication(loginCubit, const UsersListPage()),
                ),
            settings: settings);
      case "/ota":
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: httpCubit),
                    BlocProvider.value(value: loginCubit),
                    BlocProvider.value(value: socketCubit),
                    BlocProvider.value(value: registerCubit),
                    BlocProvider.value(value: otaCubit)
                  ],
                  child:
                      _checkAuthentication(loginCubit, const OtaPage()),
                ),
            settings: settings);
      default:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: httpCubit),
                    BlocProvider.value(value: loginCubit),
                  ],
                  child: const LoginPage(),
                ),
            settings: settings);
    }
  }
}

/// Verifica o estado de autenticação do usuário e exibe a página apropriada.
///
/// Caso o usuário não esteja autenticado, é redirecionado para a página de login.
/// Caso contrário, vai para a página desejada.
///
/// [loginCubit] O cubit responsável pela autenticação do usuário.
/// [page] A página a ser exibida se o usuário estiver autenticado.
Widget _checkAuthentication(LoginCubit loginCubit, Widget page) {
  return BlocBuilder<LoginCubit, LoginState>(
    builder: (context, state) {
      if (state is LoginInitial) {
        loginCubit.fetchUser();
        return const SizedBox(
            width: 50,
            height: 50,
            child: Center(
                child: CircularProgressIndicator(
              color: Colors.grey,
            )));
      } else if (state is LoginLoading) {
        return const SizedBox(
            width: 50,
            height: 50,
            child: Center(
                child: CircularProgressIndicator(
              color: Colors.grey,
            )));
      } else if (state is LoginDone) {
        return page;
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        });
        return const SizedBox.shrink();
      }
    },
  );
}
