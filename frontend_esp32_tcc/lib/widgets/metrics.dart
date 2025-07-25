import 'package:dashboard_flutter/constants.dart';
import 'package:dashboard_flutter/cubit/HTTPCubit/http_cubit.dart';
import 'package:dashboard_flutter/responsive.dart';
import 'package:dashboard_flutter/widgets/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Widget que exibe as métricas e o gráfico dos dados dos sensores.
class Metrics extends StatelessWidget {
  const Metrics({super.key});

  @override
  Widget build(BuildContext context) {
    /// Cria uma lista de itens do menu suspenso a partir de uma lista de valores.
    /// 
    /// [list]: Lista de itens para criar o menu suspenso.
    /// 
    /// Retorna uma lista de [DropwDownMenuItem<String>].
    List<DropdownMenuItem<String>> getDropDownItems(List<dynamic> list) {
      return list.map((value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList();
    }

    HttpCubit httpCubit = BlocProvider.of<HttpCubit>(context);
    return BlocBuilder<HttpCubit, HttpState>(builder: (context, state) {
      dynamic selectedDays = httpCubit.pastDays;
      if (state is HttpDataLoaded) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Estatísticas", style: TextStyle(fontSize: 25)),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    decoration: const BoxDecoration(color: primaryColor),
                    child: DropdownButton<String>(
                      value: httpCubit.selectedSensor,
                      items: getDropDownItems(httpCubit.sensorList),
                      onChanged: (value) {
                        httpCubit.getSelectedMetrics(value);
                        httpCubit.getSelectedSensorList();
                      },
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                      ),
                      iconSize: 30,
                      underline: const SizedBox(),
                    ),
                  ),
                ],
              )),
              const SizedBox(
                height: 20,
              ),
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return SizedBox(
                  height: 300,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: SelectDays(),
                      ),
                      metricsWidget(
                          constraints: constraints,
                          title:
                              "Média das medições ${selectedDays == '' ? selectedDays : 'nos últimos $selectedDays dias'}",
                          data: toDouble(httpCubit.selectedMetrics?['media'])),
                      const SizedBox(
                        height: 15,
                      ),
                      metricsWidget(
                          constraints: constraints,
                          title: "Valor máximo ${selectedDays == '' ? selectedDays : 'nos últimos $selectedDays dias'}",
                          data: toDouble(httpCubit.selectedMetrics?['valor_maximo'])),
                      const SizedBox(
                        height: 15,
                      ),
                      metricsWidget(
                          constraints: constraints,
                          title: "Valor mínimo ${selectedDays == '' ? selectedDays : 'nos últimos $selectedDays dias'}",
                          data: toDouble(httpCubit.selectedMetrics?['valor_minimo']))
                    ],
                  ),
                );
              }),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SizedBox(
                    height: !Responsive.isMobile(context) ? 500 : 400,
                    width: constraints.maxWidth * 0.8,
                    child: Charts(
                      name: httpCubit.selectedSensor,
                      sensorData: httpCubit.selectedSensorList,
                      sensorMinData: httpCubit.selectedSensorMinList,
                      sensorMaxData: httpCubit.selectedSensorMaxList,
                      dataTime: httpCubit.sensorsData.dataTimeList,
                    ),
                  );
                },
              )
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}

/// Widget que permite selecionar um intervalo de dias para exibir as métricas.
class SelectDays extends StatelessWidget {
  const SelectDays({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    HttpCubit httpCubit = BlocProvider.of<HttpCubit>(context);
    String? local = httpCubit.selectedLocal;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            if (httpCubit.pastDays != 1){
              httpCubit.setPastDays(1);
              httpCubit.updateData(local!);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
          ),
          child: const Text(
            "1 dia",
            style: TextStyle(color: buttonTextColor),
          ),
        ),
        const SizedBox(
          width: 10,
          child: VerticalDivider(),
        ),
        TextButton(
          onPressed: () {
            if (httpCubit.pastDays != 7){
              httpCubit.setPastDays(7);
              httpCubit.updateData(local!);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
          ),
          child: const Text(
            "7 dias",
            style: TextStyle(color: buttonTextColor),
          ),
        ),
        const SizedBox(
          width: 10,
          child: VerticalDivider(),
        ),
        TextButton(
          onPressed: () {
            if (httpCubit.pastDays != 30){
              httpCubit.setPastDays(30);
              httpCubit.updateData(local!);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
          ),
          child: const Text(
            "30 dias",
            style: TextStyle(color: buttonTextColor),
          ),
        ),
        const SizedBox(
          width: 10,
          child: VerticalDivider(),
        ),
        TextButton(
          onPressed: () {
            if (httpCubit.pastDays != ''){
              httpCubit.setPastDays('');
              httpCubit.updateData(local!);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
          ),
          child: const Text(
            "Total",
            style: TextStyle(color: buttonTextColor),
          ),
        ),
      ],
    );
  }
}

/// Widget que exibe uma métrica específica com um título.
class metricsWidget extends StatelessWidget {
  /// Cria uma instância de [metricsWidget].
  ///
  /// O [constraints] define as restrições de layout para o widget.
  /// O [title] é o título a ser exibido.
  /// O [data] é o valor da métrica a ser exibido.
  const metricsWidget({
    super.key,
    required this.constraints,
    required this.title,
    required this.data,
  });

  /// O título a ser exibido no widget.
  final String title;

  /// O valor da métrica a ser exibido.
  final double? data;

  /// As restrições de layout do widget.
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: !Responsive.isMobile(context)
            ? constraints.maxWidth * 0.5
            : constraints.maxWidth,
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 1),
              )
            ]),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "${data ?? 0}",
              style: const TextStyle(fontSize: 13),
            )
          ],
        ));
  }
}

double? toDouble(dynamic value) {
  return value is num ? value.toDouble() : null;
}