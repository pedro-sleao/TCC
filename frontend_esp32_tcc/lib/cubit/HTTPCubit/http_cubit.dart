import 'package:dashboard_flutter/data/models/locals.dart';
import 'package:dashboard_flutter/data/models/sensor_data.dart';
import 'package:dashboard_flutter/data/models/placa_data.dart';
import 'package:dashboard_flutter/data/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'http_state.dart';

/// Cubit responsável por gerenciar o estado das operações HTTP relacionadas
/// a locais, dados de sensores e métricas.
///
/// Esta classe utiliza o padrão Bloc para gerenciar estados e fornece métodos
/// para buscar dados, atualizar o estado e manipular as métricas dos sensores.
class HttpCubit extends Cubit<HttpState> {
  final Repository repository;

  /// Construtor para criar uma instância do [HttpCubit].
  ///
  /// [repository] é usado para fazer chamadas à API relacionadas a login e logout.
  HttpCubit({required this.repository}) : super(HttpInitial());

  dynamic pastDays = 1;
  String? selectedLocal;
  List<Local>? localDataList;
  List<PlacaData>? nodeDataList;
  String? selectedSensor;
  List<dynamic>? selectedSensorList;
  List<dynamic>? selectedSensorMinList;
  List<dynamic>? selectedSensorMaxList;
  Map<String, dynamic>? selectedMetrics;

  SensorData sensorsData = SensorData(
      temperatureList: [],
      tdsList: [],
      turbidityList: [],
      phList: [],
      dataTimeList: []);

  Map<String, dynamic> metricsList = {};

  List<String> sensorList = [
    'Temperatura',
    'TDS',
    'Turbidez',
    'pH',
  ];

  // Relaciona o nome do sensor com sua chave para fazer a requisição
  Map<String, String> sensorMap = {
    'Temperatura': 'temperature',
    'TDS': 'tds',
    'Turbidez': 'turbidity',
    'pH': 'ph',
  };

  /// Busca os dados dos locais.
  ///
  /// Faz uma chamada ao método `fetchLocals` do repositório e atualiza a lista de dados
  /// dos locais. Emite o estado [HttpLocalLoaded] quando os dados dos locais são carregados com sucesso.
  /// Lança uma exceção em caso de erro.
  void fetchLocals([String queryParameters = '']) {
    emit(HttpLoading());
    repository.fetchLocals(queryParameters).then((localsDataList) {
      selectedLocal = localsDataList.first.localName;
      localDataList = localsDataList;
      emit(HttpLocalLoaded());
    }).catchError((e) {
      emit(HttpError(errorMessage: e.toString()));
    });
  }

  /// Busca os dados das placas.
  ///
  /// Faz uma chamada ao método `fetchNodeData` do repositório e atualiza a lista de dados
  /// das placas. Emite o estado [HttpLocalLoaded] quando os dados dos locais são carregados com sucesso.
  /// Lança uma exceção em caso de erro.
  Future<void> fetchNodeData([String queryParameters = '']) async {
    repository.fetchNodeData(queryParameters).then((value) {
      nodeDataList = value;
      emit(HttpLocalLoaded());
    }).catchError((e) {
      emit(HttpError(errorMessage: e.toString()));
    });
  }

  /// Busca os dados dos sensores para um local específico.
  ///
  /// Faz uma chamada ao método `fetchSensorsData` do repositório, atualiza as métricas e os
  /// dados dos sensores. Emite o estado [HttpDataLoaded] quando os dados são carregados com sucesso.
  /// Lança uma exceção em caso de erro.
  void fetchSensorsData(String local) {
    emit(HttpLoading());
    selectedLocal = local;
    repository.fetchSensorsData(local, pastDays).then((data) {
      metricsList = data['metricas'];
      List dataList = data['dados'];
      if (dataList.isNotEmpty) {
        Map<String, dynamic> dataMap = dataList.first;
        sensorsData = SensorData.fromJson(dataMap);
        selectedSensor = "Temperatura";
        getSelectedMetrics(selectedSensor);
        getSelectedSensorList();
        emit(HttpDataLoaded());
      }
    }).catchError((e) {
      emit(HttpError(errorMessage: e.toString()));
    });
  }

