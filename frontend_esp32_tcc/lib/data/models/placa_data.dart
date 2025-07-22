/// Representa os dados de uma placa, incluindo informações sobre o local e sensores.
class PlacaData {
  final String? localName;
  final String idPlaca;
  final bool? checkTemp;
  final bool? checkTds;
  final bool? checkTurb;
  final bool? checkPh;
  final bool? checkStatus;
  final String? firmwareVersion;

  /// Cria uma instância de [PlacaData] a partir de um mapa JSON.
  ///
  /// [json] O mapa JSON contendo os dados da placa.
  PlacaData.fromJson(Map json)
      : localName = json['local'],
        idPlaca = json['id_placa'].toString(),
        checkTemp = json['temperature'],
        checkTds = json['tds'],
        checkTurb = json['turbidity'],
        checkPh = json['ph'],
        checkStatus = json['status'],
        firmwareVersion = json['firmware_version'];
}

/// Analisa uma lista de mapas JSON e retorna uma lista de instâncias de [PlacaData].
///
/// Cada mapa JSON na lista é convertido em uma instância de [PlacaData].
///
/// [jsonList] A lista de mapas JSON a serem analisados.
///
/// Retorna uma lista de instâncias de [PlacaData] criadas a partir dos dados JSON.
List<PlacaData> parseLocalDataList(List<dynamic> jsonList) {
  return jsonList.map((json) => PlacaData.fromJson(json)).toList();
}
