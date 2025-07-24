
import 'package:dashboard_flutter/data/http_services.dart';
import 'package:dashboard_flutter/data/models/locals.dart';
import 'package:dashboard_flutter/data/models/placa_data.dart';
import 'package:file_picker/file_picker.dart';

/// Repositório para acesso e manipulação de dados.
///
/// Esta classe atua como uma camada intermediária entre o serviço HTTP (`HttpService`),
/// e o restante da aplicação. Ela fornece métodos para obter e manipular dados
/// relacionados ao usuário, locais e sensores, além de realizar operações de login e logout.
class Repository {
  final HttpService httpService;

  /// Construtor para criar uma instância do `Repository` com o serviço HTTP fornecido.
  ///
  /// O [httpService] é necessário para realizar operações de rede.
  Repository({required this.httpService});

  /// Obtém os dados do usuário autenticado.
  ///
  /// Faz uma chamada ao método `fetchUser` do `HttpService` e retorna os dados do usuário.
  /// Se ocorrer um erro, uma exceção é lançada.
  Future<Map<String, dynamic>> fetchUser() async {
    try {
      final userRaw = httpService.fetchUser();
      return userRaw;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Realiza o login de um usuário.
  ///
  /// Faz uma chamada ao método `login` do `HttpService` com as credenciais fornecidas.
  /// Retorna os dados de login se a operação for bem-sucedida, ou lança uma exceção em caso de erro.
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final loginRaw = httpService.login(username, password);
      return loginRaw;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Realiza o logout do usuário.
  ///
  /// Faz uma chamada ao método `logout` do `HttpService` e retorna um valor booleano indicando
  /// se o logout foi bem-sucedido. Lança uma exceção em caso de erro.
  Future<bool> logout() async {
    final logoutBool = await httpService.logout();
    return logoutBool;
  }

  /// Registra um novo usuário.
  ///
  /// Faz uma chamada ao método `register` do `HttpService` com os dados do usuário. Retorna
  /// a mensagem de resposta do servidor. Lança uma exceção se a operação falhar.
  Future<String> register(String username, String password) async {
    try {
      final registerMsg = await httpService.register(username, password);
      return registerMsg['message'];
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Deleta um usuário.
  ///
  /// Faz uma chamada ao método `deleteUser` do `HttpService` com o nome do usuário. Retorna
  /// a mensagem de resposta do servidor. Lança uma exceção em caso de erro.
  Future<String> deleteUser(String username) async {
    try {
      final deleteMsg = await httpService.deleteUser(username);
      return deleteMsg['message'];
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Obtém os dados dos locais.
  ///
  /// Faz uma chamada ao método `fetchLocals` do `HttpService` com parâmetros opcionais de consulta.
  /// Converte os dados brutos em uma lista de objetos `Local` e a retorna. Lança uma exceção
  /// se ocorrer um erro.
  Future<List<Local>> fetchLocals([String queryParameters = '']) async {
    try {
      final localsRaw = await httpService.fetchLocals(queryParameters);
      return parseLocalList(localsRaw); 
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Obtém os dados das placas.
  ///
  /// Faz uma chamada ao método `fetchLocals` do `HttpService` com parâmetros opcionais de consulta
  /// e converte os dados brutos em uma lista de objetos `PlacaData`. Retorna a lista de dados
  /// das placas. Lança uma exceção se a operação falhar.
  Future<List<PlacaData>> fetchNodeData([String queryParameters = '']) async {
    try {
      final localsDataRaw = await httpService.fetchLocals(queryParameters);
      return parseLocalDataList(localsDataRaw);
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Obtém dados dos sensores de um local específico.
  ///
  /// Faz uma chamada ao método `fetchSensorsData` do `HttpService` com o nome do local e
  /// parâmetros opcionais para dias passados. Retorna os dados dos sensores. Lança uma exceção
  /// se a operação falhar.
  Future<Map<String, dynamic>> fetchSensorsData(
      String local, dynamic pastDays) async {
    try {
      final sensorsDataRaw =
          await httpService.fetchSensorsData(local, pastDays);
      return sensorsDataRaw;
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Obtém a lista de nomes de usuários.
  ///
  /// Faz uma chamada ao método `fecthUsers` do `HttpService` e converte os dados de usuários
  /// em uma lista de nomes de usuário. Lança uma exceção se a operação falhar.
  Future<List<String>> fecthUsers() async {
    try {
      final usersRaw = await httpService.fecthUsers();
      final List<String> usernames =
          List<String>.from(usersRaw['data'].map((user) => user['username']));
      return usernames;
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Registra os dados de uma placa.
  ///
  /// Faz uma chamada ao método `registerNodeData` do `HttpService` com os dados de uma placa.
  /// Retorna a mensagem de resposta do servidor. Lança uma exceção se a operação falhar.
  Future<String> registerNodeData(String localName, String idPlaca,
    Map sensorStates) async {
    final responseMsg = await httpService.registerNodeData(
        localName, idPlaca, sensorStates);
    return responseMsg['message'];
  }


  /// Envia o arquivo binario do firmware para o servidor
  /// 
  /// Faz uma achamada ao método `updateFirmwareOTA` do `HttpService` com o arquivo selecionado.
  Future<void> uploadFirmware() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) {
      throw Exception("Arquivo inválido ou não selecionado.");
    }

    final file = result.files.single;
    await httpService.updateFirmwareOTA(file);
  }


  /// Envia os dados de calibração para o servidor
  Future<String> sendCalibrationData(String idPlaca,
    dynamic phExpectedValue, dynamic tdsExpectedValue) async {
    
    try {
      final responseMsg = await httpService.sendCalibrationData(
        idPlaca, phExpectedValue, tdsExpectedValue);
      return responseMsg['message'];
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Solicita novos dados dos sensores em um local
  Future<String> requestNewData(String local) async {
    
    try {
      final responseMsg = await httpService.requestNewData(
        local);
      return responseMsg['message'];
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