  /// Obtém a lista de nomes de locais.
  ///
  /// Retorna uma lista com os nomes dos locais extraídos da lista de dados de locais.
  List<String> getLocalList() {
    return localDataList!.map((e) => e.localName!).toList();
  }

  /// Define o número de dias passados para consultas de dados.
  ///
  /// Atualiza a variável [pastDays] com o valor fornecido.
  void setPastDays(dynamic selectedNumber) async {
    pastDays = selectedNumber;
  }

  /// Obtém as métricas selecionadas para um sensor específico.
  ///
  /// Atualiza a variável [selectedMetrics] com as métricas do sensor selecionado e emite
  /// o estado [HttpDataLoaded]. Lança uma exceção se o sensor selecionado for nulo.
  Future<void> getSelectedMetrics(String? value) async {
    selectedSensor = value;
    selectedMetrics = metricsList[sensorMap[selectedSensor]];
    emit(HttpDataLoaded());
  }

  /// Obtém a lista de dados de sensores para o sensor selecionado.
  ///
  /// Atualiza as listas de sensores mínimos e máximos com base no sensor selecionado e
  /// nos dados disponíveis. Emite o estado [HttpDataLoaded] após a atualização.
  Future<void> getSelectedSensorList() async {
    Map<String, List<dynamic>> sensorListMap = {
      'Temperatura': sensorsData.temperatureList,
      'TDS': sensorsData.tdsList,
      'Turbidez': sensorsData.turbidityList,
      'pH': sensorsData.phList,
    };
    selectedSensorList = sensorListMap[selectedSensor];

    Map<String, Map<String, List<dynamic>?>> sensorMinMaxMap = {
      'Temperatura': {
        'min': sensorsData.temperatureListMin,
        'max': sensorsData.temperatureListMax,
      },
      'TDS': {
        'min': sensorsData.tdsListMin,
        'max': sensorsData.tdsListMax,
      },
      'Turbidez': {
        'min': sensorsData.turbidityListMin,
        'max': sensorsData.turbidityListMax,
      },
      'pH': {
        'min': sensorsData.phListMin,
        'max': sensorsData.phListMax,
      }
    };
    if (pastDays == '' || pastDays == 30) {
      selectedSensorMinList = sensorMinMaxMap[selectedSensor]?['min'];
      selectedSensorMaxList = sensorMinMaxMap[selectedSensor]?['max'];
    } else {
      selectedSensorMinList = [];
      selectedSensorMaxList = [];
    }
  }

  /// Atualiza os dados dos sensores para um local específico.
  ///
  /// Faz uma chamada ao método `fetchSensorsData` do repositório e atualiza as métricas e os
  /// dados dos sensores. Emite o estado [HttpDataLoaded] após a atualização dos dados. Essa função é semelhante a
  /// 'fetchSensorsData', a diferença é que o estado de 'HttpLoading' não é emitido, fazendo com que a tela não recarregue.
  void updateData(String local) {
    selectedLocal = local;
    repository.fetchSensorsData(local, pastDays).then((data) {
      metricsList = data['metricas'];
      List dataList = data['dados'];
      if (dataList.isNotEmpty) {
        Map<String, dynamic> dataMap = data['dados'].first;
        sensorsData = SensorData.fromJson(dataMap);
        selectedSensor = selectedSensor ?? "Temperatura";
        getSelectedMetrics(selectedSensor);
        getSelectedSensorList();
        emit(HttpDataLoaded());
      }
    }).catchError((e) {
      emit(HttpError(errorMessage: e.toString()));
    });
  }

  /// Reseta o estado do cubit para o estado inicial.
  ///
  /// Emite o estado [HttpInitial] para reiniciar o estado do cubit.
  void resetState() {
    emit(HttpInitial());
  }
}
