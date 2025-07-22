// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:dashboard_flutter/constants.dart';
import 'package:dashboard_flutter/cubit/HTTPCubit/http_cubit.dart';
import 'package:dashboard_flutter/cubit/LoginCubit/login_cubit.dart';
import 'package:dashboard_flutter/cubit/SocketCubit/socketio_cubit.dart';
import 'package:dashboard_flutter/responsive.dart';
import 'package:dashboard_flutter/widgets/bar.dart';
import 'package:dashboard_flutter/widgets/metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal da aplicação.
/// 
/// Esta página exibe as métricas e gráficos relacionados aos sensores. Ela utiliza
/// o [HttpCubit] para gerenciar o estado dos dados dos sensores e o [SocketCubit]
/// para gerenciar as conexões via socket. O layout é ajustado conforme o tamanho da tela
/// utilizando o conceito de responsividade.
class DashboardPage extends StatelessWidget {
  /// Lista dos locais para dropdown.
  late List<dynamic> localList = [];

  /// Instância do cubit responsável por gerenciar as requisições HTTP.
  late HttpCubit _httpCubit;

  /// Instância do cubit responsável pela comunicação via sockets.
  late SocketCubit _socketCubit;

  /// Cria uma instância de [DashboardPage].
  DashboardPage({super.key});

  /// Converte uma lista de valores em uma lista de itens de menu suspenso.
  ///
  /// O parâmetro [list] é a lista de valores a serem convertidos.
  /// Retorna uma lista de [DropdownMenuItem<String>] correspondentes aos valores.
  List<DropdownMenuItem<String>> getDropDownItems(List<dynamic> list) {
    return list.map((value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    _httpCubit = BlocProvider.of<HttpCubit>(context);
    _socketCubit = BlocProvider.of<SocketCubit>(context);
    return BlocBuilder<HttpCubit, HttpState>(
        bloc: _httpCubit,
        builder: (context, state) {
          List<Widget> lastDataColumn = [
            Text(
              "Ultimos dados",
              style: TextStyle(fontSize: 25),
            ),
            BarWidget(
              title: "Temperatura",
              dataList: _httpCubit.sensorsData.temperatureList,
              maxValue: 50,
            ),
            BarWidget(
              title: "TDS",
              dataList: _httpCubit.sensorsData.tdsList,
              maxValue: 1000,
            ),
            BarWidget(
              title: "Turbidez",
              dataList: _httpCubit.sensorsData.turbidityList,
              maxValue: 100,
            ),
            BarWidget(
              title: "pH",
              dataList: _httpCubit.sensorsData.phList,
              maxValue: 14,
            ),
            if (Responsive.isMobile(context)) ...[
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/metrics');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBackgroundColor,
                ),
                child: const Text(
                  "Visualizar métricas",
                  style: TextStyle(color: buttonTextColor),
                ),
              ),
            ]
          ];
          if (state is HttpInitial || state is HttpLoading) {
            state is HttpInitial ? _httpCubit.fetchLocals() : null;
            return noDataScreen(context, _httpCubit,
                getDropDownItems(localList), "Nenhum dado encontrado");
          } else if (state is HttpLocalLoaded) {
            localList = _httpCubit.getLocalList();
            _httpCubit.fetchSensorsData(localList.first);
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.grey),
              ),
            );
          } else if (state is HttpDataLoaded) {
            _socketCubit.initSocket(_httpCubit);
            return Scaffold(
              drawerScrimColor: Colors.transparent,
              key: GlobalKey<ScaffoldState>(),
              drawer: buildDrawer(context),
              body: Builder(builder: (context) {
                return SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                            icon: Icon(Icons.menu_rounded),
                            iconSize: 30,
                            color: Colors.black,
                          ),
                          Container(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 10.0),
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                DropdownButton<String>(
                                  value: _httpCubit.selectedLocal,
                                  items: getDropDownItems(localList),
                                  onChanged: (value) {
                                    _httpCubit.fetchSensorsData(value!);
                                  },
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.black,
                                  ),
                                  iconSize: 30,
                                  underline: SizedBox(),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                logoutButton(context)
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!Responsive.isMobile(context)) ...[
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: Container(
                                      width: lastDataContainerSize,
                                      decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        children: lastDataColumn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Metrics(),
                              )
                            ],
                          ),
                        ),
                      ],
                      if (Responsive.isMobile(context)) ...[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: lastDataColumn,
                          ),
                        ),
                      ]
                    ],
                  ),
                );
              }),
            );
          } else if (state is HttpError) {
            return noDataScreen(context, _httpCubit,
                getDropDownItems(localList), "Erro na conexão com o servidor");
          } else {
            return Container();
          }
        });
  }
}

/// Constrói o menu lateral da aplicação.
///
/// Este widget é exibido como um menu lateral e contém botões para navegar entre
/// as diferentes páginas da aplicação. Se o usuário tiver o papel de "admin", um
/// botão adicional para acessar a página de administração é exibido.
Widget buildDrawer(context) {
  LoginCubit loginCubit = BlocProvider.of<LoginCubit>(context);

  return SafeArea(
    child: Container(
      padding: EdgeInsets.only(top: 50),
      width: 50,
      child: Column(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            icon: Icon(
              Icons.table_chart,
              color: Colors.black,
            ),
          ),
          if (loginCubit.userRole == "admin") ...[
            SizedBox(
              height: 10,
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/admin');
              },
              icon: Icon(
                Icons.supervisor_account,
                color: Colors.black,
              ),
            ),
          ],
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/ota');
            },
            icon: Icon(
              Icons.update,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Constrói uma tela de mensagem de erro ou de ausência de dados.
///
/// Este widget é exibido quando não há dados disponíveis ou ocorre um erro de
/// conexão com o servidor. Ele inclui um botão para logout e, no caso de
/// ausência de dados, um seletor de dias.
Widget noDataScreen(context, HttpCubit httpCubit,
    List<DropdownMenuItem<String>> dropDownItens, String message) {
  return Scaffold(
    key: GlobalKey<ScaffoldState>(),
    body: Builder(builder: (context) {
      return SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icon(Icons.menu_rounded),
                  iconSize: 30,
                  color: Colors.black,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20.0, right: 10.0),
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        value: httpCubit.selectedLocal,
                        items: dropDownItens,
                        onChanged: (value) {
                          httpCubit.fetchSensorsData(value!);
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black,
                        ),
                        iconSize: 30,
                        underline: SizedBox(),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      logoutButton(context)
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    Icon(Icons.error),
                    if (message == "Nenhum dado encontrado")...[
                      SizedBox(height: 20,),
                      SelectDays()
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }),
    drawerScrimColor: Colors.transparent,
    drawer: buildDrawer(context),
  );
}

Widget logoutButton(context) {
  LoginCubit loginCubit = BlocProvider.of<LoginCubit>(context);
  return IconButton(
    onPressed: () {
      loginCubit.logout();
    },
    icon: Icon(
      Icons.logout,
      color: Colors.black,
    ),
  );
}
