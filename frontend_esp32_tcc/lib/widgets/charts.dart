// ignore_for_file: prefer_const_constructors, unused_import

import 'package:dashboard_flutter/cubit/HTTPCubit/http_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';


/// Um widget que exibe gráficos de linha ou gráficos de área de intervalo com base em dados de sensores.
///
/// Este widget usa o `SfCartesianChart` da biblioteca `syncfusion_flutter_charts` para mostrar
/// gráficos que representam dados de sensores ao longo do tempo.
class Charts extends StatefulWidget {
  /// Cria uma instância de [Charts].
  ///
  /// O [name] é o título do gráfico, que é usado para determinar a unidade de medida.
  /// O [sensorData] é a lista de dados dos sensores a serem exibidos no gráfico.
  /// O [sensorMinData] e [sensorMaxData] são listas opcionais de dados mínimos e máximos
  /// para gráficos de área de intervalo. O [dataTime] é a lista de timestamps correspondentes
  /// aos dados dos sensores.
  const Charts({
    super.key,
    required this.name,
    required this.sensorData,
    this.sensorMinData,
    this.sensorMaxData,
    required this.dataTime,
  });

  /// O título do gráfico, usado para determinar a unidade de medida (por exemplo, "Temperatura").
  final String? name;

  /// Lista de dados dos sensores a serem exibidos no gráfico.
  final List? sensorData;

  /// Lista opcional de dados mínimos para gráficos de área de intervalo.
  final List? sensorMinData;

  /// Lista opcional de dados máximos para gráficos de área de intervalo.
  final List? sensorMaxData;

  /// Lista de timestamps correspondentes aos dados dos sensores.
  final List dataTime;

  @override
  State<Charts> createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  late List<ChartData> chartData = [];
  late List<RangeChartData> rangeChartData = [];
  late String unidade;
  late TrackballBehavior _trackballBehavior;

  @override
  void initState() {
    super.initState();

    // Define a unidade de medida com base no título do gráfico.
    if (widget.name!.contains("Temperatura")){
      unidade = "°C";
    } else if (widget.name!.contains("Turbidez")){
      unidade = "%";
    } else if (widget.name!.contains("TDS")){
      unidade = "ppm";
    } else if (widget.name!.contains("pH")){
      unidade = "";
    }

    _trackballBehavior = TrackballBehavior(
        enable: true,
        markerSettings: const TrackballMarkerSettings(
          height: 10,
          width: 10,
          borderColor: Colors.black,
          borderWidth: 4,
        ),
        activationMode: ActivationMode.singleTap,
        lineDashArray: const <double>[5, 5],
        tooltipSettings: InteractiveTooltip(
            enable: true,
            color: Colors.black,
            format: 'point.y$unidade  point.x'));

    updateChartData();
  }

  void _updateTrackballBehavior({dynamic pastDays = 1}) {
    _trackballBehavior = TrackballBehavior(
      enable: true,
      markerSettings: const TrackballMarkerSettings(
        height: 10,
        width: 10,
        borderColor: Colors.black,
        borderWidth: 4,
      ),
      activationMode: ActivationMode.singleTap,
      lineDashArray: const <double>[5, 5],
      tooltipSettings: InteractiveTooltip(
        enable: true,
        color: Colors.black,
        format: (pastDays != 1 && pastDays != 7)
            ? 'point.high$unidade  point.low$unidade point.x'
            : 'point.y$unidade  point.x',
      ),
    );
  }

  /// Atualiza os dados do gráfico com base nas listas de dados fornecidas.
  ///
  /// Filtra os dados dos sensores e os timestamps, e gera listas de dados para gráficos de linha
  /// e gráficos de área de intervalo (se os dados mínimos e máximos estiverem disponíveis).
  void updateChartData() {
    List<double> filteredSensorData = [];
    List<String> filteredDataTime = [];

    for (var i = 0; i < widget.dataTime.length; i++) {
      if (widget.sensorData![i] != null) {
        filteredSensorData.add(widget.sensorData![i].toDouble());
        filteredDataTime.add(widget.dataTime[i]);
      }
    }

    final int length = filteredSensorData.length;
    // final int startIndex = length > 10 ? length - 10 : 0;
    const int startIndex = 0;

    chartData = List<ChartData>.generate(
      length - startIndex,
      (index) => ChartData(filteredDataTime[startIndex + index],
          filteredSensorData[startIndex + index]),
    );

    if (widget.sensorMinData!.isNotEmpty && widget.sensorMaxData!.isNotEmpty) {
      rangeChartData = List<RangeChartData>.generate(
        length - startIndex,
        (index) => RangeChartData(
            DateTime.parse(filteredDataTime[startIndex + index]),
            widget.sensorMinData?[startIndex + index],
            widget.sensorMaxData?[startIndex + index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    HttpCubit httpCubit = BlocProvider.of<HttpCubit>(context);
    _updateTrackballBehavior(pastDays: httpCubit.pastDays);

    updateChartData();
    return SfCartesianChart(
      title: ChartTitle(text: 'Histórico de medições'),
      trackballBehavior: _trackballBehavior,
      primaryXAxis: CategoryAxis(
        maximumLabels: 1,
      ),
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        position: LegendPosition.top,
      ),
      series: <CartesianSeries>[
        if (httpCubit.pastDays == '' || httpCubit.pastDays == 30) ...[
          RangeAreaSeries<RangeChartData, DateTime>(
            animationDuration: 0,
            dataSource: rangeChartData,
            name: widget.name,
            borderWidth: 2,
            color: Color(0xFFE0F2F1),
            borderDrawMode: RangeAreaBorderMode.excludeSides,
            borderColor: const Color(0xFF00BFA5),
            xValueMapper: (RangeChartData data, _) => data.x,
            lowValueMapper: (RangeChartData data, _) => data.low,
            highValueMapper: (RangeChartData data, _) => data.high,
          )
        ] else ...[
          LineSeries<ChartData, String>(
            animationDuration: 0,
            name: widget.name,
            dataSource: chartData,
            pointColorMapper: (ChartData data, _) => Colors.tealAccent[700]!,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            markerSettings: MarkerSettings(isVisible: false),
          ),
        ]
      ],
    );
  }
}



/// Dados para o gráfico de linha.
///
/// Contém o timestamp e o valor do sensor.
class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}


/// Dados para o gráfico de área de intervalo.
///
/// Contém o timestamp, valor mínimo e valor máximo do sensor.
class RangeChartData {
  RangeChartData(this.x, this.high, this.low);
  final DateTime x;
  final double high;
  final double low;
}
