/// Representa os dados dos sensores coletados, incluindo listas de medições, valores máximos e mínimos.
class SensorData {
  final List<dynamic> temperatureList;
  final List<dynamic>? temperatureListMin;
  final List<dynamic>? temperatureListMax;
  final List<dynamic> tdsList;
  final List<dynamic>? tdsListMin;
  final List<dynamic>? tdsListMax;
  final List<dynamic> turbidityList;
  final List<dynamic>? turbidityListMin;
  final List<dynamic>? turbidityListMax;
  final List<dynamic> phList;
  final List<dynamic>? phListMin;
  final List<dynamic>? phListMax;
  final List<String> dataTimeList;

  SensorData({
    required this.temperatureList,
    this.temperatureListMin,
    this.temperatureListMax,
    required this.tdsList,
    this.tdsListMin,
    this.tdsListMax,
    required this.turbidityList,
    this.turbidityListMin,
    this.turbidityListMax,
    required this.phList,
    this.phListMin,
    this.phListMax,
    required this.dataTimeList,
  });

  /// Cria uma instância de [SensorData] a partir de um mapa JSON.
  ///
  /// [dataList] O mapa JSON contendo os dados dos sensores.
  factory SensorData.fromJson(Map<String, dynamic> dataList) {
    return SensorData(
      temperatureList: dataList['temperature'],
      temperatureListMin: dataList['temperature_min'],
      temperatureListMax: dataList['temperature_max'],
      tdsList: dataList['tds'],
      tdsListMin: dataList['tds_min'],
      tdsListMax: dataList['tds_max'],
      turbidityList: dataList['turbidity'],
      turbidityListMin: dataList['turbidity_min'],
      turbidityListMax: dataList['turbidity_max'],
      phList: dataList['ph'],
      phListMin: dataList['ph_min'],
      phListMax: dataList['ph_max'],
      dataTimeList: dataList['data'].cast<String>(),
    );
  }
}
