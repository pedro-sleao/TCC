/// Representa um local com informações de nome, latitude e longitude.
class Local {
  final String? localName;

  /// Cria uma instância de [Local] com os valores fornecidos.
  ///
  /// [localName] O nome do local.
  Local({
    required this.localName,
  });

  /// Cria uma instância de [Local] a partir de um mapa JSON.
  ///
  /// [json] O mapa JSON contendo os dados do local.
  factory Local.fromJson(Map<String, dynamic> json) {
    return Local(
      localName: json['local'],
    );
  }
}

/// Analisa uma lista de mapas JSON e retorna uma lista de instâncias de [Local].
///
/// Apenas os mapas JSON que contêm valores não nulos para 'local', 'latitude' e 'longitude'
/// são convertidos em instâncias de [Local].
///
/// [jsonList] A lista de mapas JSON a serem analisados.
///
/// Retorna uma lista de instâncias de [Local] criadas a partir dos dados JSON.
List<Local> parseLocalList(List<dynamic> jsonList) {
  return jsonList
      .where((json) =>
          json['local'] != null)
      .map((json) => Local.fromJson(json))
      .toList();
}
